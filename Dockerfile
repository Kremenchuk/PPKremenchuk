# syntax=docker/dockerfile:1
# =====================================================================
#  STM Industry — production image
#
#  Multi-stage: everything that needs a compiler or Node lives in the
#  `build` stage and is thrown away, so the final image ships only the
#  runtime libraries, the installed gems and the precompiled assets.
#
#  Layer order is deliberate — see the comments at each COPY:
#    * Gemfile / Gemfile.lock change  -> `bundle install` re-runs
#    * package.json / yarn.lock change -> `yarn install` re-runs
#    * any other source change         -> only the asset build re-runs
# =====================================================================

ARG RUBY_VERSION=3.4.8
ARG NODE_MAJOR=20

# ---------------------------------------------------------------- base
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

# libsqlite3-0 – the database driver
# imagemagick  – CarrierWave/MiniMagick builds gallery thumbnails at upload
# curl         – container healthcheck
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libsqlite3-0 imagemagick tzdata && \
    rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------------- build
FROM base AS build

ARG NODE_MAJOR

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git pkg-config libsqlite3-dev && \
    curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install --no-install-recommends -y nodejs && \
    npm install -g yarn@1.22.22 && \
    rm -rf /var/lib/apt/lists/*

# ---- gems (cached until the Gemfile changes) ------------------------
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# ---- node modules (cached until package.json / yarn.lock change) -----
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 600000

# ---- application code ------------------------------------------------
COPY . .

# webpack bundle (jsbundling-rails hooks `yarn build` into assets:precompile)
# and the sprockets/sassc stylesheets. SECRET_KEY_BASE_DUMMY lets the task
# boot without config/master.key, which is not in the repository.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Drop what only the build needed, so it is not copied into the final image.
RUN rm -rf node_modules tmp/cache .git

# ---------------------------------------------------------------- final
FROM base

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run as a non-root user; the writable paths are the mounted volumes.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p db log storage tmp/pids public/uploads && \
    chown -R rails:rails db log storage tmp public/uploads
USER rails:rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

# README
Rename '.env_local' to '.env' before deploying

`docker-compose build`

`docker-compose run --rm stm_industry_dev bundle exec rails db:create`

`docker-compose run --rm stm_industry_dev bundle exec rake db:migrate`

`docker-compose run --rm stm_industry_dev bundle exec rake db:seed`

`docker-compose run --rm stm_industry_dev bundle exec rails assets:precompile --trace`

`docker-compose up`


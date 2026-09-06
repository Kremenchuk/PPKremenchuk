# STM Industry

Сайт производителя металлических стеллажей (Rails 7.2 / Ruby 3.4 / SQLite,
i18n uk/en/ru, онлайн-калькулятор с 3D-превью на Three.js).

## Деплой на прод

Полная пошаговая инструкция для DevOps — в **[DEPLOY.md](DEPLOY.md)**
(Docker Compose и Render, секреты, тома, обновление, откат, чеклист).

Быстрый старт (свой сервер, Docker):

```bash
cp .env_local .env            # заполнить HOST/DOMAIN; положить config/master.key
docker compose build          # сборка образа + assets:precompile
docker compose up -d          # старт (entrypoint сам делает db:prepare + db:seed)
```

Приложение слушает `:3000` — поставьте перед ним reverse-proxy с HTTPS.

## Локальная разработка

```bash
bundle install
yarn install
bin/rails db:prepare db:seed
bin/dev                       # rails server + webpack --watch → http://localhost:3000
```

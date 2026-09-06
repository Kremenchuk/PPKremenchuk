# Деплой STM Industry — инструкция для DevOps

Пошаговый гайд по выкладке сайта **stm-industry** на прод. Есть два поддерживаемых
сценария: **A) свой сервер через Docker Compose** (рекомендуется для прода) и
**B) Render.com** (как сейчас настроен staging).

---

## 0. Что это за приложение

| | |
|---|---|
| Стек | Ruby 3.4.8, Rails 7.2, Puma |
| БД | **SQLite** (файл `storage/production.sqlite3`) |
| Ассеты | jsbundling (webpack/yarn) + sprockets/sassc, `assets:precompile` на этапе сборки |
| Загрузки | CarrierWave → `public/uploads` |
| i18n | uk (по умолчанию), en |
| Данные-сиды | админ + константы калькулятора (`db/seeds.rb`, идемпотентно) |

Внешних сервисов (Redis, отдельная СУБД) нет — SQLite это файл, поэтому «сервиса
базы» в compose нет. Для прод-нагрузки это ок при одном инстансе; для
горизонтального масштабирования нужен переезд на PostgreSQL (см. §5).

---

## 1. Предварительные требования

- **Docker 24+** и **Docker Compose v2** (`docker compose`, не дефис) — для сценария A.
- Доступ к git-репозиторию `Kremenchuk/PPKremenchuk`. ⚠️ **Стек деплоя
  (Dockerfile, `docker-compose.yml`, `bin/docker-entrypoint`, `.env_local`) живёт
  в ветке `new_design`** — деплойте её; старый `master` этого стека не содержит.
  После слияния `new_design → master` деплойте `master`.
- **Секреты** (см. §2): `config/master.key` и `.env`.
- Для сценария A — reverse-proxy (nginx/Caddy/Traefik) и TLS-сертификат перед контейнером.

---

## 2. Секреты и конфигурация

### 2.1 `config/master.key`
Расшифровывает `config/credentials.yml.enc`. Нужен приложению **в рантайме**
(иначе Rails не стартует в production).

> ⚠️ Исторически `master.key` закоммичен в репозиторий. Для настоящего прода
> **сгенерируйте новые credentials и ротуйте ключ**, а сам ключ передавайте вне
> git — файлом `config/master.key` или переменной `RAILS_MASTER_KEY`.

Варианты передать ключ контейнеру:
- положить файл `config/master.key` (он попадает в образ при сборке), **или**
- передать `RAILS_MASTER_KEY=<ключ>` в окружении (добавьте в `.env`).

### 2.2 `.env`
Скопируйте пример и заполните:

```bash
cp .env_local .env      # если есть шаблон; иначе создайте вручную
```

Минимум:

```dotenv
HOST=stm-industry.com.ua
DOMAIN=stm-industry.com.ua
# SMTP (smtp.gmail.com, см. config/environments/production.rb) — без этих двух
# переменных форма обратной связи не отправляет письма
USER_NAME=<gmail-логин>
PASSWORD=<пароль приложения Gmail>
# опционально, если не кладёте config/master.key в образ:
# RAILS_MASTER_KEY=<содержимое config/master.key>
```

`docker-compose.yml` уже задаёт `RAILS_ENV=production`,
`RAILS_SERVE_STATIC_FILES=true`, `RAILS_LOG_TO_STDOUT=true`,
`DATABASE_URL=sqlite3:storage/production.sqlite3`.

---

## 3. Сценарий A — свой сервер (Docker Compose) ✅ рекомендуемый

### 3.1 Первый запуск

```bash
# 1. получить код
git clone https://github.com/Kremenchuk/PPKremenchuk.git stm-industry
cd stm-industry
git checkout new_design      # ветка с этим стеком (после слияния — master)

# 2. секреты
cp .env_local .env            # заполнить HOST/DOMAIN (§2.2)
#   и положить config/master.key ЛИБО прописать RAILS_MASTER_KEY в .env

# 3. собрать образ (assets:precompile выполняется внутри сборки)
docker compose build

# 4. поднять
docker compose up -d
```

При старте `bin/docker-entrypoint` сам выполнит `rails db:prepare` (создаст/мигрирует
SQLite) и `rails db:seed` (админ + константы). Отдельные `db:create/migrate/seed`
руками не нужны.

### 3.2 Проверка

```bash
docker compose ps                    # web → Up (healthy) через ~40 c
docker compose logs -f web           # ждём "Listening on http://0.0.0.0:3000"
curl -fsS http://localhost:3000/ >/dev/null && echo OK
```

Контейнер слушает **:3000**. Поставьте перед ним reverse-proxy c HTTPS
(терминирование TLS на nginx/Caddy, `proxy_pass http://127.0.0.1:3000`).

Логин админа берётся из `db/seeds.rb` (по умолчанию `kremenchuk@bk.ru` / `123456`)
— **обязательно смените пароль после первого входа**.

### 3.3 Данные и тома (важно для бэкапов)

Именованные тома в `docker-compose.yml`:

| том | что внутри |
|---|---|
| `storage` | `storage/production.sqlite3` + Active Storage |
| `uploads` | `public/uploads` (галерея CarrierWave) |
| `logs`    | `log/` |

Бэкап (пример):

```bash
# БД — в образе нет sqlite3-CLI (только libsqlite3), поэтому копируем файлы
# тома. Делайте в окно низкой нагрузки; маска захватывает и -wal/-shm.
docker run --rm -v stm-industry_storage:/data -v "$PWD":/out alpine \
  sh -c 'cd /data && tar czf /out/db-$(date +%F).tgz production.sqlite3*'
# загрузки
docker run --rm -v stm-industry_uploads:/data -v "$PWD":/out alpine \
  tar czf /out/uploads-$(date +%F).tgz -C /data .
```

### 3.4 Обновление (выкатка новой версии)

```bash
git pull origin master
docker compose build            # пересобирает ассеты и код
docker compose up -d            # пересоздаёт контейнер, тома сохраняются
docker image prune -f           # почистить старые слои
```

Простой при рестарте — секунды. Миграции применяются автоматически на старте
(entrypoint). Перед выкаткой снимите бэкап БД (§3.3).

### 3.5 Откат

```bash
git checkout <предыдущий-тег-или-SHA>
docker compose build && docker compose up -d
# при несовместимой миграции — восстановить БД из бэкапа (§3.3)
```

---

## 4. Сценарий B — Render.com (текущий staging)

Сервис `stm-staging` (srv-`dae7b9uq1p3s7388a120`), нативный Ruby-рантайм,
источник — `Kremenchuk/PPKremenchuk@new_design`. Для прода заведите отдельный
сервис из ветки `master`.

**Build Command:**
```bash
bundle install && yarn install --frozen-lockfile && bundle exec rails assets:precompile
```

**Start Command:**
```bash
bin/rails db:prepare && bin/rails db:seed && bundle exec puma -C config/puma.rb
```

**Environment:**
```
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=1
RAILS_SERVE_STATIC_FILES=true
RAILS_MASTER_KEY=<config/master.key>
DATABASE_URL=sqlite3:storage/production.sqlite3   # иначе SQLite ляжет в db/
HOST=<домен>
DOMAIN=<домен>
USER_NAME=<gmail-логин>            # SMTP для формы обратной связи
PASSWORD=<пароль приложения Gmail>
```

**Деплой:**
- по `git push` в отслеживаемую ветку (если подключён GitHub-репо), **или**
- вручную через **Deploy Hook** (Settings → Deploy Hook):
  ```bash
  curl -X POST "https://api.render.com/deploy/<SERVICE_ID>?key=<DEPLOY_KEY>"
  ```

> ⚠️ **Ограничение Free-плана:** диск эфемерный — при засыпании/редеплое SQLite
> пересоздаётся из сидов, пользовательские данные и загрузки теряются. Для прода
> на Render нужен платный **Persistent Disk** (смонтировать `storage/` и
> `public/uploads/`) или переезд на управляемый **PostgreSQL** (§5).

---

## 5. Чеклист прод-готовности

- [ ] **Секреты вне git:** ротовать `master.key`, передавать через `RAILS_MASTER_KEY`.
- [ ] **Сменить пароль админа** из сидов после первого входа.
- [ ] **Персистентность БД:** SQLite на постоянном диске (том Docker или Persistent
      Disk на Render). При росте нагрузки/нескольких инстансах — миграция на PostgreSQL
      (заменить `sqlite3` на `pg` в `Gemfile`, `DATABASE_URL=postgres://…`).
- [ ] **HTTPS:** TLS на reverse-proxy; при желании включить `config.force_ssl`.
- [ ] **Бэкапы:** регулярный дамп `storage/` и `public/uploads/` (§3.3), хранить вне сервера.
- [ ] **Логи:** `RAILS_LOG_TO_STDOUT=1` + сбор логов proxy/докера; ротация тома `logs`.
- [ ] **Healthcheck:** в compose уже есть (`GET /`); подключить к мониторингу/алертам.
- [ ] **Домен/почта:** проверить `HOST`/`DOMAIN` в `.env` и работу формы обратной связи (SMTP).

---

## 6. Шпаргалка

```bash
docker compose build            # собрать образ (+ассеты)
docker compose up -d            # поднять
docker compose logs -f web      # логи
docker compose ps               # статус/health
docker compose exec web bash    # шелл внутри контейнера
docker compose down             # остановить (тома сохраняются)
```

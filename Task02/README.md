# Лабораторная работа № 2

Скрипт создаёт и заполняет базу данных SQLite `movies_rating.db` данными из файлов в каталоге `Task02`.

## Требования к окружению

- Python 3 с доступной командой `python3`;
- SQLite 3 с доступной командой `sqlite3`;
- Bash (на Windows можно использовать Git Bash).

Проверка установленных программ:

```bash
python3 --version
sqlite3 --version
```

## Запуск

Перейдите в каталог `Task02` и выполните:

```bash
bash db_init.bat
```

`db_init.bat` запускает `make_db_init.py`, который формирует `db_init.sql`, затем выполняет этот SQL-скрипт в базе `movies_rating.db`. Создаются и заполняются таблицы `movies`, `ratings`, `tags` и `users`. При повторном запуске таблицы создаются заново.

import csv
import re
from pathlib import Path

folder = Path(__file__).parent


def sql_text(value):
    return "'" + value.replace("'", "''") + "'"


with (folder / "db_init.sql").open("w", encoding="utf-8") as out:
    out.write("""BEGIN TRANSACTION;

DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;

CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER,
    genres TEXT
);

CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating REAL NOT NULL,
    timestamp INTEGER NOT NULL
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    timestamp INTEGER NOT NULL
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);

""")

    with (folder / "movies.csv").open(encoding="utf-8", newline="") as source:
        for row in csv.DictReader(source):
            title = row["title"].strip()
            match = re.search(r"\((\d{4})\)$", title)
            year = match.group(1) if match else "NULL"
            if match:
                title = title[:match.start()].strip()

            out.write(
                f"INSERT INTO movies VALUES ("
                f"{int(row['movieId'])}, {sql_text(title)}, "
                f"{year}, {sql_text(row['genres'])});\n"
            )

    with (folder / "ratings.csv").open(encoding="utf-8", newline="") as source:
        for number, row in enumerate(csv.DictReader(source), start=1):
            out.write(
                f"INSERT INTO ratings VALUES ("
                f"{number}, {int(row['userId'])}, {int(row['movieId'])}, "
                f"{float(row['rating'])}, {int(row['timestamp'])});\n"
            )

    with (folder / "tags.csv").open(encoding="utf-8", newline="") as source:
        for number, row in enumerate(csv.DictReader(source), start=1):
            out.write(
                f"INSERT INTO tags VALUES ("
                f"{number}, {int(row['userId'])}, {int(row['movieId'])}, "
                f"{sql_text(row['tag'])}, {int(row['timestamp'])});\n"
            )

    with (folder / "users.txt").open(encoding="utf-8") as source:
        for line in source:
            user_id, name, email, gender, registered, occupation = (
                line.rstrip("\r\n").split("|")
            )
            out.write(
                f"INSERT INTO users VALUES ("
                f"{int(user_id)}, {sql_text(name)}, {sql_text(email)}, "
                f"{sql_text(gender)}, {sql_text(registered)}, "
                f"{sql_text(occupation)});\n"
            )

    out.write("\nCOMMIT;\n")
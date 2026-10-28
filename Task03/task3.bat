#!/bin/bash
chcp 65001 2>/dev/null || true

sqlite3 movies_rating.db < db_init.sql

echo "1. Фильмы с хотя бы одной оценкой: первые 10 по году выпуска и названию."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "
SELECT m.title, m.year
FROM movies AS m
WHERE EXISTS (
    SELECT 1
    FROM ratings AS r
    WHERE r.movie_id = m.id
)
ORDER BY m.year IS NULL, m.year, m.title
LIMIT 10;
"
echo " "

echo "2. Пользователи, чьи фамилии начинаются на A: первые 5 по дате регистрации."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "
SELECT u.name, u.register_date
FROM users AS u
WHERE substr(u.name, instr(u.name, ' ') + 1) LIKE 'A%'
ORDER BY u.register_date, u.name
LIMIT 5;
"
echo " "

echo "3. Эксперт, фильм, год, оценка и дата оценки: первые 50 записей."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "
SELECT u.name AS expert,
       m.title AS movie,
       m.year,
       r.rating,
       date(r.timestamp, 'unixepoch') AS rating_date
FROM ratings AS r
JOIN users AS u ON u.id = r.user_id
JOIN movies AS m ON m.id = r.movie_id
ORDER BY u.name, m.title, r.rating
LIMIT 50;
"
echo " "

echo "4. Фильмы и присвоенные им теги: первые 40 записей."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "
SELECT m.title, m.year, t.tag
FROM movies AS m
JOIN tags AS t ON t.movie_id = m.id
ORDER BY m.year IS NULL, m.year, m.title, t.tag
LIMIT 40;
"
echo " "

echo "5. Все фильмы последнего года выпуска в базе."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "
SELECT title, year
FROM movies
WHERE year = (SELECT MAX(year) FROM movies)
ORDER BY title;
"
echo " "

echo "6. Комедии после 2000 года с оценками мужчин не ниже 4.5."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "
SELECT m.title, m.year, COUNT(*) AS matching_ratings
FROM movies AS m
JOIN ratings AS r ON r.movie_id = m.id
JOIN users AS u ON u.id = r.user_id
WHERE m.year > 2000
  AND instr('|' || m.genres || '|', '|Comedy|') > 0
  AND u.gender = 'male'
  AND r.rating >= 4.5
GROUP BY m.id, m.title, m.year
ORDER BY m.year, m.title;
"
echo " "

echo "7. Количество пользователей каждой профессии, самые частые и редкие профессии."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "
WITH occupation_counts AS (
    SELECT occupation, COUNT(*) AS user_count
    FROM users
    GROUP BY occupation
),
bounds AS (
    SELECT MAX(user_count) AS max_count, MIN(user_count) AS min_count
    FROM occupation_counts
)
SELECT c.occupation, c.user_count,
       CASE
           WHEN c.user_count = b.max_count THEN 'самая распространенная'
           WHEN c.user_count = b.min_count THEN 'самая редкая'
           ELSE ''
       END AS frequency
FROM occupation_counts AS c
CROSS JOIN bounds AS b
ORDER BY c.user_count DESC, c.occupation;
"

-- 04_vector_similarity_queries.sql
-- Purpose:
--   Run vector similarity searches using VECTOR_DISTANCE.
--
-- Beginner note:
--   VECTOR_DISTANCE compares two vectors.
--   A smaller distance means a closer match.
--   The ORDER BY clause places the closest records first.
--
-- Run as:
--   sqlplus vector_lab/VectorLab_2026@KBPDB @sql/04_vector_similarity_queries.sql

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 220
SET PAGESIZE 100

COLUMN title FORMAT A55
COLUMN category FORMAT A20
COLUMN cosine_distance FORMAT 9999990.999999
COLUMN vector_value FORMAT A80

PROMPT ===== Connected User =====
SHOW USER;

PROMPT ===== All Sample Records =====

SELECT note_id, title, category
FROM support_notes
ORDER BY note_id;

PROMPT ===== Backup / Recovery Similarity Search =====
PROMPT Query vector: [0.90, 0.10, 0.05, 0.10, 0.05]
PROMPT The first dimension is highest, so this query represents Backup / Recovery.

SELECT
    note_id,
    title,
    category,
    ROUND(VECTOR_DISTANCE(
        embedding,
        TO_VECTOR('[0.90, 0.10, 0.05, 0.10, 0.05]', 5, FLOAT32),
        COSINE
    ), 6) AS cosine_distance
FROM support_notes
ORDER BY cosine_distance
FETCH FIRST 3 ROWS ONLY;

PROMPT ===== Backup Similarity Search With Relational Filter =====
PROMPT This combines vector search with a normal WHERE condition.

SELECT
    note_id,
    title,
    category,
    ROUND(VECTOR_DISTANCE(
        embedding,
        TO_VECTOR('[0.90, 0.10, 0.05, 0.10, 0.05]', 5, FLOAT32),
        COSINE
    ), 6) AS cosine_distance
FROM support_notes
WHERE category = 'Backup'
ORDER BY cosine_distance
FETCH FIRST 5 ROWS ONLY;

PROMPT ===== Network / Listener Similarity Search =====
PROMPT Query vector: [0.05, 0.95, 0.05, 0.05, 0.05]
PROMPT The second dimension is highest, so this query represents Network / Listener.

SELECT
    note_id,
    title,
    category,
    ROUND(VECTOR_DISTANCE(
        embedding,
        TO_VECTOR('[0.05, 0.95, 0.05, 0.05, 0.05]', 5, FLOAT32),
        COSINE
    ), 6) AS cosine_distance
FROM support_notes
ORDER BY cosine_distance
FETCH FIRST 3 ROWS ONLY;

PROMPT ===== View Stored Vector Values =====
PROMPT FROM_VECTOR converts stored vectors back into readable text.

SELECT
    note_id,
    title,
    FROM_VECTOR(embedding) AS vector_value
FROM support_notes
ORDER BY note_id;

PROMPT ===== Script Completed =====

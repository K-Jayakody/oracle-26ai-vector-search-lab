-- 05_hnsw_vector_index.sql
-- Purpose:
--   Create and verify an HNSW vector index on SUPPORT_NOTES.EMBEDDING.
--
-- Beginner note:
--   HNSW stands for Hierarchical Navigable Small World.
--   It is a graph-based vector index used for faster approximate similarity search.
--
-- Run as:
--   sqlplus vector_lab/VectorLab_2026@KBPDB @sql/05_hnsw_vector_index.sql
--
-- Note:
--   If index creation fails due to Vector Pool memory configuration,
--   connect as a privileged user and check:
--     SHOW PARAMETER vector_memory_size;

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 220
SET PAGESIZE 100

COLUMN index_name FORMAT A30
COLUMN index_type FORMAT A20
COLUMN index_subtype FORMAT A35
COLUMN status FORMAT A15
COLUMN title FORMAT A55
COLUMN category FORMAT A20
COLUMN cosine_distance FORMAT 9999990.999999

PROMPT ===== Connected User =====
SHOW USER;

PROMPT ===== Dropping Old HNSW Index If It Exists =====

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX support_notes_hnsw_idx';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1418 THEN
            NULL;
        ELSE
            RAISE;
        END IF;
END;
/

PROMPT ===== Creating HNSW Vector Index =====

CREATE VECTOR INDEX support_notes_hnsw_idx
ON support_notes (embedding)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE
WITH TARGET ACCURACY 95;

PROMPT ===== Verifying Vector Index =====

SELECT index_name, index_type, index_subtype, status
FROM user_indexes
WHERE index_name = 'SUPPORT_NOTES_HNSW_IDX';

PROMPT ===== Running Similarity Search Again After Index Creation =====

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

PROMPT ===== Optional Approximate Search Syntax =====
PROMPT This explicitly requests approximate search and can use the vector index when suitable.

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
FETCH APPROXIMATE FIRST 3 ROWS ONLY WITH TARGET ACCURACY 95;

PROMPT ===== Script Completed =====

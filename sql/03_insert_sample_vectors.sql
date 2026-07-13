-- 03_insert_sample_vectors.sql
-- Purpose:
--   Insert sample technical support notes with manually created vector embeddings.
--
-- Beginner note:
--   The embedding column stores a VECTOR(5, FLOAT32).
--   The 5 dimensions represent:
--     1 = Backup / Recovery
--     2 = Network / Listener
--     3 = Performance
--     4 = Security
--     5 = Installation / Configuration
--
-- Run as:
--   sqlplus vector_lab/VectorLab_2026@KBPDB @sql/03_insert_sample_vectors.sql

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 100

PROMPT ===== Connected User =====
SHOW USER;

PROMPT ===== Inserting Sample Records =====

INSERT INTO support_notes (title, category, note_text, embedding)
VALUES (
    'RMAN backup failure during nightly backup',
    'Backup',
    'RMAN backup failed because the archive log destination was full. Cleared old logs and re-ran the backup successfully.',
    TO_VECTOR('[0.95, 0.05, 0.05, 0.10, 0.05]', 5, FLOAT32)
);

INSERT INTO support_notes (title, category, note_text, embedding)
VALUES (
    'Listener service not reachable from application server',
    'Network',
    'The application server could not connect to the database listener. Verified port 1521, listener status, and firewall rules.',
    TO_VECTOR('[0.05, 0.95, 0.05, 0.05, 0.05]', 5, FLOAT32)
);

INSERT INTO support_notes (title, category, note_text, embedding)
VALUES (
    'Slow SQL query after application deployment',
    'Performance',
    'A query became slow after deployment. Execution plan changed and missing index was identified.',
    TO_VECTOR('[0.05, 0.10, 0.95, 0.05, 0.05]', 5, FLOAT32)
);

INSERT INTO support_notes (title, category, note_text, embedding)
VALUES (
    'User account locked due to failed login attempts',
    'Security',
    'A database user account was locked due to repeated failed login attempts. Checked profile settings and audit logs.',
    TO_VECTOR('[0.10, 0.05, 0.05, 0.95, 0.05]', 5, FLOAT32)
);

INSERT INTO support_notes (title, category, note_text, embedding)
VALUES (
    'Oracle installation prerequisite package missing',
    'Installation',
    'Oracle software installation failed because required operating system prerequisite packages were missing.',
    TO_VECTOR('[0.05, 0.05, 0.05, 0.05, 0.95]', 5, FLOAT32)
);

INSERT INTO support_notes (title, category, note_text, embedding)
VALUES (
    'Archive log destination error in Data Guard setup',
    'Backup',
    'LOG_ARCHIVE_DEST configuration caused an error while configuring archive log shipping for a standby database.',
    TO_VECTOR('[0.90, 0.10, 0.10, 0.10, 0.10]', 5, FLOAT32)
);

COMMIT;

PROMPT ===== Verifying Inserted Records =====

COLUMN title FORMAT A55
COLUMN category FORMAT A20

SELECT note_id, title, category
FROM support_notes
ORDER BY note_id;

PROMPT ===== Script Completed =====

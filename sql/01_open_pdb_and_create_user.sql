-- 01_open_pdb_and_create_user.sql
-- Purpose:
--   Open the KBPDB pluggable database, save its open state, and create the VECTOR_LAB user.
--
-- Run as:
--   sqlplus / as sysdba @sql/01_open_pdb_and_create_user.sql

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ===== Current Container =====
SHOW CON_NAME;

PROMPT ===== Available PDBs =====
SHOW PDBS;

PROMPT ===== Opening KBPDB =====
ALTER PLUGGABLE DATABASE KBPDB OPEN;

PROMPT ===== Saving KBPDB Open State =====
ALTER PLUGGABLE DATABASE KBPDB SAVE STATE;

PROMPT ===== Switching to KBPDB =====
ALTER SESSION SET CONTAINER = KBPDB;

PROMPT ===== Confirm Current Container =====
SHOW CON_NAME;

PROMPT ===== Creating VECTOR_LAB User =====

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM dba_users
    WHERE username = 'VECTOR_LAB';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER vector_lab IDENTIFIED BY "VectorLab_2026"';
        DBMS_OUTPUT.PUT_LINE('User VECTOR_LAB created.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('User VECTOR_LAB already exists. Skipping user creation.');
    END IF;
END;
/

PROMPT ===== Granting Required Privileges =====
GRANT DB_DEVELOPER_ROLE TO vector_lab;
ALTER USER vector_lab QUOTA UNLIMITED ON users;

PROMPT ===== Verifying VECTOR_LAB User =====
COLUMN username FORMAT A20
COLUMN account_status FORMAT A30

SELECT username, account_status
FROM dba_users
WHERE username = 'VECTOR_LAB';

PROMPT ===== Script Completed =====

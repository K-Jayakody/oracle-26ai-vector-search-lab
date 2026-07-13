# Troubleshooting Guide

This document contains common issues encountered during the Oracle AI Database 26ai Vector Search Lab and the steps used to resolve them.

---

## 1. Enabling X11 Forwarding

### Issue

The Oracle Database graphical installer does not open when running `./runInstaller`.

This usually happens when X11 forwarding is not enabled or when the local client does not support X11 graphical applications.

---

### Cause

The Oracle installer is a graphical application. If you are connecting to the Linux server remotely through SSH, the server must allow X11 forwarding and your local machine must have an X11-compatible client.

For example, on Windows, you can use tools such as:

- MobaXterm

MobaXterm is commonly used because it has built-in X11 server support.

---

### Solution

Edit the SSH daemon configuration file as the `root` user.

```bash
vi /etc/ssh/sshd_config
```

Add or confirm the following setting:

```text
X11Forwarding yes
```

Restart the SSH service.

```bash
systemctl restart sshd
```

Install the X11 authentication package.

```bash
dnf install -y xorg-x11-xauth
```

If you still face missing GUI library issues, you can install additional X11 packages.

```bash
dnf install -y xorg*
```

> Note: Installing `xorg*` may install many packages. For a minimal setup, start with `xorg-x11-xauth`.

Log out from the server and log back in directly as the oracle user (or the user you are setting up the software as).

Then test whether X11 forwarding works.

```bash
xclock
```

If the clock window opens on your local machine, X11 forwarding is working.

---

## 2. Prerequisite Checks Fail with Swap Warning

### Issue

During Oracle Database installation, the prerequisite checks may show a warning related to swap size.

---

### Cause

Oracle Universal Installer checks whether the server meets the recommended memory and swap requirements.

A swap warning can appear if the configured swap space is below the recommended value for the server's memory size or Oracle Database installation profile.

---

### Ignore the Warning

If this is a lab or test environment and the server has enough physical memory, you may choose to ignore the swap warning and continue.

This is acceptable for a controlled learning environment, but it is not recommended for production systems without proper validation.

---

## 4. HNSW Vector Index Test Fails with ORA-51962

### Issue

The HNSW vector index creation fails with the following error:

```text
ORA-51962: The vector memory area is out of space for the current container.
```

---

### Cause

HNSW vector indexes use the Oracle Vector Pool.

The Vector Pool is a memory area in the SGA used for HNSW vector indexes and related metadata.

If the current container does not have enough vector memory available, Oracle returns `ORA-51962`.

---

### Solution

Connect as a privileged user.

```bash
sqlplus / as sysdba
```

Switch to the project PDB.

```sql
ALTER SESSION SET CONTAINER = KBPDB;
```

Check the current vector memory setting.

```sql
SHOW PARAMETER vector_memory_size;
```

Set the vector memory size.

```sql
ALTER SYSTEM SET vector_memory_size = 500M SCOPE = SPFILE;
```

Restart the database so the SPFILE change takes effect.

From SQL*Plus:

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

Open the PDB again if required.

```sql
ALTER PLUGGABLE DATABASE KBPDB OPEN;
ALTER PLUGGABLE DATABASE KBPDB SAVE STATE;
```

Switch back to the PDB and verify the value.

```sql
ALTER SESSION SET CONTAINER = KBPDB;

SHOW PARAMETER vector_memory_size;
```

Run the HNSW vector index creation again as `VECTOR_LAB`.

```sql
CREATE VECTOR INDEX support_notes_hnsw_idx
ON support_notes (embedding)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE
WITH TARGET ACCURACY 95;
```

## 5. HNSW Index Already Exists

### Issue

When re-running the HNSW index script, the following error may occur:

```text
ORA-00955: name is already used by an existing object
```

---

### Cause

The HNSW vector index was already created in a previous test.

---

### Solution

Drop the existing index and create it again.

```sql
DROP INDEX support_notes_hnsw_idx;
```

Then re-run the index creation script.

```bash
sqlplus vector_lab/VectorLab_2026@KBPDB @sql/05_hnsw_vector_index.sql
```

---

## 6. Cannot Connect to KBPDB Using TNS Alias

### Issue

The following connection fails:

```bash
sqlplus vector_lab/VectorLab_2026@KBPDB
```

---

### Possible Causes

1. The listener is not running.
2. The `KBPDB` service is not registered with the listener.
3. The `tnsnames.ora` entry is incorrect.
4. The PDB is not open.
5. `ORACLE_HOME` or `TNS_ADMIN` is not set correctly.

---

### Solution

Check listener status.

```bash
lsnrctl status
```

Check the PDB open mode.

```bash
sqlplus / as sysdba
```

```sql
SHOW PDBS;
```

If `KBPDB` is mounted but not open, run:

```sql
ALTER PLUGGABLE DATABASE KBPDB OPEN;
ALTER PLUGGABLE DATABASE KBPDB SAVE STATE;
```

Check the service name from the database.

```sql
ALTER SESSION SET CONTAINER = KBPDB;

SHOW PARAMETER service_names;
```

Test the TNS alias.

```bash
tnsping KBPDB
```

Confirm that `tnsnames.ora` contains the correct entry.

```text
KBPDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = KBPDB)
    )
  )
```

---

## 7. VECTOR_LAB User Cannot Create Table

### Issue

The `VECTOR_LAB` user fails when creating the `support_notes` table.

Possible errors include:

```text
ORA-01031: insufficient privileges
```

or:

```text
ORA-01950: no privileges on tablespace 'USERS'
```

---

### Cause

The user may not have the required developer privileges or quota on the `USERS` tablespace.

---

### Solution

Connect as a privileged user inside the `KBPDB` PDB.

```bash
sqlplus / as sysdba
```

```sql
ALTER SESSION SET CONTAINER = KBPDB;
```

Grant the required role and quota.

```sql
GRANT DB_DEVELOPER_ROLE TO vector_lab;

ALTER USER vector_lab QUOTA UNLIMITED ON users;
```

If `DB_DEVELOPER_ROLE` is not available, use these basic privileges:

```sql
GRANT CREATE SESSION TO vector_lab;
GRANT CREATE TABLE TO vector_lab;
GRANT CREATE VIEW TO vector_lab;
GRANT CREATE PROCEDURE TO vector_lab;

ALTER USER vector_lab QUOTA UNLIMITED ON users;
```

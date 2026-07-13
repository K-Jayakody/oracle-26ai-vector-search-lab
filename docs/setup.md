# Oracle AI Database 26ai Vector Search Lab

## Project Overview

This project is a beginner-friendly hands-on lab for testing **Oracle AI Vector Search** in Oracle AI Database 26ai.

The goal of this lab is to show how Oracle Database can store vector data, compare vectors, and return the most similar records using SQL.


---

## What You Will Build

In this lab, you will create a small technical knowledge base table called `support_notes`.

Each support note contains:

- A title
- A category
- A short technical note
- A vector embedding

The vector embedding is stored directly inside Oracle Database using the `VECTOR` data type.

You will then run similarity searches such as:

> "Find records that are closest to a backup/recovery issue."

Instead of searching by exact keywords, Oracle compares the numeric vectors and returns the closest matching records.

---

## What Is a Vector?

A vector is simply a list of numbers.

Example:

```text
[0.95, 0.05, 0.05, 0.10, 0.05]
```

In real AI applications, these numbers are usually created by an embedding model. The model reads text, images, audio, or other data and converts the meaning of that data into numbers.

In this beginner lab, we manually create small 5-number vectors so that the concept is easy to understand.

---

## What Do the 5 Vector Dimensions Mean?

For this lab, each vector has 5 dimensions.

Each dimension represents a simplified topic score.

| Dimension | Meaning |
|---|---|
| 1 | Backup / Recovery |
| 2 | Network / Listener |
| 3 | Performance |
| 4 | Security |
| 5 | Installation / Configuration |

Example:

```text
[0.95, 0.05, 0.05, 0.10, 0.05]
```

This means the record is mostly related to **Backup / Recovery** because the first value is the highest.

Another example:

```text
[0.05, 0.95, 0.05, 0.05, 0.05]
```

This means the record is mostly related to **Network / Listener** because the second value is the highest.

> Important: These are simplified manual vectors for learning. In a real semantic search system, vectors should be generated using an embedding model.

---

## What Is Vector Search?

Traditional search usually depends on words.

For example, a keyword search for `listener` may not find a document that says `database connectivity problem` unless the exact word exists.

Vector search works differently. It compares the meaning or closeness of records by comparing their vector values.

In this lab, Oracle calculates the distance between:

- The vector stored in the table
- The query vector provided in the SQL statement

The smaller the distance, the closer the match.

---

## What Is Cosine Distance?

This lab uses `COSINE` distance.

Cosine distance compares the direction of two vectors. It is commonly used in similarity search because it helps compare how closely two vectors point toward the same meaning.

In the query result:

- A smaller cosine distance means a closer match.
- The closest records appear first because the query orders by `VECTOR_DISTANCE`.

---

## Lab Environment

| Item | Value |
|---|---|
| Operating System | Oracle Linux 9 |
| Database | Oracle AI Database 26ai |
| Software Version Used | 23.26.1.0.0 |
| Architecture | Single-instance database |
| Container Database | Enabled |
| CDB Name | ORCL |
| PDB Name | KBPDB |
| Lab Schema | VECTOR_LAB |

---

# Phase 1: Install Oracle AI Database 26ai

> If Oracle AI Database 26ai is already installed, you can skip this phase and continue from Phase 2.

## 1.1 Run the Preinstall Package as the root User

Run the following as `root`.

```bash
dnf install oracle-ai-database-preinstall-26ai
```

The Oracle AI Database preinstallation RPM installs required packages and performs system configuration needed for Oracle Database installation.

---

## 1.2 Create Necessary Groups and Users

> Run this only if the groups and user do not already exist.

```bash
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
groupadd -g 54324 backupdba
groupadd -g 54325 dgdba
groupadd -g 54326 kmdba
groupadd -g 54327 asmdba
groupadd -g 54330 racdba

useradd -u 54321 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba oracle

passwd oracle
```

---

## 1.3 Create Directories for Oracle Database Files

Run as `root`.

```bash
mkdir -p /u01/app/oracle/oradata
chown oracle:oinstall /u01/app/oracle/oradata
chmod 775 /u01/app/oracle/oradata

mkdir -p /u01/app/oracle/fast_recovery_area
chown oracle:oinstall /u01/app/oracle/fast_recovery_area
chmod 775 /u01/app/oracle/fast_recovery_area
```

---

## 1.4 Prepare Oracle Base and Inventory Directories

Run as `root`.

```bash
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oraInventory

chown -R oracle:oinstall /u01
chmod -R 775 /u01/app
```

---

## 1.5 Extract the Oracle AI Database Software

Download the Oracle AI Database 26ai software from a credible source such as Oracle Software Delivery Cloud.

Run the following as the `oracle` user.

```bash
mkdir -p /u01/app/oracle/product/23.0.0/dbhome_1
cd /u01/app/oracle/product/23.0.0/dbhome_1

unzip -q /u01/soft/V1054592-01.zip
```

> Change `/u01/soft/V1054592-01.zip` based on the actual software file path in your server.

---

## 1.6 Install Oracle AI Database Software Using the Wizard

Run as the `oracle` user.

```bash
cd /u01/app/oracle/product/23.0.0/dbhome_1
./runInstaller
```

Use the following wizard choices:

1. From **Select Configuration Option**, select **Set Up Software Only**.
2. From **Select Database Installation Option**, select **Single instance database installation**.
3. From **Specify Installation Location**, provide the Oracle base path.

   ```text
   /u01/app/oracle
   ```

4. From **Create Inventory**, select the inventory directory.

   ```text
   /u01/app/oraInventory
   ```

5. From **Privileged Operating System Groups**, keep the default values.
6. From **Root Script Configuration**, choose whether to run root scripts manually or automatically.
7. Wait until prerequisite checks complete successfully.
8. Install the software.
9. Run the required `root.sh` scripts when prompted.

---

## 1.7 Create the Oracle AI Database Using DBCA

Run as the `oracle` user.

```bash
cd /u01/app/oracle/product/23.0.0/dbhome_1/bin
./dbca
```

Use the following DBCA choices:

1. From **Select Database Operation**, select **Create a database**.
2. From **Select Database Creation Mode**, select **Typical configuration**.
3. Provide the following values:

| Field | Value |
|---|---|
| CDB Name | ORCL |
| PDB Name | KBPDB |
| Architecture | Single instance |

---

## 1.8 Start and Check the Listener

Run as the `oracle` user.

```bash
lsnrctl start
lsnrctl status
```

---

# Phase 2: Open and Save the PDB State

Connect as `SYSDBA`.

```bash
sqlplus / as sysdba
```

Check the PDBs.

```sql
SHOW PDBS;
```

Open the project PDB and save its state.

```sql
ALTER PLUGGABLE DATABASE KBPDB OPEN;
ALTER PLUGGABLE DATABASE KBPDB SAVE STATE;
```

Switch to the PDB.

```sql
ALTER SESSION SET CONTAINER=KBPDB;
```

Verify the current container.

```sql
SHOW CON_NAME;
```

---

# Phase 3: Create a Dedicated Lab User

Run this inside the `KBPDB` pluggable database as a privileged user.

```sql
CREATE USER vector_lab IDENTIFIED BY "VectorLab_2026";

GRANT DB_DEVELOPER_ROLE TO vector_lab;

ALTER USER vector_lab QUOTA UNLIMITED ON users;
```

Verify the user.

```sql
SELECT username, account_status
FROM dba_users
WHERE username = 'VECTOR_LAB';
```

You can also run the provided:

```bash
sqlplus / as sysdba @sql/01_open_pdb_and_create_user.sql
```

---

# Phase 4: Connect as the Lab User

## 4.1 Create TNS Entries for the CDB and PDB

Go to the Oracle network configuration directory.

```bash
cd /u01/app/oracle/product/23.0.0/dbhome_1/network/admin
vi tnsnames.ora
```

Add the following entries.

```text
ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCL)
    )
  )

KBPDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = KBPDB)
    )
  )
```

Test the TNS alias.

```bash
tnsping KBPDB
```

---

## 4.2 Connect to the PDB as the New Lab User

```bash
sqlplus vector_lab/VectorLab_2026@KBPDB
```

Confirm the connected user.

```sql
SHOW USER;
```

Expected output:

```text
USER is "VECTOR_LAB"
```

---

# Phase 5: Create a Table Using the VECTOR Data Type

Run this as `VECTOR_LAB` or create them manually by running the commands provided within the script.

```bash
sqlplus vector_lab/VectorLab_2026@KBPDB @sql/02_create_vector_table.sql
```

The main table is:

```sql
CREATE TABLE support_notes (
    note_id      NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title        VARCHAR2(200) NOT NULL,
    category     VARCHAR2(50),
    note_text    VARCHAR2(4000),
    embedding    VECTOR(5, FLOAT32),
    created_at   TIMESTAMP DEFAULT SYSTIMESTAMP
);
```

## Explanation: `VECTOR(5, FLOAT32)`

```sql
embedding VECTOR(5, FLOAT32)
```

This means:

- `embedding` is the column name.
- `VECTOR` is the Oracle data type used to store a vector.
- `5` means each vector must contain exactly 5 numbers.
- `FLOAT32` means each number is stored as a 32-bit floating-point value.

In this lab, the 5 numbers represent simplified topic scores.

Verify the table.

```sql
DESC support_notes;
```

---

# Phase 6: Insert Sample Records with Vector Embeddings

Run this as `VECTOR_LAB` or create them manually by running the commands provided within the script.

```bash
sqlplus vector_lab/VectorLab_2026@KBPDB @sql/03_insert_sample_vectors.sql
```

Example insert:

```sql
INSERT INTO support_notes (title, category, note_text, embedding)
VALUES (
    'RMAN backup failure during nightly backup',
    'Backup',
    'RMAN backup failed because the archive log destination was full. Cleared old logs and re-ran the backup successfully.',
    TO_VECTOR('[0.95, 0.05, 0.05, 0.10, 0.05]', 5, FLOAT32)
);
```

## Explanation: `TO_VECTOR`

`TO_VECTOR` converts a text representation of a vector into Oracle's actual `VECTOR` data type.

This part:

```sql
TO_VECTOR('[0.95, 0.05, 0.05, 0.10, 0.05]', 5, FLOAT32)
```

means:

- Convert the text `[0.95, 0.05, 0.05, 0.10, 0.05]` into a vector.
- The vector has 5 dimensions.
- Store the values using `FLOAT32`.

Verify the inserted records.

```sql
SELECT note_id, title, category
FROM support_notes
ORDER BY note_id;
```

---

# Phase 7: Run a Basic Vector Similarity Search

Run this as `VECTOR_LAB` or create them manually by running the commands provided within the script.

```bash
sqlplus vector_lab/VectorLab_2026@KBPDB @sql/04_vector_similarity_queries.sql
```

The backup/recovery query vector is:

```text
[0.90, 0.10, 0.05, 0.10, 0.05]
```

This vector has the highest value in the first position, so it represents a backup/recovery issue.

Main query:

```sql
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
```

## Explanation: `VECTOR_DISTANCE`

`VECTOR_DISTANCE` compares two vectors and returns a distance score.

In this query, Oracle compares:

1. The stored vector in the `embedding` column.
2. The query vector representing a backup/recovery issue.

The result is ordered by `cosine_distance`.

```sql
ORDER BY cosine_distance
```

The smallest distance appears first. That means the closest match appears first.

Expected result:

```text
RMAN backup failure during nightly backup
Archive log destination error in Data Guard setup
User account locked due to failed login attempts
```

The first two results should be backup-related because their vectors are closest to the backup query vector.

---

# Phase 8: Combine Vector Search with Relational Filtering

This query searches for records similar to a backup-related vector, but only inside the `Backup` category.

```sql
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
```

## Why This Is Useful

This shows that vector search does not replace normal SQL.

Instead, vector search works together with normal relational database features such as:

- `WHERE` filters
- `ORDER BY`
- `FETCH FIRST`
- Table columns
- Indexes
- Security
- Application queries

This is one of the main benefits of using vector search inside Oracle Database.

---

# Phase 9: Test Another Query Vector

This query vector represents a network/listener connectivity issue.

```text
[0.05, 0.95, 0.05, 0.05, 0.05]
```

The second value is the highest, so it represents the `Network / Listener` dimension.

Query:

```sql
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
```

Expected result:

The listener/network-related record should appear first.

---

# Phase 10: View Stored Vector Values

```sql
SELECT
    note_id,
    title,
    FROM_VECTOR(embedding) AS vector_value
FROM support_notes
ORDER BY note_id;
```

## Explanation: `FROM_VECTOR`

`FROM_VECTOR` converts a stored Oracle vector value back into readable text.

This is helpful for learning and validation because you can see the numeric vector values stored in the table.

---

# Phase 11: HNSW Vector Index Test

Run this as `VECTOR_LAB` or create them manually by running the commands provided within the script.

```bash
sqlplus vector_lab/VectorLab_2026@KBPDB @sql/05_hnsw_vector_index.sql
```

Create the HNSW vector index.

```sql
CREATE VECTOR INDEX support_notes_hnsw_idx
ON support_notes (embedding)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE
WITH TARGET ACCURACY 95;
```

## What Is HNSW?

HNSW stands for **Hierarchical Navigable Small World**.

In simple terms, it creates a graph-like structure that helps Oracle find similar vectors faster.

Without a vector index, Oracle can compare the query vector against every row.

With an HNSW index, Oracle can search through a graph of nearby vectors and find close matches more efficiently.

## Exact Search vs Approximate Search

A normal vector search can calculate exact distances, but this can become expensive when there are many rows.

An HNSW vector index is used for approximate search. Approximate search usually gives very close results faster, but it may trade a small amount of accuracy for performance.

In this small lab table, performance improvement will not be noticeable because there are only a few rows. The purpose here is to demonstrate the syntax and concept.

## Vector Pool Memory Note

Vector index creation may require Vector Pool memory to be configured in the database.

Check the current setting as a privileged user:

```sql
SHOW PARAMETER vector_memory_size;
```

If index creation fails due to memory configuration, the solution is included within troubleshooting notes.

Verify the index.

```sql
SELECT index_name, index_type, index_subtype, status
FROM user_indexes
WHERE index_name = 'SUPPORT_NOTES_HNSW_IDX';
```

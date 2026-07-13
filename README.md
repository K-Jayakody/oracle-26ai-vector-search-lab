# Oracle AI Database 26ai Vector Search Lab

## Overview

This repository contains a beginner-friendly hands-on lab for testing **Oracle AI Vector Search** in Oracle AI Database 26ai.

The purpose of this lab is to demonstrate how Oracle Database can store vector embeddings, compare vectors, and return similar records using SQL. The lab uses a simple technical support knowledge base table called `support_notes`.

This project is designed for entry-level users who want to understand the basics of vector search inside Oracle Database.

---

## What I Tested

In this lab, I tested Oracle AI Database 26ai Vector Search by:

1. Creating a dedicated pluggable database user.
2. Creating a table with a native `VECTOR` column.
3. Inserting sample support/documentation records with manually created vector embeddings.
4. Running similarity searches using `VECTOR_DISTANCE`.
5. Combining vector search with normal SQL filtering.
6. Creating an HNSW vector index for approximate similarity search.

---

## Lab Environment

| Item | Value |
|---|---|
| Operating System | Oracle Linux 9 |
| Database | Oracle AI Database 26ai |
| Database Version Used | 23.26.1.0.0 |
| Architecture | Single-instance database |
| CDB Name | ORCL |
| PDB Name | KBPDB |
| Lab Schema | VECTOR_LAB |

---

## Repository Structure

```text
oracle-26ai-vector-search-lab/
├── README.md 
├── sql/
│   ├── 01_open_pdb_and_create_user.sql
│   ├── 02_create_vector_table.sql
│   ├── 03_insert_sample_vectors.sql
│   ├── 04_vector_similarity_queries.sql
│   └── 05_hnsw_vector_index.sql
├── docs/
│   ├── setup.md
│   ├── learning-notes.md
│   └── troubleshooting.md
└── screenshots/
    ├── runInstaller/
	│	├── 1_configuration_opiton.png
	│	├── 2_database_installation_option.png
	│	├── 3_installation_location.png
	│	├── 4_os_groups.png
	│	├── 5_root_script_configuration.png
	│	├── 6_prerequisite_checks.png
	│	├── 7_summary.png
	│	├── 8_install_product.png
	│	└── 9_finish.png
	├──dbca/
	│	├── 1_database_operation.png
	│	├── 2_database_creation_mode.png
	│	├── 3_summary.png
	│	├── 4_progress_page.png
	│	└── 5_finish.png
    ├── 01_database_version.png
    ├── 02_pdb_open_state.png
    ├── 03_vector_lab_user_created.png
    ├── 04_vector_table_created.png
    ├── 05_similarity_search_backup.png
    ├── 06_similarity_search_network.png
    ├── 07_hnsw_index_created.png
    └── 08_readable_vector_values.png
```

---

## Key Oracle Features Used

### 1. `VECTOR` Data Type

The `VECTOR` data type is used to store vector embeddings directly inside an Oracle table.

Example:

```sql
embedding VECTOR(5, FLOAT32)
```

This means:

- `embedding` is the column name.
- `VECTOR` is the data type.
- `5` means the vector must contain 5 values.
- `FLOAT32` means each value is stored as a 32-bit floating-point number.

---

### 2. `TO_VECTOR`

`TO_VECTOR` converts a text representation of a vector into Oracle's `VECTOR` data type.

Example:

```sql
TO_VECTOR('[0.95, 0.05, 0.05, 0.10, 0.05]', 5, FLOAT32)
```

This is used in the lab when inserting sample vector values.

---

### 3. `VECTOR_DISTANCE`

`VECTOR_DISTANCE` compares two vectors and returns a distance score.

Example:

```sql
VECTOR_DISTANCE(
    embedding,
    TO_VECTOR('[0.90, 0.10, 0.05, 0.10, 0.05]', 5, FLOAT32),
    COSINE
)
```

A smaller distance means a closer match.

---

### 4. `FROM_VECTOR`

`FROM_VECTOR` converts a stored Oracle vector value back into readable text.

Example:

```sql
SELECT
    note_id,
    title,
    FROM_VECTOR(embedding) AS vector_value
FROM support_notes
ORDER BY note_id;
```

This is useful for learning and validation because it allows you to view the vector values stored in the table.

---

### 5. HNSW Vector Index

HNSW stands for **Hierarchical Navigable Small World**.

An HNSW vector index helps speed up vector similarity search by creating a graph-based index structure. This is useful when searching through a large number of vectors.

In this lab, the table has only a few records, so the performance difference is not important. The goal is to demonstrate the syntax and understand the concept.

---

## Troubleshooting

Common issues and fixes are documented in:

```text
docs/troubleshooting.md
```

The troubleshooting guide includes fixes for:

- X11 forwarding issues.
- GUI installer issues.
- Swap warnings.
- TNS connection issues.
- User privilege issues.
- `ORA-51962` vector memory errors.

---

## Key Learning Points

1. Oracle Database can store vector embeddings directly inside a table.
2. A vector is a list of numbers that can represent the meaning or features of data.
3. `TO_VECTOR` converts a text representation of numbers into Oracle's `VECTOR` data type.
4. `VECTOR_DISTANCE` compares two vectors and returns a distance score.
5. A smaller vector distance means a closer match.
6. Vector search can be combined with normal SQL filtering.
7. HNSW vector indexes can be used for faster approximate similarity search.
8. In this beginner lab, the vectors were manually created for learning. In a real system, an embedding model should generate them.

---

## Why This Is Useful

Oracle AI Vector Search allows AI-style semantic search to be built directly inside Oracle Database.

Instead of moving application data to a separate vector database, relational data and vector embeddings can be stored and queried together using SQL.

This is useful for search use cases such as:

- Document search
- Knowledge base search
- Support note search
- Recommendation systems
- Retrieval-augmented generation applications
- Similarity matching

---

## Conclusion

This lab demonstrates how Oracle AI Database 26ai can be used to store and search vector embeddings directly using SQL.

The main feature tested was Oracle AI Vector Search, including the `VECTOR` data type, `TO_VECTOR`, `FROM_VECTOR`, `VECTOR_DISTANCE`, and HNSW vector indexing.

This project helped me understand how vector search works inside Oracle Database and how it can be combined with normal relational database features.

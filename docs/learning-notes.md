# Learning Notes

## What I Tested

In this lab, I tested Oracle AI Database 26ai Vector Search by creating a table with a native `VECTOR` column and running similarity searches using SQL.

## Key Learning Points

1. Oracle Database can store vector embeddings directly inside a table.
2. A vector is a list of numbers that can represent the meaning or features of data.
3. `TO_VECTOR` converts a text representation of numbers into Oracle's `VECTOR` data type.
4. `VECTOR_DISTANCE` compares two vectors and returns a distance score.
5. A smaller distance means a closer match.
6. Vector search can be combined with normal SQL filtering.
7. HNSW vector indexes can be used for faster approximate similarity search.
8. In this beginner lab, the vectors were manually created for learning. In a real system, an embedding model should generate them.

## Why This Is Useful

This feature allows AI-style semantic search to be built directly inside Oracle Database. Instead of moving data into a separate vector database, application data and vector embeddings can be stored and queried together using SQL.

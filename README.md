# haskell-postgres

Requirements:
    * Stack
    * Docker
    * Docker Compose

1. Run Container: `docker-compose up -d`

2. Build: `stack build`

3. Run: `stack exec haskell-postgres-exe`

4. Run psql: `docker exec -it ${CONTAINER_ID} psql -U haskell -d haskell_db` 

5. Verify Migrations: `select * from schema_migrations`
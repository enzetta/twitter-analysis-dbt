Welcome to your new dbt project!

### Using the starter project

```bash
# Run Program
dbt run

# full refresh all data
dbt run --full-refresh

# Run specific model
# dbt run --models <filename without the extension> e.g.
dbt run --models interactions_referrer
```







### data selection
- Politicians
- Politically engaged users
  - Mentioned politicians
  - Where Mentioned by politicians
  - Direct interactions with politicians
  - Politicians direcly interacted with user
- Politically connected users
  - all users who used a politically relevant hashtag
  - all users who were mentioned by politically engaged users
  - all users who mentioned politically engaged users
  - all users who directly interacted with politically engaged users
  - all users who were directly interacted with by politically engaged users

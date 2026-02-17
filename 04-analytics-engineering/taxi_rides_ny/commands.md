# dbt Commands Reference

A comprehensive guide to commonly used dbt commands and flags.

---

## Project Setup Commands

### `dbt init`
Initializes a new dbt project by creating the necessary folder structure and configuration files.

**Usage:**
```bash
dbt init my_project_name
```

**What it creates:**
- `dbt_project.yml` - Main project configuration
- `models/` - Directory for SQL models
- `seeds/`, `snapshots/`, `tests/`, `macros/`, `analyses/` - Standard directories
- `README.md` - Project documentation template

**When to use:** Run once at the very beginning when starting a new dbt project.

---

### `dbt debug`
Validates your dbt installation and verifies database connections.

**Usage:**
```bash
dbt debug
```

**What it checks:**
- dbt version
- Python version
- `profiles.yml` configuration
- Database connection credentials
- Adapter installation

**When to use:** 
- After installing dbt for the first time
- When troubleshooting connection issues
- After modifying `profiles.yml`

---

## Data Loading Commands

### `dbt seed`
Loads CSV files from the `seeds/` folder into your data warehouse as tables.

**Usage:**
```bash
dbt seed                    # Load all seed files
dbt seed --select my_seed   # Load a specific seed file
dbt seed --full-refresh     # Drop and recreate all seed tables
```

**When to use:**
- Loading small lookup tables (e.g., country codes, status codes)
- Loading test data for development
- **Not recommended for large datasets** (use ETL tools instead)

---

### `dbt snapshot`
Implements Type 2 Slowly Changing Dimensions (SCD) by tracking historical changes in your data over time.

**Usage:**
```bash
dbt snapshot               # Run all snapshots
dbt snapshot --select my_snapshot
```

**What it does:**
- Takes a "snapshot" of a table at a point in time
- On subsequent runs, detects changes and creates new records with timestamps
- Preserves historical state (e.g., track when a customer changed their address)

**When to use:**
- When you need to track how data changes over time
- Auditing and compliance requirements
- Historical analysis

---

## Compilation & Execution Commands

### `dbt compile`
Compiles Jinja and SQL into pure SQL without running it against the database.

**Usage:**
```bash
dbt compile                    # Compile all models
dbt compile --select my_model  # Compile a specific model
```

**What it does:**
- Resolves all `{{ ref() }}` and `{{ source() }}` references
- Expands Jinja macros
- Outputs compiled SQL to `target/compiled/`

**When to use:**
- Debugging Jinja logic
- Inspecting the final SQL that will be executed
- Faster feedback loop than `dbt run` (doesn't execute against the database)

---

### `dbt run`
Executes all models in your project and materializes them in the database.

**Usage:**
```bash
dbt run                        # Run all models
dbt run --select my_model      # Run a specific model
dbt run --select +my_model     # Run a model and all its ancestors
dbt run --select my_model+     # Run a model and all its descendants
dbt run --exclude my_model     # Run all models except one
```

**What it does:**
- Compiles your models
- Executes the SQL against your database
- Creates tables/views based on your materialization strategy

**When to use:**
- Building or refreshing your data models
- After making changes to your SQL
- In production pipelines (often via `dbt build` instead)

---

### `dbt test`
Runs all data quality tests defined in your project.

**Usage:**
```bash
dbt test                       # Run all tests
dbt test --select my_model     # Run tests for a specific model
dbt test --select source:*     # Run tests on all sources
```

**Types of tests:**
- **Generic tests:** `not_null`, `unique`, `accepted_values`, `relationships`
- **Singular tests:** Custom SQL queries in the `tests/` directory

**When to use:**
- Validating data quality after a run
- In CI/CD pipelines to catch issues before merging
- Ensuring upstream data hasn't changed unexpectedly

---

### `dbt build`
A single command that runs `seed`, `run`, `snapshot`, and `test` in the correct dependency order.

**Usage:**
```bash
dbt build                      # Build everything
dbt build --select my_model+   # Build a model and downstream dependencies
```

**What it does:**
- Automatically determines the correct execution order based on the DAG
- Runs seeds → snapshots → models → tests
- Fails fast if a test fails (won't build downstream models)

**When to use:**
- **Recommended for production pipelines**
- When you want to ensure everything is fresh and tested
- Simpler than chaining `dbt seed`, `dbt run`, `dbt test`

---

## Utilities & Documentation

### `dbt source freshness`
Checks if your source data is stale based on the `loaded_at_field` in your source configuration.

**Usage:**
```bash
dbt source freshness
```

**Requirements:**
You must define `freshness` in your `sources.yml`:
```yaml
sources:
  - name: raw_data
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    loaded_at_field: updated_at
    tables:
      - name: green_tripdata
```

**When to use:**
- Monitoring data pipelines
- Alerting when upstream data hasn't been updated
- As part of a health check in production

---

### `dbt docs generate`
Generates documentation for your dbt project, creating a `catalog.json` file.

**Usage:**
```bash
dbt docs generate
```

**What it creates:**
- `target/manifest.json` - DAG and project metadata
- `target/catalog.json` - Database schema and statistics

**When to use:**
- Before serving the documentation site
- After making changes to models or descriptions

---

### `dbt docs serve`
Launches a local web server to browse your dbt documentation.

**Usage:**
```bash
dbt docs serve              # Default port 8080
dbt docs serve --port 8001  # Custom port
```

**What it shows:**
- Interactive DAG (lineage graph)
- Model descriptions and column-level documentation
- SQL source code
- Test results

**When to use:**
- Exploring your project's structure
- Onboarding new team members
- Understanding data lineage

---

### `dbt clean`
Removes artifacts from previous dbt runs.

**Usage:**
```bash
dbt clean
```

**What it deletes:**
- `target/` directory (compiled SQL, logs)
- `dbt_packages/` directory (installed packages)

**When to use:**
- Troubleshooting caching issues
- Starting fresh before a deployment
- Freeing up disk space

---

### `dbt deps`
Installs packages defined in `packages.yml`.

**Usage:**
```bash
dbt deps
```

**Example `packages.yml`:**
```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```

**When to use:**
- After adding a new package to `packages.yml`
- Setting up a project for the first time
- Similar to `npm install` or `pip install -r requirements.txt`

---

### `dbt retry`
Re-runs only the models that failed in the previous `dbt run` or `dbt build`.

**Usage:**
```bash
dbt build      # Some models fail
dbt retry      # Only re-run the failed ones
```

**When to use:**
- After fixing a bug that caused a model to fail
- Saves time by not re-running successful models

---

## Commonly Used Flags

### `--full-refresh`
Forces dbt to drop and recreate tables, ignoring incremental logic.

**Usage:**
```bash
dbt run --full-refresh
dbt run --select my_incremental_model --full-refresh
```

**When to use:**
- Rebuilding incremental models from scratch
- Fixing data quality issues that require a complete reload
- Testing new incremental logic

---

### `--fail-fast`
Stops execution immediately after the first failure.

**Usage:**
```bash
dbt run --fail-fast
dbt test --fail-fast
```

**When to use:**
- Development, when you want quick feedback
- You don't want to wait for all models to run if one fails

---

### `--target`
Specifies which target environment to use from `profiles.yml`.

**Usage:**
```bash
dbt run --target dev    # Use the 'dev' target
dbt run --target prod   # Use the 'prod' target
```

**When to use:**
- Switching between development and production databases
- Running the same models in different environments

---

### `--select` (Model Selection Syntax)

Powerful syntax for running specific subsets of your project.

**Basic Selection:**
```bash
dbt run --select my_model              # Run a single model
dbt run --select model_a model_b       # Run multiple models
dbt run --select my_folder.*           # Run all models in a folder
dbt run --select tag:daily             # Run all models with the 'daily' tag
```

**Graph Operators:**
```bash
dbt run --select +my_model             # Run my_model and all ancestors (parents)
dbt run --select my_model+             # Run my_model and all descendants (children)
dbt run --select +my_model+            # Run my_model, ancestors, and descendants
dbt run --select my_model+2            # Run my_model and 2 levels of descendants
```

**Advanced Selection:**
```bash
dbt run --select source:raw_data+      # Run all models downstream of a source
dbt run --select @my_model             # Run my_model, its parents, and its children
dbt run --select tag:nightly,models    # Intersection: models tagged 'nightly'
```

**When to use:**
- Running only changed models in CI/CD
- Testing a specific branch of your DAG
- Incremental development workflows

---

### `--exclude`
The opposite of `--select`. Excludes specific models from a run.

**Usage:**
```bash
dbt run --exclude my_model
dbt run --exclude tag:deprecated
```

**When to use:**
- Temporarily skipping slow or broken models
- Running everything except a specific subset

---

## Pro Tips

- **Combine flags:** `dbt build --select +my_model --target prod`
- **Use `dbt ls`** to preview which models will be selected: `dbt ls --select +my_model`
- **Leverage tags** in your models for easy selection:
  ```yaml
  # models/marts/schema.yml
  models:
    - name: fct_orders
      config:
        tags: ['daily', 'finance']
  ```
  Then run: `dbt run --select tag:daily`

---

## Helpful Resources

- [dbt Command Reference](https://docs.getdbt.com/reference/dbt-commands)
- [Model Selection Syntax](https://docs.getdbt.com/reference/node-selection/syntax)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
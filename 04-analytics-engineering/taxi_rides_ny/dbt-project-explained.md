# Understanding a dbt Project Structure

This file explains the purpose of the key files and directories within a standard dbt project.

---

## `dbt_project.yml`

This is the most important file in your dbt project; it's the main configuration file that tells dbt how to operate on your project. Without it, dbt won't recognize the directory as a dbt project.

- **Core Function:** Defines project-level settings, such as the project name, version, and the `profile` to use for database connections (which links to your `~/.dbt/profiles.yml` file).
- **Configuration:** You can configure default materializations (e.g., table, view, incremental), define model paths, and set variables that can be used throughout your project.

**Example:**
```yaml
name: 'my_dbt_project'
version: '1.0.0'
config-version: 2

profile: 'my_dbt_project_profile'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

models:
  my_dbt_project:
    # Default materialization for all models in the project is 'view'
    +materialized: view
    marts:
      # Models in the 'marts' directory will be materialized as 'table'
      +materialized: table
```

---

## `models/`

This is the core directory where all your data transformation logic lives. Each `.sql` file in this directory represents a single model (which corresponds to a table or view in your database). The structure of this folder is critical for a maintainable project.

### `models/staging/`
The first layer of transformation, acting as the entry point for your raw data.

- **Purpose:** To create a clean, consistent, and lightly prepared version of your source data.
- **Structure:** Each model should correspond to exactly one source table (a 1-to-1 mapping).
- **Transformations:** Only light transformations are performed here:
    - Renaming columns (e.g., `userID` to `user_id`).
    - Casting data types (e.g., `varchar` to `timestamp`).
    - Basic cleaning (e.g., standardizing `NULL` values).
- **Rule:** **No joins or aggregations.** This layer is just about cleaning individual source tables.

### `models/intermediate/`
The "work-in-progress" or "workspace" layer. It's where you handle complexity.

- **Purpose:** To combine and transform staging models to create logical building blocks for your final marts. These models are not meant for end-users.
- **Transformations:** This is where the heavy lifting happens:
    - **Joining** different staging models (e.g., joining `stg_orders` with `stg_customers`).
    - Performing complex calculations or business logic.
    - Filtering, pivoting, or unpivoting data.
- **Rule:** These models are built to be reused by downstream models, not queried directly by business users.

### `models/marts/`
The final, user-facing layer. These are the "data products" that your business stakeholders and BI tools will consume.

- **Purpose:** To provide clean, easy-to-understand, and performant tables that are optimized for analytics.
- **Structure:** Often organized into two types of models:
    - **Fact tables (`fct_`):** Contain events or transactions (e.g., `fct_orders`).
    - **Dimension tables (`dim_`):** Contain descriptive attributes about entities (e.g., `dim_customers`).
- **Rule:** These models should be easy to query and understand, with clear, business-friendly column names. They `ref()` intermediate or staging models.

---

## `macros/`

This directory contains reusable pieces of SQL code, similar to functions in a programming language. They are written using Jinja and are essential for writing efficient and clean dbt projects by following the **DRY (Don't Repeat Yourself)** principle.

- **Purpose:** To abstract SQL logic that is used in multiple models.
- **Use Cases:**
    - Converting a price in cents to dollars.
    - Generating dynamic SQL based on the environment (dev vs. prod).
    - Creating custom schema tests.

**Example (`macros/pricing.sql`):**
```sql
{% macro cents_to_dollars(column_name, decimal_places=2) %}
    round( {{ column_name }} / 100, {{ decimal_places }} )
{% endmacro %}
```

---

## `seeds/`

This directory is for loading static, CSV-formatted data into your data warehouse. This data doesn't change often.

- **Purpose:** To manage and version-control small, static datasets.
- **Use Cases:**
    - A list of country codes.
    - A mapping of employee IDs to names.
    - A list of test user IDs to exclude from production models.
- **Command:** Use `dbt seed` to load or update the data from these CSVs into your database.

---

## `tests/`

This directory is for custom data tests that involve writing a specific SQL query.

- **Purpose:** To assert complex data quality rules that can't be expressed with simple, out-of-the-box tests.
- **How it works:** You write a SQL query that should return **zero** rows if the test passes. If the query returns one or more rows, the test fails.
- **Example (`tests/assert_order_amount_is_positive.sql`):**
  ```sql
  -- A test to ensure all order amounts are positive
  select
      order_id,
      amount
  from {{ ref('fct_orders') }}
  where amount < 0
  ```

---

## `snapshots/`

This directory is for tracking changes to a mutable table over time. This is often referred to as "Slowly Changing Dimensions" (SCDs).

- **Purpose:** To capture a historical record of how the values in a table's rows have changed.
- **How it works:** dbt creates a new table that stores a version of your source table's records. When you run `dbt snapshot`, it checks for changes and adds new versions of the changed rows, marking the old ones as no longer current.
- **Use Cases:** Tracking changes in user addresses, product prices, or employee roles.

---

## `analyses/`

This directory is for SQL files that you want dbt to compile but not run as models.

- **Purpose:** For ad-hoc analysis, data exploration, or data quality audits that you want to keep version-controlled but that shouldn't be part of your main data transformation pipeline.
- **Rule:** The SQL in this folder is not executed against your database with `dbt run`. You would typically copy the compiled SQL and run it yourself. Many dbt users do not use this folder extensively.
# Apache Spark Cheat Sheet

## What is Spark?

**Apache Spark** is an open-source, distributed computing framework for large-scale data processing and analytics.

**Key Features:**
- **In-memory processing**: 10-100x faster than Hadoop MapReduce
- **Distributed**: Processes data across multiple nodes in parallel
- **Unified engine**: Supports batch, streaming, SQL, ML, and graph processing
- **Lazy evaluation**: Builds execution plan before running
- **Fault tolerant**: Automatically recovers from node failures

## Why Use Spark in Data Engineering?

| Use Case | Description |
|----------|-------------|
| **ETL at Scale** | Transform terabytes of data efficiently |
| **Data Cleaning** | Handle messy data with distributed processing |
| **Data Lake Processing** | Query and transform raw data in cloud storage |
| **Batch Analytics** | Run scheduled analytics jobs on large datasets |
| **Data Warehousing** | Load and transform data for warehouses |
| **Log Processing** | Analyze massive log files |

**When to use Spark:**
- Datasets larger than single machine memory (100+ GB)
- Complex transformations requiring iterative processing
- Need for both batch and streaming in one framework
- Working with Parquet, ORC, JSON, CSV at scale

---

## Setup (Windows)

### Environment Configuration
```python
import os
os.environ['JAVA_HOME'] = r'C:\tools\jdk-17.0.18+8'
os.environ['HADOOP_HOME'] = r'C:\tools\hadoop'
os.environ['PATH'] = r'C:\tools\hadoop\bin;' + os.environ['JAVA_HOME'] + r'\bin;' + os.environ.get('PATH', '')

import pyspark
from pyspark.sql import SparkSession
```

### Create Spark Session
```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('my_app') \
    .getOrCreate()
```

**Parameters:**
- `master("local[*]")` - Run locally using all CPU cores
- `appName()` - Name for the application

---

## Reading Data

### CSV Files
```python
# Basic read
df = spark.read \
    .option("header", "true") \
    .csv('file.csv')

# With schema (recommended for production)
from pyspark.sql import types

schema = types.StructType([
    types.StructField('column1', types.StringType(), True),
    types.StructField('column2', types.IntegerType(), True),
    types.StructField('column3', types.TimestampType(), True)
])

df = spark.read \
    .option("header", "true") \
    .schema(schema) \
    .csv('file.csv')

# Read compressed files (Spark handles decompression)
df = spark.read \
    .option("header", "true") \
    .csv('file.csv.gz')
```

### Parquet Files (Recommended Format)
```python
# Read parquet (schema included automatically)
df = spark.read.parquet('file.parquet')

# Read directory of parquet files
df = spark.read.parquet('data/year=2021/month=01/')
```

### JSON Files
```python
df = spark.read.json('file.json')
```

---

## Writing Data

### Parquet (Best Practice)
```python
# Write to parquet
df.write.parquet('output_dir/')

# With mode
df.write.mode('overwrite').parquet('output_dir/')

# With partitioning (for large datasets)
df.write.partitionBy('year', 'month').parquet('output_dir/')

# With repartitioning (control file count)
df.repartition(24).write.parquet('output_dir/')
```

**Write Modes:**
- `'overwrite'` - Replace existing data
- `'append'` - Add to existing data
- `'ignore'` - Skip if exists
- `'error'` - Fail if exists (default)

### CSV
```python
df.write.csv('output_dir/', header=True, mode='overwrite')

# Single file output
df.coalesce(1).write.csv('output_dir/', header=True)
```

---

## Data Types

```python
from pyspark.sql import types

types.StringType()      # Text
types.IntegerType()     # 4 bytes integer
types.LongType()        # 8 bytes integer
types.DoubleType()      # Floating point
types.TimestampType()   # Date and time
types.DateType()        # Date only
types.BooleanType()     # True/False
```

---

## Inspecting DataFrames

### Schema and Structure
```python
# View schema
df.printSchema()

# Get schema object
df.schema

# Column names
df.columns

# Row count (ACTION - triggers execution)
df.count()

# DataFrame dimensions
print(f"Rows: {df.count()}, Columns: {len(df.columns)}")
```

### Preview Data
```python
# Show first 20 rows (default)
df.show()

# Show n rows
df.show(10)

# Don't truncate long strings
df.show(5, truncate=False)

# Vertical format (good for wide tables)
df.show(5, vertical=True)

# Convert to pandas for pretty display (SMALL DATA ONLY!)
df.limit(10).toPandas()
```

---

## Selecting and Filtering

### Select Columns
```python
# Select specific columns
df.select('col1', 'col2', 'col3')

# Using column objects
from pyspark.sql import functions as F
df.select(F.col('col1'), F.col('col2'))

# Select with expressions
df.select('col1', (F.col('col2') * 2).alias('col2_doubled'))
```

### Filter Rows
```python
# Filter with condition
df.filter(df.age > 25)

# Multiple conditions
df.filter((df.age > 25) & (df.city == 'NYC'))

# Using SQL-like where
df.where(df.age > 25)

# Filter with column in list
df.filter(df.status.isin(['active', 'pending']))
```

---

## Transformations (Common)

### Add/Modify Columns
```python
from pyspark.sql import functions as F

# Add new column
df = df.withColumn('new_col', F.lit('constant_value'))

# Modify existing column
df = df.withColumn('price', F.col('price') * 1.1)

# Date operations
df = df.withColumn('pickup_date', F.to_date(df.pickup_datetime))
df = df.withColumn('year', F.year(df.date_column))
df = df.withColumn('month', F.month(df.date_column))

# String operations
df = df.withColumn('upper_name', F.upper(df.name))
df = df.withColumn('substring', F.substring(df.text, 1, 5))

# Type casting
df = df.withColumn('id', F.col('id').cast('integer'))
```

### Drop Columns
```python
# Drop single column
df = df.drop('column_name')

# Drop multiple columns
df = df.drop('col1', 'col2', 'col3')
```

### Rename Columns
```python
# Rename one column
df = df.withColumnRenamed('old_name', 'new_name')
```

### Repartition (Control Parallelism)
```python
# Repartition to 24 partitions (good for writing)
df = df.repartition(24)

# Repartition by column (for partitioned writes)
df = df.repartition('year', 'month')

# Coalesce (reduce partitions without shuffle - faster)
df = df.coalesce(1)  # Single file output
```

---

## Aggregations and GroupBy

```python
from pyspark.sql import functions as F

# Group and count
df.groupBy('category').count()

# Multiple aggregations
df.groupBy('category').agg(
    F.count('*').alias('count'),
    F.avg('price').alias('avg_price'),
    F.sum('revenue').alias('total_revenue'),
    F.max('date').alias('latest_date')
)

# Common aggregate functions
F.count()
F.sum()
F.avg()
F.min()
F.max()
F.first()
F.last()
F.countDistinct()
```

---

## User Defined Functions (UDFs)

```python
from pyspark.sql import functions as F
from pyspark.sql import types

# Define Python function
def custom_logic(value):
    if value % 7 == 0:
        return 'divisible_by_7'
    else:
        return 'not_divisible'

# Register as UDF
custom_udf = F.udf(custom_logic, returnType=types.StringType())

# Use in DataFrame
df = df.withColumn('result', custom_udf(df.number_column))
```

**Note:** UDFs are slower than built-in functions. Use built-in functions when possible!

---

## Lazy vs Eager Evaluation

### Transformations (Lazy - Not Executed Immediately)

These build an execution plan but don't run until an action is called:

```python
df.select()          # Select columns
df.filter()          # Filter rows
df.where()           # Same as filter
df.withColumn()      # Add/modify column
df.drop()            # Drop column
df.groupBy()         # Group data
df.join()            # Join DataFrames
df.repartition()     # Change partitions
df.orderBy()         # Sort data
df.distinct()        # Remove duplicates
df.limit()           # Limit rows
```

### Actions (Eager - Execute Immediately)

These trigger computation of the entire execution plan:

```python
df.show()            # Display data
df.count()           # Count rows
df.collect()         # Return all data to driver (DANGEROUS for large data!)
df.take(n)           # Return first n rows to driver
df.first()           # Return first row
df.head(n)           # Same as take(n)
df.toPandas()        # Convert to pandas DataFrame
df.write.parquet()   # Write to storage
df.write.csv()       # Write to CSV
```

**Why it matters:**
- Lazy evaluation allows Spark to optimize the entire query before execution
- Multiple transformations are combined into a single execution plan
- Only computed data that's actually needed

**Example:**
```python
# None of these execute yet (all lazy)
df2 = df.filter(df.age > 25)
df3 = df2.select('name', 'age')
df4 = df3.withColumn('age_plus_10', df3.age + 10)

# This triggers execution of the entire plan
df4.show()  # ACTION - now everything runs
```

---

## Converting Between Pandas and Spark

### Pandas → Spark
```python
import pandas as pd

pandas_df = pd.read_csv('file.csv')

# Convert to Spark DataFrame
spark_df = spark.createDataFrame(pandas_df)

# With explicit schema
spark_df = spark.createDataFrame(pandas_df, schema=schema)
```

### Spark → Pandas
```python
# Convert to pandas (USE WITH CAUTION - loads all data to driver memory!)
pandas_df = spark_df.toPandas()

# SAFE: Only convert small samples
pandas_df = spark_df.limit(1000).toPandas()
pandas_df = spark_df.sample(0.01).toPandas()  # 1% sample
```

**⚠️ Warning:** `.toPandas()` loads all data into single machine memory. Only use on small DataFrames or samples!

---

## SQL Queries

```python
# Register DataFrame as temporary view
df.createOrReplaceTempView('my_table')

# Run SQL query
result = spark.sql("""
    SELECT category, COUNT(*) as count, AVG(price) as avg_price
    FROM my_table
    WHERE date >= '2021-01-01'
    GROUP BY category
    ORDER BY count DESC
""")

result.show()
```

---

## Common Patterns

### Chaining Operations
```python
from pyspark.sql import functions as F

result = df \
    .filter(df.status == 'active') \
    .withColumn('price_usd', df.price * 1.1) \
    .groupBy('category') \
    .agg(F.avg('price_usd').alias('avg_price')) \
    .orderBy(F.desc('avg_price')) \
    .limit(10)

result.show()
```

### Reading Multiple Files
```python
# Read all CSVs in a directory
df = spark.read.csv('data/*.csv', header=True)

# Read with wildcards
df = spark.read.csv('data/2021/*/sales.csv', header=True)

# Read multiple specific files
df = spark.read.csv(['file1.csv', 'file2.csv', 'file3.csv'], header=True)
```

---

## Performance Tips

1. **Use Parquet format**: Columnar, compressed, includes schema
2. **Partition large datasets**: By date, region, or frequently filtered columns
3. **Cache when reusing data**: `df.cache()` or `df.persist()`
4. **Avoid UDFs**: Use built-in functions when possible
5. **Use appropriate data types**: Smaller types = less memory
6. **Repartition before writing**: Control output file count
7. **Filter early**: Push filters close to data source
8. **Avoid `.collect()` and `.toPandas()` on large data**: Crashes driver

---

## Stop Spark Session

```python
# Stop when done
spark.stop()
```

---

## Common File Formats Comparison

| Format | Schema | Compression | Speed | Use Case |
|--------|--------|-------------|-------|----------|
| **Parquet** | ✓ Built-in | ✓ Excellent | ⚡ Very Fast | **Best for analytics** |
| **CSV** | ✗ Manual | ✗ Poor | 🐌 Slow | Human-readable, small data |
| **JSON** | ✗ Inferred | ✗ Poor | 🐌 Slow | Semi-structured data |
| **ORC** | ✓ Built-in | ✓ Excellent | ⚡ Very Fast | Hive integration |

**Recommendation for Data Engineering:** Use **Parquet** for everything except human-readable exports.

---

## Quick Reference

```python
# Setup
spark = SparkSession.builder.master("local[*]").appName('app').getOrCreate()

# Read
df = spark.read.parquet('data.parquet')
df = spark.read.option("header", "true").csv('data.csv')

# Inspect
df.show(10)
df.printSchema()
df.count()

# Transform
df.select('col1', 'col2')
df.filter(df.col1 > 100)
df.withColumn('new_col', F.col('old_col') * 2)
df.groupBy('category').count()

# Write
df.write.mode('overwrite').parquet('output/')

# Stop
spark.stop()
```

---

## Useful Links

- [Official PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)
- [Spark SQL Functions](https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql/functions.html)
- [DataFrames Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)

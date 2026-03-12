# DataFrame Transformations Cheat Sheet

A comprehensive guide to data transformations using Pandas and PySpark DataFrames, including when Python is better than SQL.

---

## Table of Contents
- [Pandas Transformations](#pandas-transformations)
- [PySpark Transformations](#pyspark-transformations)
- [When Python > SQL](#when-python--sql)
- [Common Patterns](#common-patterns)

---

## Pandas Transformations

### Selecting & Filtering

```python
import pandas as pd

# Select columns
df[['col1', 'col2']]
df.loc[:, ['col1', 'col2']]

# Filter rows
df[df['age'] > 25]
df[df['age'].between(18, 65)]
df[(df['age'] > 25) & (df['city'] == 'NYC')]
df[df['status'].isin(['active', 'pending'])]

# Select with conditions
df.loc[df['age'] > 25, ['name', 'age']]

# Query syntax (SQL-like)
df.query('age > 25 and city == "NYC"')
```

### Adding/Modifying Columns

```python
# Add new column
df['new_col'] = 'constant'
df['total'] = df['price'] * df['quantity']

# Apply function to column
df['upper_name'] = df['name'].str.upper()
df['age_category'] = df['age'].apply(lambda x: 'young' if x < 30 else 'old')

# Conditional column
df['status'] = df['score'].apply(
    lambda x: 'pass' if x >= 60 else 'fail'
)

# Using numpy for conditions
import numpy as np
df['category'] = np.where(df['value'] > 100, 'high', 'low')

# Multiple conditions
df['tier'] = np.select(
    [df['score'] >= 90, df['score'] >= 70, df['score'] >= 50],
    ['A', 'B', 'C'],
    default='F'
)
```

### Grouping & Aggregation

```python
# Simple group by
df.groupby('category')['sales'].sum()
df.groupby('category').size()

# Multiple aggregations
df.groupby('category').agg({
    'sales': ['sum', 'mean', 'count'],
    'profit': 'sum',
    'date': ['min', 'max']
})

# Named aggregations (better!)
df.groupby('category').agg(
    total_sales=('sales', 'sum'),
    avg_sales=('sales', 'mean'),
    count=('sales', 'count'),
    total_profit=('profit', 'sum')
)

# Custom aggregation function
df.groupby('category')['sales'].agg(lambda x: x.max() - x.min())

# Multiple group by
df.groupby(['category', 'region'])['sales'].sum()
```

### Sorting

```python
# Sort by single column
df.sort_values('sales', ascending=False)

# Sort by multiple columns
df.sort_values(['category', 'sales'], ascending=[True, False])

# Sort index
df.sort_index()
```

### Handling Missing Data

```python
# Check for nulls
df.isnull().sum()
df['column'].isna()

# Drop nulls
df.dropna()  # Drop rows with any null
df.dropna(subset=['col1', 'col2'])  # Drop if specific columns null
df.dropna(thresh=2)  # Keep rows with at least 2 non-null values

# Fill nulls
df.fillna(0)
df.fillna({'col1': 0, 'col2': 'missing'})
df['column'].fillna(df['column'].mean())  # Fill with mean
df.fillna(method='ffill')  # Forward fill
df.fillna(method='bfill')  # Backward fill
```

### String Operations

```python
# Common string methods
df['name'].str.lower()
df['name'].str.upper()
df['name'].str.title()
df['name'].str.strip()
df['name'].str.replace('old', 'new')
df['name'].str.split(',')
df['name'].str.contains('pattern')
df['name'].str.startswith('A')
df['name'].str.len()

# Extract with regex
df['code'].str.extract(r'(\d+)')
df['email'].str.extract(r'([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+)')
```

### Date/Time Operations

```python
# Convert to datetime
df['date'] = pd.to_datetime(df['date'])

# Extract date parts
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['day'] = df['date'].dt.day
df['dayofweek'] = df['date'].dt.dayofweek
df['quarter'] = df['date'].dt.quarter

# Date arithmetic
df['next_week'] = df['date'] + pd.Timedelta(days=7)
df['days_since'] = (pd.Timestamp.now() - df['date']).dt.days

# Format dates
df['date_str'] = df['date'].dt.strftime('%Y-%m-%d')
```

### Merging & Joining

```python
# Inner join
pd.merge(df1, df2, on='key')
pd.merge(df1, df2, left_on='key1', right_on='key2')

# Left join
pd.merge(df1, df2, on='key', how='left')

# Other joins
pd.merge(df1, df2, on='key', how='right')
pd.merge(df1, df2, on='key', how='outer')

# Multiple keys
pd.merge(df1, df2, on=['key1', 'key2'])

# Concatenate
pd.concat([df1, df2], axis=0)  # Stack vertically
pd.concat([df1, df2], axis=1)  # Stack horizontally
```

### Reshaping

```python
# Pivot
df.pivot(index='date', columns='category', values='sales')
df.pivot_table(index='date', columns='category', values='sales', aggfunc='sum')

# Melt (unpivot)
df.melt(id_vars=['id', 'name'], value_vars=['q1', 'q2', 'q3', 'q4'])

# Transpose
df.T
```

### Window Functions

```python
# Ranking
df['rank'] = df.groupby('category')['sales'].rank(ascending=False)
df['dense_rank'] = df.groupby('category')['sales'].rank(method='dense')

# Cumulative operations
df['cumsum'] = df.groupby('category')['sales'].cumsum()
df['cummax'] = df.groupby('category')['sales'].cummax()

# Rolling window
df['rolling_avg'] = df['sales'].rolling(window=3).mean()
df['rolling_sum'] = df['sales'].rolling(window=7).sum()

# Shift (lag/lead)
df['prev_value'] = df['sales'].shift(1)  # Previous row
df['next_value'] = df['sales'].shift(-1)  # Next row
df['diff_from_prev'] = df['sales'] - df['sales'].shift(1)
```

---

## PySpark Transformations

### Selecting & Filtering

```python
from pyspark.sql import functions as F

# Select columns
df.select('col1', 'col2')
df.select(F.col('col1'), F.col('col2'))

# Filter rows
df.filter(df.age > 25)
df.filter((df.age > 25) & (df.city == 'NYC'))
df.filter(df.status.isin(['active', 'pending']))

# Where (same as filter)
df.where(df.age > 25)

# Between
df.filter(df.age.between(18, 65))
```

### Adding/Modifying Columns

```python
from pyspark.sql import functions as F

# Add constant column
df = df.withColumn('new_col', F.lit('constant'))

# Mathematical operations
df = df.withColumn('total', F.col('price') * F.col('quantity'))

# Conditional column (when/otherwise)
df = df.withColumn('status', 
    F.when(F.col('score') >= 60, 'pass')
     .otherwise('fail')
)

# Multiple conditions
df = df.withColumn('tier',
    F.when(F.col('score') >= 90, 'A')
     .when(F.col('score') >= 70, 'B')
     .when(F.col('score') >= 50, 'C')
     .otherwise('F')
)

# Type casting
df = df.withColumn('id', F.col('id').cast('integer'))
```

### Grouping & Aggregation

```python
from pyspark.sql import functions as F

# Simple group by
df.groupBy('category').count()
df.groupBy('category').agg(F.sum('sales'))

# Multiple aggregations
df.groupBy('category').agg(
    F.sum('sales').alias('total_sales'),
    F.avg('sales').alias('avg_sales'),
    F.count('*').alias('count'),
    F.min('date').alias('first_date'),
    F.max('date').alias('last_date')
)

# Multiple group by
df.groupBy('category', 'region').agg(F.sum('sales'))

# Common aggregation functions
F.count()
F.sum()
F.avg()
F.mean()
F.min()
F.max()
F.first()
F.last()
F.countDistinct()
F.approx_count_distinct()
```

### Sorting

```python
from pyspark.sql import functions as F

# Sort ascending
df.orderBy('sales')
df.sort('sales')

# Sort descending
df.orderBy(F.desc('sales'))
df.orderBy(F.col('sales').desc())

# Multiple columns
df.orderBy(['category', F.desc('sales')])
```

### Handling Missing Data

```python
from pyspark.sql import functions as F

# Drop nulls
df.dropna()  # Drop rows with any null
df.dropna(subset=['col1', 'col2'])  # Drop if specific columns null
df.dropna(how='all')  # Drop only if all values are null

# Fill nulls
df.fillna(0)
df.fillna({'col1': 0, 'col2': 'missing'})

# Using coalesce (return first non-null)
df = df.withColumn('value', F.coalesce(F.col('value'), F.lit(0)))

# Check for nulls
df.filter(F.col('column').isNull())
df.filter(F.col('column').isNotNull())
```

### String Operations

```python
from pyspark.sql import functions as F

# Case conversion
df = df.withColumn('upper_name', F.upper(F.col('name')))
df = df.withColumn('lower_name', F.lower(F.col('name')))

# Trimming
df = df.withColumn('trimmed', F.trim(F.col('name')))

# Substring
df = df.withColumn('first_3', F.substring(F.col('name'), 1, 3))

# Replace
df = df.withColumn('clean', F.regexp_replace(F.col('text'), 'old', 'new'))

# Split
df = df.withColumn('parts', F.split(F.col('name'), ','))

# Pattern matching
df.filter(F.col('name').like('%pattern%'))
df.filter(F.col('name').rlike(r'regex_pattern'))

# String length
df = df.withColumn('name_length', F.length(F.col('name')))

# Concatenation
df = df.withColumn('full_name', F.concat(F.col('first'), F.lit(' '), F.col('last')))
df = df.withColumn('full_name', F.concat_ws(' ', F.col('first'), F.col('last')))
```

### Date/Time Operations

```python
from pyspark.sql import functions as F

# Convert to date/timestamp
df = df.withColumn('date', F.to_date(F.col('date_string'), 'yyyy-MM-dd'))
df = df.withColumn('timestamp', F.to_timestamp(F.col('ts_string'), 'yyyy-MM-dd HH:mm:ss'))

# Extract date parts
df = df.withColumn('year', F.year(F.col('date')))
df = df.withColumn('month', F.month(F.col('date')))
df = df.withColumn('day', F.dayofmonth(F.col('date')))
df = df.withColumn('dayofweek', F.dayofweek(F.col('date')))
df = df.withColumn('quarter', F.quarter(F.col('date')))
df = df.withColumn('weekofyear', F.weekofyear(F.col('date')))

# Date arithmetic
df = df.withColumn('next_week', F.date_add(F.col('date'), 7))
df = df.withColumn('prev_week', F.date_sub(F.col('date'), 7))
df = df.withColumn('days_diff', F.datediff(F.col('end_date'), F.col('start_date')))

# Current date/time
df = df.withColumn('now', F.current_timestamp())
df = df.withColumn('today', F.current_date())

# Format dates
df = df.withColumn('formatted', F.date_format(F.col('date'), 'yyyy-MM-dd'))
```

### Joins

```python
# Inner join
df1.join(df2, on='key', how='inner')
df1.join(df2, df1.key == df2.key, how='inner')

# Left join
df1.join(df2, on='key', how='left')

# Other joins
df1.join(df2, on='key', how='right')
df1.join(df2, on='key', how='outer')
df1.join(df2, on='key', how='left_anti')  # Left anti (rows in df1 but not df2)
df1.join(df2, on='key', how='left_semi')  # Left semi (exists in df2)

# Multiple keys
df1.join(df2, on=['key1', 'key2'])

# Union (concatenate vertically)
df1.union(df2)
df1.unionByName(df2)  # Match by column names
```

### Window Functions

```python
from pyspark.sql import Window
from pyspark.sql import functions as F

# Define window
window = Window.partitionBy('category').orderBy('date')

# Ranking
df = df.withColumn('rank', F.rank().over(window))
df = df.withColumn('dense_rank', F.dense_rank().over(window))
df = df.withColumn('row_number', F.row_number().over(window))

# Cumulative operations
df = df.withColumn('cumsum', F.sum('sales').over(window))
df = df.withColumn('cummax', F.max('sales').over(window))

# Rolling window
window_rolling = Window.partitionBy('category').orderBy('date').rowsBetween(-2, 0)
df = df.withColumn('rolling_avg', F.avg('sales').over(window_rolling))

# Lag and Lead
df = df.withColumn('prev_value', F.lag('sales', 1).over(window))
df = df.withColumn('next_value', F.lead('sales', 1).over(window))
df = df.withColumn('diff', F.col('sales') - F.lag('sales', 1).over(window))
```

### User Defined Functions (UDFs)

```python
from pyspark.sql import functions as F
from pyspark.sql import types

# Define Python function
def custom_logic(value):
    if value > 100:
        return 'high'
    elif value > 50:
        return 'medium'
    else:
        return 'low'

# Register as UDF
custom_udf = F.udf(custom_logic, returnType=types.StringType())

# Use in DataFrame
df = df.withColumn('category', custom_udf(F.col('value')))

# UDF with multiple inputs
def calculate_score(val1, val2, multiplier):
    return (val1 + val2) * multiplier

score_udf = F.udf(calculate_score, returnType=types.DoubleType())
df = df.withColumn('score', score_udf(F.col('val1'), F.col('val2'), F.lit(1.5)))
```

---

## When Python > SQL

### 1. Complex Custom Logic

**Better with Python:**
```python
# Pandas
def complex_calculation(row):
    if row['status'] == 'active':
        base = row['value'] * 1.2
        if row['region'] == 'APAC':
            return base * 0.9
        elif row['region'] == 'EMEA':
            return base * 1.1
        else:
            return base
    else:
        return row['value'] * 0.5

df['adjusted_value'] = df.apply(complex_calculation, axis=1)
```

**SQL Equivalent (Messy):**
```sql
SELECT 
    CASE 
        WHEN status = 'active' THEN 
            CASE 
                WHEN region = 'APAC' THEN value * 1.2 * 0.9
                WHEN region = 'EMEA' THEN value * 1.2 * 1.1
                ELSE value * 1.2
            END
        ELSE value * 0.5
    END as adjusted_value
FROM table
```

**Why Python is better:** Nested logic with multiple conditions is more readable as Python functions.

---

### 2. Iterative Operations

**Better with Python:**
```python
# Calculate running business days (excluding weekends)
import pandas as pd
import numpy as np

dates = pd.date_range('2021-01-01', '2021-12-31')
business_days = [d for d in dates if d.dayofweek < 5]

# Complex time series analysis
df['ma_7'] = df['value'].rolling(7).mean()
df['ma_30'] = df['value'].rolling(30).mean()
df['signal'] = np.where(df['ma_7'] > df['ma_30'], 'buy', 'sell')
```

**Why Python is better:** SQL struggles with iterative calculations and complex rolling window operations.

---

### 3. External API Calls / Web Scraping

**Better with Python:**
```python
import requests

def get_exchange_rate(currency):
    response = requests.get(f'https://api.example.com/rates/{currency}')
    return response.json()['rate']

# Apply to dataframe
df['exchange_rate'] = df['currency'].apply(get_exchange_rate)
df['amount_usd'] = df['amount'] * df['exchange_rate']
```

**Why Python is better:** SQL cannot make external API calls (without complex extensions).

---

### 4. Machine Learning / Statistical Analysis

**Better with Python:**
```python
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

# Feature engineering
scaler = StandardScaler()
df[['scaled_val1', 'scaled_val2']] = scaler.fit_transform(df[['val1', 'val2']])

# Clustering
kmeans = KMeans(n_clusters=3)
df['cluster'] = kmeans.fit_predict(df[['scaled_val1', 'scaled_val2']])

# Outlier detection
from scipy import stats
df['z_score'] = np.abs(stats.zscore(df['value']))
df['is_outlier'] = df['z_score'] > 3
```

**Why Python is better:** Rich ecosystem of ML/statistical libraries not available in SQL.

---

### 5. Text Processing & NLP

**Better with Python:**
```python
import re
from collections import Counter

# Advanced text cleaning
def clean_text(text):
    # Remove URLs
    text = re.sub(r'http\S+', '', text)
    # Remove special characters
    text = re.sub(r'[^a-zA-Z0-9\s]', '', text)
    # Lowercase and strip
    return text.lower().strip()

df['clean_text'] = df['text'].apply(clean_text)

# Word frequency
all_words = ' '.join(df['clean_text']).split()
word_freq = Counter(all_words)
top_10_words = word_freq.most_common(10)

# Sentiment analysis (with library)
from textblob import TextBlob
df['sentiment'] = df['text'].apply(lambda x: TextBlob(x).sentiment.polarity)
```

**Why Python is better:** Advanced regex, NLP libraries, and text analysis tools.

---

### 6. JSON / Nested Data Structures

**Better with Python:**
```python
import json

# Parse complex JSON
def extract_nested(json_str):
    data = json.loads(json_str)
    return {
        'user_id': data['user']['id'],
        'user_name': data['user']['profile']['name'],
        'purchase_amount': sum([item['price'] for item in data['items']]),
        'item_count': len(data['items'])
    }

df_expanded = df['json_column'].apply(extract_nested).apply(pd.Series)
df = pd.concat([df, df_expanded], axis=1)
```

**Why Python is better:** Easier to navigate and transform deeply nested structures.

---

### 7. File System Operations

**Better with Python:**
```python
import os
import glob

# Read multiple files with pattern matching
files = glob.glob('data/2021/**/*.csv', recursive=True)
df_list = [pd.read_csv(f) for f in files]
df_all = pd.concat(df_list, ignore_index=True)

# Check file existence and size
df['file_exists'] = df['file_path'].apply(os.path.exists)
df['file_size'] = df['file_path'].apply(lambda x: os.path.getsize(x) if os.path.exists(x) else None)
```

**Why Python is better:** Direct access to file system operations.

---

### 8. Custom Data Validation

**Better with Python:**
```python
import re

# Email validation
def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

# Phone number validation
def validate_phone(phone):
    pattern = r'^\+?1?\d{9,15}$'
    return bool(re.match(pattern, str(phone)))

# Business logic validation
def validate_order(row):
    errors = []
    if row['quantity'] <= 0:
        errors.append('Invalid quantity')
    if row['price'] < 0:
        errors.append('Invalid price')
    if row['total'] != row['quantity'] * row['price']:
        errors.append('Total mismatch')
    return errors if errors else None

df['email_valid'] = df['email'].apply(validate_email)
df['phone_valid'] = df['phone'].apply(validate_phone)
df['validation_errors'] = df.apply(validate_order, axis=1)
```

**Why Python is better:** Complex validation logic with custom business rules.

---

### 9. Data Quality Profiling

**Better with Python:**
```python
# Comprehensive data profiling
def profile_column(series):
    return {
        'dtype': series.dtype,
        'missing': series.isnull().sum(),
        'missing_pct': series.isnull().sum() / len(series) * 100,
        'unique': series.nunique(),
        'unique_pct': series.nunique() / len(series) * 100,
        'top_values': series.value_counts().head(5).to_dict(),
        'min': series.min() if series.dtype in ['int64', 'float64'] else None,
        'max': series.max() if series.dtype in ['int64', 'float64'] else None,
        'mean': series.mean() if series.dtype in ['int64', 'float64'] else None
    }

# Profile entire dataframe
profile = {col: profile_column(df[col]) for col in df.columns}
profile_df = pd.DataFrame(profile).T
```

**Why Python is better:** Easy to create comprehensive data quality reports.

---

### 10. Dynamic Column Generation

**Better with Python:**
```python
# Dynamically create columns based on conditions
categories = df['category'].unique()

for cat in categories:
    df[f'is_{cat}'] = (df['category'] == cat).astype(int)

# One-hot encoding
df_encoded = pd.get_dummies(df, columns=['category', 'region'])

# Dynamic feature creation for ML
for col in ['sales', 'profit', 'revenue']:
    df[f'{col}_log'] = np.log1p(df[col])
    df[f'{col}_squared'] = df[col] ** 2
    df[f'{col}_sqrt'] = np.sqrt(df[col])
```

**Why Python is better:** Easy to generate multiple columns programmatically.

---

## Common Patterns

### Pattern 1: Data Cleaning Pipeline

```python
def clean_data(df):
    """Comprehensive data cleaning pipeline"""
    # Remove duplicates
    df = df.drop_duplicates()
    
    # Handle missing values
    df = df.fillna({
        'numeric_col': 0,
        'string_col': 'unknown',
        'date_col': pd.Timestamp('1900-01-01')
    })
    
    # Clean string columns
    string_cols = df.select_dtypes(include=['object']).columns
    for col in string_cols:
        df[col] = df[col].str.strip().str.lower()
    
    # Convert data types
    df['id'] = df['id'].astype('int64')
    df['date'] = pd.to_datetime(df['date'])
    
    # Remove outliers (IQR method)
    Q1 = df['value'].quantile(0.25)
    Q3 = df['value'].quantile(0.75)
    IQR = Q3 - Q1
    df = df[(df['value'] >= Q1 - 1.5 * IQR) & (df['value'] <= Q3 + 1.5 * IQR)]
    
    return df

df_clean = clean_data(df)
```

### Pattern 2: Time-based Aggregation

```python
# Resample time series data
df['date'] = pd.to_datetime(df['date'])
df_daily = df.set_index('date').resample('D')['value'].agg(['sum', 'mean', 'count'])
df_weekly = df.set_index('date').resample('W')['value'].sum()
df_monthly = df.set_index('date').resample('M')['value'].sum()

# Custom business logic aggregation
def custom_agg(group):
    return pd.Series({
        'total_sales': group['sales'].sum(),
        'avg_price': group['price'].mean(),
        'num_transactions': len(group),
        'top_product': group.loc[group['sales'].idxmax(), 'product'] if len(group) > 0 else None
    })

df_agg = df.groupby('date').apply(custom_agg)
```

### Pattern 3: Conditional Transformation

```python
# Apply different transformations based on conditions
def transform_by_type(row):
    if row['type'] == 'A':
        return row['value'] * 1.1
    elif row['type'] == 'B':
        return row['value'] * 0.9
    elif row['type'] == 'C':
        return row['value'] ** 2
    else:
        return row['value']

df['transformed'] = df.apply(transform_by_type, axis=1)

# Vectorized version (faster for large datasets)
df['transformed'] = df['value']  # default
mask_a = df['type'] == 'A'
mask_b = df['type'] == 'B'
mask_c = df['type'] == 'C'

df.loc[mask_a, 'transformed'] = df.loc[mask_a, 'value'] * 1.1
df.loc[mask_b, 'transformed'] = df.loc[mask_b, 'value'] * 0.9
df.loc[mask_c, 'transformed'] = df.loc[mask_c, 'value'] ** 2
```

### Pattern 4: Feature Engineering for ML

```python
# Comprehensive feature engineering
def create_features(df):
    # Time-based features
    df['hour'] = df['timestamp'].dt.hour
    df['day_of_week'] = df['timestamp'].dt.dayofweek
    df['is_weekend'] = df['day_of_week'].isin([5, 6]).astype(int)
    df['is_business_hours'] = df['hour'].between(9, 17).astype(int)
    
    # Interaction features
    df['price_per_unit'] = df['total_price'] / df['quantity']
    df['avg_transaction'] = df.groupby('customer_id')['total_price'].transform('mean')
    
    # Statistical features
    df['z_score'] = (df['value'] - df['value'].mean()) / df['value'].std()
    df['percentile'] = df['value'].rank(pct=True)
    
    # Categorical encoding
    df = pd.get_dummies(df, columns=['category', 'region'], drop_first=True)
    
    return df

df_features = create_features(df)
```

---

## Quick Decision Matrix: Python vs SQL

| Scenario | Use Python When... | Use SQL When... |
|----------|-------------------|-----------------|
| **Aggregations** | Custom logic needed | Standard sum/avg/count |
| **Joins** | Complex merge logic | Standard joins |
| **Filtering** | Dynamic conditions | Simple WHERE clauses |
| **Transformations** | Business logic, UDFs | Column math, CASE statements |
| **Text Processing** | Regex, NLP, parsing | Simple LIKE, CONCAT |
| **Date Operations** | Complex date logic | Simple date math |
| **Data Validation** | Custom rules, external checks | NOT NULL, FK constraints |
| **Performance** | Complex calculations on small data | Large-scale aggregations |
| **API Integration** | ✓ Always Python | ✗ Not possible |
| **ML/Statistics** | ✓ Always Python | ✗ Limited/none |

---

## Performance Tips

### Pandas
- Use vectorized operations instead of `.apply()` when possible
- Use `.loc[]` and `.iloc[]` for indexing
- Use `inplace=True` cautiously (doesn't always improve performance)
- Use categorical dtype for low-cardinality string columns
- Use `pd.eval()` for complex expressions

### PySpark
- Use built-in functions over UDFs (UDFs are slower)
- Cache DataFrames when reusing: `df.cache()`
- Repartition before expensive operations
- Use `broadcast()` for small lookup tables in joins
- Avoid `.collect()` and `.toPandas()` on large datasets

---

## Summary

**Use Python/DataFrames when you need:**
- Complex custom business logic
- External integrations (APIs, files, databases)
- Machine learning and statistical analysis
- Advanced text processing and NLP
- Iterative or procedural logic
- Rapid prototyping and exploration

**Use SQL when you need:**
- Simple aggregations and filters
- Standard joins and set operations
- Working with database-resident data
- Team members more comfortable with SQL
- Query optimization by database engine

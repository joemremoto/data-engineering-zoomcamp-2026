# Anatomy of a Spark Cluster

## Overview

Apache Spark uses a **master-worker architecture** to distribute computation across multiple machines. Understanding this architecture is crucial for optimizing Spark applications.

## Core Components

### 1. Driver Program

**What it is:**
- The process running your main application code (where `SparkSession` is created)
- Contains your `main()` function or notebook code
- Orchestrates the entire Spark application

**Responsibilities:**
- Converts your code into a DAG (Directed Acyclic Graph) of tasks
- Schedules tasks across executors
- Maintains metadata about the application
- Coordinates with the cluster manager
- Collects results from executors

**Where it runs:**
- Your local machine (in local mode)
- Client machine (in client mode)
- Cluster node (in cluster mode)

**Example in your code:**
```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('taxi_sql_analysis') \
    .getOrCreate()
```
This creates the Driver that controls everything.

---

### 2. Cluster Manager

**What it is:**
- External service for acquiring resources on the cluster
- Manages which applications get which resources

**Types:**

#### **Local Mode**
- No cluster manager needed
- Driver runs everything in a single JVM
- Good for development and testing
- Example: `.master("local[*]")` uses all CPU cores

#### **Standalone**
- Spark's built-in cluster manager
- Simple to set up for dedicated Spark clusters

#### **YARN (Hadoop)**
- Uses Hadoop's resource manager
- Common in Hadoop ecosystems
- Two modes: client and cluster deployment

#### **Kubernetes**
- Modern container orchestration
- Growing in popularity
- Dynamic resource allocation

#### **Mesos**
- General-purpose cluster manager
- Can run multiple frameworks

---

### 3. Executors

**What they are:**
- Worker processes that run on cluster nodes
- Each executor is a JVM process
- Multiple executors can run on one physical machine

**Responsibilities:**
- Execute tasks assigned by the Driver
- Store data for RDDs/DataFrames in memory or disk
- Return results to the Driver
- Report status and metrics

**Key characteristics:**
- Each executor has a fixed number of cores
- Each executor has allocated memory
- Executors live for the duration of the application
- They run in parallel across the cluster

**Configuration:**
```python
spark = SparkSession.builder \
    .config("spark.executor.memory", "4g") \
    .config("spark.executor.cores", "4") \
    .config("spark.executor.instances", "10") \
    .getOrCreate()
```

---

### 4. Tasks

**What they are:**
- The smallest unit of work in Spark
- Each task processes one partition of data
- Multiple tasks run in parallel across executors

**Task lifecycle:**
1. Driver creates tasks from your code
2. Driver sends tasks to executors
3. Executors run tasks
4. Results sent back to Driver

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT/USER                           │
│                    (Your Python Script)                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      DRIVER PROGRAM                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  SparkContext / SparkSession                         │   │
│  │  - DAG Scheduler                                     │   │
│  │  - Task Scheduler                                    │   │
│  │  - Block Manager Master                              │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────┬────────────────────────────┬────────────────────┘
             │                            │
             │    ┌───────────────────────┘
             │    │
             ▼    ▼
┌────────────────────────────────────────────────────────────┐
│                   CLUSTER MANAGER                           │
│              (Standalone/YARN/K8s/Mesos)                    │
│   - Resource allocation                                     │
│   - Executor management                                     │
└───┬──────────────────┬──────────────────┬─────────────────┘
    │                  │                  │
    ▼                  ▼                  ▼
┌─────────┐      ┌─────────┐      ┌─────────┐
│ NODE 1  │      │ NODE 2  │      │ NODE 3  │
│┌───────┐│      │┌───────┐│      │┌───────┐│
││EXECUTOR│      ││EXECUTOR│      ││EXECUTOR│
││       ││      ││       ││      ││       ││
││ Task1 ││      ││ Task3 ││      ││ Task5 ││
││ Task2 ││      ││ Task4 ││      ││ Task6 ││
││       ││      ││       ││      ││       ││
││ Cache ││      ││ Cache ││      ││ Cache ││
│└───────┘│      │└───────┘│      │└───────┘│
└─────────┘      └─────────┘      └─────────┘
```

---

## Execution Flow

### 1. Job Submission
```
User Code → Driver → DAG Scheduler
```
- You call an action like `.count()` or `.show()`
- Driver receives this and creates a job

### 2. Stage Creation
```
Driver → Breaks job into Stages (based on shuffles)
```
- Each shuffle boundary creates a new stage
- Stages contain tasks that can run in parallel

### 3. Task Scheduling
```
Driver → Task Scheduler → Cluster Manager → Executors
```
- Driver requests executors from cluster manager
- Tasks are assigned to executors
- Each task processes one partition

### 4. Execution
```
Executors → Run tasks in parallel → Return results
```
- Executors process their assigned partitions
- Results sent back to Driver
- Driver aggregates final result

---

## Deployment Modes

### Local Mode
```
Driver + Executors = Same JVM process
```
**When to use:** Development, testing, small datasets

**Example:**
```python
.master("local[4]")  # 4 threads
.master("local[*]")  # All available cores
```

### Client Mode
```
Driver = Your machine
Executors = Cluster nodes
```
**When to use:** Interactive work, notebooks, debugging

**Pros:** 
- See output immediately
- Easy to debug

**Cons:**
- Network dependency (your machine must stay connected)
- Driver is a bottleneck if it has to process large results

### Cluster Mode
```
Driver = Cluster node
Executors = Other cluster nodes
```
**When to use:** Production ETL jobs, scheduled jobs

**Pros:**
- More fault-tolerant
- No dependency on client machine
- Better for production

**Cons:**
- Harder to see logs/output
- Less interactive

---

## Memory Architecture

### Driver Memory
```
┌─────────────────────────────────┐
│       Driver Memory             │
├─────────────────────────────────┤
│  - SparkContext metadata        │
│  - DAG/Task scheduling info     │
│  - Collected results (collect())│
│  - Broadcast variables          │
└─────────────────────────────────┘
```

### Executor Memory
```
┌─────────────────────────────────┐
│      Executor Memory            │
├─────────────────────────────────┤
│  Execution Memory (60%)         │
│  - Shuffles, joins, sorts       │
│  - Temporary data               │
├─────────────────────────────────┤
│  Storage Memory (40%)           │
│  - Cached DataFrames            │
│  - Broadcast variables          │
├─────────────────────────────────┤
│  Reserved (300MB)               │
│  - Internal Spark usage         │
└─────────────────────────────────┘
```

**Configuration:**
```python
.config("spark.driver.memory", "4g")
.config("spark.executor.memory", "8g")
.config("spark.memory.fraction", "0.6")  # Execution + Storage
.config("spark.memory.storageFraction", "0.5")  # Storage portion
```

---

## Data Flow Example

Let's trace a simple operation through the cluster:

```python
df = spark.read.csv("data/yellow/*.csv.gz")  # Transformation (lazy)
result = df.count()  # Action (triggers execution)
```

### Step-by-step:

1. **Driver reads your code**
   - Recognizes `count()` as an action
   - Creates execution plan

2. **Driver breaks work into tasks**
   - Each `.csv.gz` file becomes one or more partitions
   - Each partition = one task

3. **Driver requests resources**
   - Asks cluster manager for executors
   - Gets executor locations

4. **Tasks are distributed**
   - Driver sends tasks to executors
   - Example: 12 files = 12 tasks across 3 executors

5. **Executors execute**
   ```
   Executor 1: Counts rows in files 1-4
   Executor 2: Counts rows in files 5-8
   Executor 3: Counts rows in files 9-12
   ```

6. **Results aggregated**
   - Each executor sends count back to Driver
   - Driver sums all counts
   - Returns final result to you

---

## Partitions and Parallelism

### What are Partitions?
- Logical divisions of your data
- Each partition is processed by one task
- More partitions = more parallelism (up to a limit)

### Partition Count
```python
# Check partitions
print(df.rdd.getNumPartitions())

# Change partitions
df = df.repartition(24)  # Hash-based, shuffles data
df = df.coalesce(6)      # Reduces partitions, no shuffle
```

### Optimal Partitions
```
Rule of thumb: 2-4 partitions per CPU core

Example:
- 10 executors with 4 cores each = 40 cores
- Good partition count: 80-160 partitions
```

---

## Shuffle Operations

### What is a Shuffle?
- Redistribution of data across partitions
- Expensive operation (disk I/O, network I/O)
- Happens during: `groupBy`, `join`, `repartition`, `distinct`

### Shuffle Process
```
┌─────────────┐         ┌─────────────┐
│ Executor 1  │         │ Executor 2  │
│             │         │             │
│  [A, B, C]  │────────▶│  [A, A, A]  │
│  [D, E, F]  │    X    │  [B, B, B]  │
│             │   / \   │  [C, C, C]  │
│             │  /   \  │             │
│             │ /     \ │             │
└─────────────┘/       \└─────────────┘
              /         \
┌─────────────┐         ┌─────────────┐
│ Executor 3  │         │ Executor 4  │
│             │         │             │
│  [D, D, D]  │         │  [E, E, E]  │
│  [F, F, F]  │         │             │
└─────────────┘         └─────────────┘
```

**Minimize shuffles by:**
- Using appropriate partitioning
- Broadcasting small DataFrames
- Filter early to reduce data volume

---

## Configuration Tuning

### Essential Settings

```python
spark = SparkSession.builder \
    .appName("Production Job") \
    .config("spark.executor.instances", "10") \
    .config("spark.executor.cores", "4") \
    .config("spark.executor.memory", "8g") \
    .config("spark.driver.memory", "4g") \
    .config("spark.default.parallelism", "200") \
    .config("spark.sql.shuffle.partitions", "200") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()
```

### What they mean:

| Setting | Purpose | Default | When to Change |
|---------|---------|---------|----------------|
| `executor.instances` | Number of executors | 2 | Always set for cluster |
| `executor.cores` | Cores per executor | 1 | Balance parallelism vs memory |
| `executor.memory` | RAM per executor | 1g | Based on data size |
| `driver.memory` | Driver RAM | 1g | If collecting large results |
| `default.parallelism` | RDD partitions | 2×cores | Match shuffle partitions |
| `sql.shuffle.partitions` | DataFrame partitions after shuffle | 200 | Based on data size |

---

## Monitoring Your Cluster

### Spark UI
Access at: `http://localhost:4040` (when running locally)

**Key tabs:**
- **Jobs**: See all jobs and their stages
- **Stages**: Task-level details, timeline
- **Storage**: Cached DataFrames
- **Executors**: Resource usage, task distribution
- **SQL**: Query plans and execution

### What to look for:
- **Skewed tasks**: One task taking much longer (data skew)
- **Spill to disk**: Not enough memory (increase executor memory)
- **Shuffle read/write**: Large shuffles (optimize code)
- **GC time**: High garbage collection (tune memory)

---

## Common Issues and Solutions

### Problem: Out of Memory
**Symptoms:** Executor crashes, "Java heap space" errors

**Solutions:**
- Increase `spark.executor.memory`
- Reduce `spark.sql.shuffle.partitions` if too many small tasks
- Use `.persist(StorageLevel.DISK_ONLY)` instead of memory
- Filter data earlier in pipeline

### Problem: Slow Jobs
**Symptoms:** Tasks taking hours

**Solutions:**
- Check for data skew (one partition much larger)
- Increase parallelism (more partitions)
- Use broadcast joins for small tables
- Enable adaptive query execution

### Problem: Connection Timeouts
**Symptoms:** Tasks fail with network errors

**Solutions:**
- Increase `spark.network.timeout`
- Check cluster network stability
- Reduce task size (more partitions)

---

## Best Practices

### 1. **Right-size your cluster**
```
Don't use 100 executors for 1GB of data
Don't use 2 executors for 1TB of data
```

### 2. **Partition appropriately**
```python
# Too few partitions = poor parallelism
df.repartition(2)  # Bad for 100GB data

# Too many partitions = scheduler overhead  
df.repartition(10000)  # Bad for 1GB data

# Just right
df.repartition(200)  # Good for most cases
```

### 3. **Cache strategically**
```python
# Cache if reusing DataFrame multiple times
df.cache()
df.count()  # Materializes cache
df.filter(...).show()  # Uses cache
df.groupBy(...).count()  # Uses cache

# Don't cache if using only once
df.show()  # No cache needed
```

### 4. **Use appropriate file formats**
```
CSV: Slow, not splittable when compressed
Parquet: Fast, columnar, splittable, compressed
```

### 5. **Monitor and tune**
- Always check Spark UI
- Profile your jobs
- Test with sample data first
- Scale incrementally

---

## Summary

A Spark cluster consists of:
- **1 Driver**: Orchestrates everything
- **N Executors**: Do the actual work
- **1 Cluster Manager**: Allocates resources
- **Tasks**: Smallest unit of work (1 per partition)

**Key concepts:**
- Partitions enable parallelism
- Shuffles are expensive
- Memory matters (both driver and executor)
- Configuration drives performance

**Remember:**
Your DataFrame operations are distributed across executors, but the Driver coordinates everything. Understanding this architecture helps you write better Spark code!

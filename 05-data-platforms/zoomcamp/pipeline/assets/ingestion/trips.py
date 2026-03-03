"""@bruin

name: ingestion.trips

type: python

image: python:3.11

connection: duckdb-default

materialization:
  type: table
  strategy: append

@bruin"""

import os
import json
import pandas as pd
from datetime import datetime
from dateutil.relativedelta import relativedelta


os.environ['ARROW_TZDATA_PATH'] = 'C:/Windows/Globalization'

# NYC Taxi TLC base URL
BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/"


def materialize():
    """
    Fetch NYC Taxi trip data from TLC public endpoint.
    
    Uses Bruin runtime context:
    - BRUIN_START_DATE / BRUIN_END_DATE: Date range for data extraction
    - BRUIN_VARS: Pipeline variables (taxi_types)
    
    Returns:
        pandas.DataFrame: Raw trip data with extracted_at timestamp
    """
    # Read Bruin environment variables
    start_date = datetime.strptime(os.environ["BRUIN_START_DATE"], "%Y-%m-%d")
    end_date = datetime.strptime(os.environ["BRUIN_END_DATE"], "%Y-%m-%d")
    
    # Read pipeline variables (taxi_types)
    bruin_vars = json.loads(os.environ.get("BRUIN_VARS", "{}"))
    taxi_types = bruin_vars.get("taxi_types", ["yellow"])
    
    # Add extraction timestamp for lineage
    extracted_at = datetime.now()
    
    # Generate list of months in the date range
    months = []
    current = start_date
    while current <= end_date:
        months.append(current)
        current += relativedelta(months=1)
    
    # Fetch data for each taxi type and month
    all_dataframes = []
    
    for taxi_type in taxi_types:
        for month in months:
            year = month.year
            month_num = month.month
            
            # Construct file URL: <taxi_type>_tripdata_<year>-<month>.parquet
            filename = f"{taxi_type}_tripdata_{year}-{month_num:02d}.parquet"
            url = BASE_URL + filename
            
            try:
                print(f"Fetching: {url}")
                df = pd.read_parquet(url)
                
                # Add metadata columns
                df["taxi_type"] = taxi_type
                df["extracted_at"] = extracted_at
                
                all_dataframes.append(df)
                print(f"[OK] Loaded {len(df)} rows from {filename}")
                
            except Exception as e:
                print(f"[ERROR] Failed to load {filename}: {e}")
                # Continue with other files even if one fails
                continue
    
    # Concatenate all dataframes
    if not all_dataframes:
        raise ValueError("No data was successfully loaded from any source")
    
    final_df = pd.concat(all_dataframes, ignore_index=True)
    
    # Convert timezone-aware datetime columns to timezone-naive for Windows compatibility
    # This prevents PyArrow timezone database issues in the ingestr loading phase
    for col in final_df.columns:
        if pd.api.types.is_datetime64_any_dtype(final_df[col]):
            if hasattr(final_df[col].dtype, 'tz') and final_df[col].dtype.tz is not None:
                final_df[col] = final_df[col].dt.tz_localize(None)
    
    print(f"\n{'='*50}")
    print(f"Total rows ingested: {len(final_df)}")
    print(f"Taxi types: {', '.join(taxi_types)}")
    print(f"Date range: {start_date.date()} to {end_date.date()}")
    print(f"{'='*50}\n")
    
    return final_df



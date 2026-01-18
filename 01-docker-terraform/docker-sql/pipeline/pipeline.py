# import sys

# print('parameters:', sys.argv)

# file_name = sys.argv[0]
# month = sys.argv[1]

# print(f"hello pipeline, file_name: {file_name}, month: {month}")

# # @joemremoto ➜ .../data-engineering-zoomcamp-2026/01-docker-terraform/docker-sql/pipeline (main) $ python pipeline.py 12
# # parameters: ['pipeline.py', '12']
# # hello pipeline, file_name: pipeline.py, month: 12

import sys
import pandas as pd

print('parameters:', sys.argv)

file_name = sys.argv[0]
month = sys.argv[1]

print(f"hello pipeline, file_name: {file_name}, month: {month}")



df = pd.DataFrame({"A": [1, 2], "B": [3, 4]})
print(df.head())

df.to_parquet(f"output_month_{sys.argv[1]}.parquet")
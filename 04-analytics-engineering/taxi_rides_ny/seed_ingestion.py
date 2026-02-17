import requests
from pathlib import Path

# URL for the taxi zone lookup CSV
CSV_URL = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"

def download_seed_file():
    """Download the taxi zone lookup CSV file and save it to the seeds directory."""
    
    # Define the seeds directory and ensure it exists
    seeds_dir = Path("seeds")
    seeds_dir.mkdir(exist_ok=True)
    
    # Define the output file path
    output_file = seeds_dir / "taxi_zone_lookup.csv"
    
    # Check if file already exists
    if output_file.exists():
        print(f"File {output_file.name} already exists in the seeds directory. Skipping download.")
        return
    
    print(f"Downloading taxi zone lookup data from {CSV_URL}...")
    
    # Download the CSV file
    response = requests.get(CSV_URL)
    response.raise_for_status()
    
    # Save the file
    with open(output_file, 'wb') as f:
        f.write(response.content)
    
    print(f"Successfully downloaded {output_file.name} to the seeds directory.")

if __name__ == "__main__":
    download_seed_file()

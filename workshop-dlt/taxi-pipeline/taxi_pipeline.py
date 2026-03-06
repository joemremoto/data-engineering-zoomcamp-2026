"""Pipeline for ingesting NYC taxi data from REST API."""

import dlt
from dlt.sources.rest_api import rest_api_resources
from dlt.sources.rest_api.typing import RESTAPIConfig


@dlt.source
def taxi_pipeline_rest_api_source():
    """Define dlt resources from NYC Taxi REST API endpoint."""
    config: RESTAPIConfig = {
        "client": {
            "base_url": "https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api",
            # Public API - no authentication required
            "paginator": {
                "type": "offset",
                "limit": 1000,
                "offset_param": "offset",
                "limit_param": "limit",
                # API doesn't provide total count, so rely on empty page detection
                "total_path": None,
                "stop_after_empty_page": True,
            },
        },
        "resources": [
            {
                "name": "taxi_data",
                "endpoint": {
                    "path": "",  # Base URL is the endpoint
                },
            },
        ],
    }

    yield from rest_api_resources(config)


pipeline = dlt.pipeline(
    pipeline_name='taxi_pipeline',
    destination='duckdb',
    dataset_name='nyc_taxi_data',
    # `refresh="drop_sources"` ensures the data and the state is cleaned
    # on each `pipeline.run()`; remove the argument once you have a
    # working pipeline.
    refresh="drop_sources",
    # show basic progress of resources extracted, normalized files and load-jobs on stdout
    progress="log",
)


if __name__ == "__main__":
    load_info = pipeline.run(taxi_pipeline_rest_api_source())
    print(load_info)  # noqa: T201

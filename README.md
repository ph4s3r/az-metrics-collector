==================================================================

# Azure Metrics Collector

Author: Peter Karacsonyi

Collecting Azure tenant level metrics and exposing them with a prometheus client

## Contribution

Open new issue and provide info -> create new branch linked to issue -> Pull -> add verbose messages to your commits -> Push -> MR

To add new metrics:

1) write the logic to query data from azure in `metrics_collection/metrics_collector.py`
2) define a gauge in `metrics_collection/gauges.py`
3) call the gauge create function in `update_metrics()`, set it to a value running your query function and or you can even define another update function.   
   When using another function don't forget to decorate it with `@scheduler.scheduled_job()`.  
   If different update schedule is needed, define a variable and use it in the decorator.

## Deploying the server as a linux service

### Configuration

1) Choose a user to run the service with
2) Copy azure credentials to a file named `~/.azure_creds` (under the chose user's home directory) where the first line is a CLIENT_ID and second is the secret (values only)

**Before installing the application, check configuration items in the deploy.sh file and change defaults if needed!**  
Current configuration settings and their defaults:

- python path
`PYTHON='/usr/bin/python3'`
- install dir
`INSTALL_DIR='/opt/azmetrics'`
- run as
`RUNAS='<yourUserName>'`
- prometheus server port
`PROMETHEUS_HTTP_PORT='8000'`
- data refresh interval (cron format)
`REFRESH_CRON='0 * * * *'`
- subscription filter
`SUB_FILTER_KEYWORD='landingzone'`

### Install

After setting the configuration items in deploy.sh, run `deploy.sh`  
To learn more what the deployment is actually doing, look into `deploy.sh`

## Uninstalling

run `uninstall_service.sh`

## Running Standalone

1) Check default configuration values in the `config = {}` dict in `metrics_server.py`.
2) Run `/usr/bin/python3 metrics_server.py`

==================================================================

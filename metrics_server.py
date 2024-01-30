#!/usr/bin/python3
#   about: Azure Metrics Server powered by Prometheus
#  author: Peter Karacsonyi <peter.karacsonyi85@domain.com>
#    date: 05 Apr 2023
# license: GNU General Public License, version 2
#####

import os
import time
import warnings

# 3rd party imports
from prometheus_client import start_http_server
from apscheduler.triggers.cron import CronTrigger
from apscheduler.schedulers.background import BackgroundScheduler

# local imports
from metrics_collection import auth_cc
from metrics_collection import metrics_collector
from metrics_collection import gauges

# disable warnings
warnings.filterwarnings(
    'ignore',
    message='The localize method is no longer necessary, \
      as this time zone supports the fold attribute',
)

# getting variables from the deploy script
config = {
  "HTTP_SERVER_PORT" : int(os.environ.get('PROMETHEUS_HTTP_PORT', '8000')),             # default 8000
  "REFRESH_CRON" : os.environ.get('config.get("REFRESH_CRON")', '0 * * * *'),           # default hourly
  "SUB_FILTER_KEYWORD" : os.environ.get('config.get("SUB_FILTER_KEYWORD")', 'landingzone'),  # default landingzone
}

print('Starting Azure Metrics Collector powered by Prometheus')

### get azure creds
az_creds = auth_cc.Auth_ClientSecretCredential()


### schedule the update job
scheduler = BackgroundScheduler()
@scheduler.scheduled_job(trigger = CronTrigger.from_crontab(config.get("REFRESH_CRON")))
def update_metrics():
    '''
    All the azure resource query logic is in metrics_collection, 
    here we only call the functions getting the data to set prometheus gauges
    '''

    print('Querying data from Azure')
    subs, res, rgs, vms = metrics_collector.get_sub_vm_rg_resource_counts(
      config.get("SUB_FILTER_KEYWORD"), az_creds
      )

    gauge_subscription_count = gauges.create_gauge_subscription_count(config)
    gauge_subscription_count.set(subs)
    gauge_resource_count = gauges.create_gauge_resource_count(config)
    gauge_resource_count.set(res)
    gauge_resource_group_count = gauges.create_gauge_resource_group_count(config)
    gauge_resource_group_count.set(rgs)
    gauge_vm_count = gauges.create_gauge_vm_count(config)
    gauge_vm_count.set(vms)

update_metrics()


### start server and scheduler
print(f'Starting server in port {config.get("HTTP_SERVER_PORT")}')
start_http_server(config.get("HTTP_SERVER_PORT"))
print(f'Metrics server is running on port {config.get("HTTP_SERVER_PORT")}')
scheduler.start()
print('Scheduler is running')
while True:
    time.sleep(5)

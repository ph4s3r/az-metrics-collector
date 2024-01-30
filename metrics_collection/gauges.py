from prometheus_client import Gauge

### define gauges for each metric

def create_gauge_subscription_count(config):
  return Gauge(
      f'azure_{config.get("SUB_FILTER_KEYWORD")}_subscription_count',
      f'Number of {config.get("SUB_FILTER_KEYWORD")} subscriptions in the Azure tenant'
  )

def create_gauge_resource_count(config):
  return Gauge(
     f'azure_{config.get("SUB_FILTER_KEYWORD")}_resource_count',
     f'Number of resources in {config.get("SUB_FILTER_KEYWORD")} subscriptions'
  )

def create_gauge_resource_group_count(config):
  return Gauge(
    f'azure_{config.get("SUB_FILTER_KEYWORD")}_resource_group_count',
    f'Number of resource groups in {config.get("SUB_FILTER_KEYWORD")} subscriptions'
  )

def create_gauge_vm_count(config):
  return Gauge(
    f'azure_{config.get("SUB_FILTER_KEYWORD")}_vm_count',
    f'Number of {config.get("SUB_FILTER_KEYWORD")} virtual machines in {config.get("SUB_FILTER_KEYWORD")} subscriptions'
  )

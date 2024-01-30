#!/usr/bin/python3
#   about: Azure Metrics Collector
#  author: Peter Karacsonyi <peter.karacsonyi@domain.com>
#    date: 05 Apr 2023
# license: GNU General Public License, version 2
#####

from azure.mgmt.resource import SubscriptionClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.resource import ResourceManagementClient

def get_filtered_subscriptions(filter_keyword, creds):
    """
    Gets the list subscriptions where subscription name matches the argument filter_keyword
    """

    subscription_client = SubscriptionClient(
      creds
    )
  
    return [sub for sub in subscription_client.subscriptions.list() if filter_keyword.lower() in sub.display_name.lower()]


def get_vm_rg_resource_count_per_subscription(subscription_id, creds):
    """
    Gets the number of virtual machines, resource groups and resources in a subscription
    """

    compute_client = ComputeManagementClient(
      creds,
      subscription_id
    )

    resource_client = ResourceManagementClient(
      creds,
      subscription_id
    )

    return ( 
      len(list(compute_client.virtual_machines.list_all())),
      len(list(resource_client.resource_groups.list())),
      len(list(resource_client.resources.list())) 
    )


def get_sub_vm_rg_resource_counts(filter_keyword, creds):
    """
    Calls the function to get all subscriptions, 
    then loops through them calling the function "get_vm_rg_resource_count_per_subscription" 
    to get the number of resources 
    """

    vms = rgs = res = 0

    # query all subscriptions
    subscriptions = get_filtered_subscriptions(filter_keyword, creds)

    # query resources for each subscription
    for sub in subscriptions:
        vm_count, rg_count, resource_count = get_vm_rg_resource_count_per_subscription(sub.subscription_id, creds)
        vms = vms + vm_count
        rgs = rgs + rg_count
        res = res + resource_count 

    # return the number of items as a tuple
    return (
      len(subscriptions),
      res,
      rgs,
      vms
    )

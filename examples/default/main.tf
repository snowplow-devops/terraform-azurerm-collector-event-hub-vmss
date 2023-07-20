locals {
  name = "collector-test"

  ssh_public_key   = "PUBLIC_KEY"
  user_provided_id = "collector-module-example@snowplow.io"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = "North Europe"
}

module "pipeline_eh_namespace" {
  source  = "snowplow-devops/event-hub-namespace/azurerm"
  version = "0.1.1"

  name                = "${local.name}-ehn"
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

module "raw_eh_topic" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.1"

  name                = "${local.name}-raw-topic"
  namespace_name      = module.pipeline_eh_namespace.name
  resource_group_name = azurerm_resource_group.rg.name
}

module "bad_1_eh_topic" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.1"

  name                = "${local.name}-bad-1-topic"
  namespace_name      = module.pipeline_eh_namespace.name
  resource_group_name = azurerm_resource_group.rg.name
}


module "vnet" {
  source  = "snowplow-devops/vnet/azurerm"
  version = "0.1.2"

  name                = "${local.name}-vnet"
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}


module "collector_lb" {
  source  = "snowplow-devops/lb/azurerm"
  version = "0.1.1"

  name                = "${local.name}-clb"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = lookup(module.vnet.vnet_subnets_name_id, "collector-agw1")

  probe_path = "/health"

  depends_on = [azurerm_resource_group.rg]
}

module "collector_event_hub" {
  source = "../.."

  name                = "${local.name}-collector-server"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = lookup(module.vnet.vnet_subnets_name_id, "pipeline1")

  application_gateway_backend_address_pool_ids = [module.collector_lb.agw_backend_address_pool_id]

  ingress_port = module.collector_lb.agw_backend_egress_port

  good_topic_name                           = module.raw_eh_topic.name
  bad_topic_name                            = module.bad_1_eh_topic.name
  eh_namespace_broker                       = module.pipeline_eh_namespace.broker
  eh_namespace_read_write_connection_string = module.pipeline_eh_namespace.read_write_primary_connection_string

  ssh_public_key   = local.ssh_public_key
  ssh_ip_allowlist = ["0.0.0.0/0"]

  user_provided_id = local.user_provided_id

  depends_on = [azurerm_resource_group.rg]
}

output "collector_fqdn" {
  value = module.collector_lb.ip_address_fqdn
}

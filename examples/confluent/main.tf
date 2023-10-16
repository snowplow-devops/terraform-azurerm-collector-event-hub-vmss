locals {
  name = "collector-test"

  ssh_public_key   = "PUBLIC_KEY"
  user_provided_id = "collector-module-example@snowplow.io"

  # This is your cluster "Bootstrap Server"
  kafka_brokers = "<SET_ME>"
  # This is your cluster API Key (Key + Secret)
  kafka_username = "<SET_ME>"
  kafka_password = "<SET_ME>"

  # Default names for topics (note: change if you used different denominations)
  good_topic_name = "raw"
  bad_topic_name  = "bad_1"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = "North Europe"
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
  version = "0.2.0"

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

  good_topic_name = local.good_topic_name
  bad_topic_name  = local.bad_topic_name
  kafka_brokers   = local.kafka_brokers
  kafka_username  = local.kafka_username
  kafka_password  = local.kafka_password

  kafka_source = "confluent_cloud"

  ssh_public_key   = local.ssh_public_key
  ssh_ip_allowlist = ["0.0.0.0/0"]

  user_provided_id = local.user_provided_id

  depends_on = [azurerm_resource_group.rg]
}

output "collector_fqdn" {
  value = module.collector_lb.ip_address_fqdn
}

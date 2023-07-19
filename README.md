[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Registry][registry-image]][registry] [![Source][source-image]][source]

# terraform-azurerm-collector-event-hub-vmss

A Terraform module which deploys the Snowplow Stream Collector on a VM scale-set and sinks data into Event Hubs over Kafka.

## Telemetry

This module by default collects and forwards telemetry information to Snowplow to understand how our applications are being used.  No identifying information about your sub-account or account fingerprints are ever forwarded to us - it is very simple information about what modules and applications are deployed and active.

If you wish to subscribe to our mailing list for updates to these modules or security advisories please set the `user_provided_id` variable to include a valid email address which we can reach you at.

### How do I disable it?

To disable telemetry simply set variable `telemetry_enabled = false`.

### What are you collecting?

For details on what information is collected please see this module: https://github.com/snowplow-devops/terraform-snowplow-telemetry

## Usage

A Collector requires two output Kafka Topics and a Load Balancer which is deployed upstream. The Load Balancer ensures we can easily configure TLS termination later in the setup and provides a simple mechanism for setting up DNS.

```hcl
module "pipeline_eh_namespace" {
  source  = "snowplow-devops/event-hub-namespace/azurerm"
  version = "0.1.0"

  name                = "snowplow-pipeline"
  resource_group_name = var.resource_group_name
}

module "raw_eh_topic" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.0"

  name                = "raw-topic"
  namespace_name      = module.pipeline_eh_namespace.name
  resource_group_name = var.resource_group_name
}

module "bad_1_eh_topic" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.0"

  name                = "bad-1-topic"
  namespace_name      = module.pipeline_eh_namespace.name
  resource_group_name = var.resource_group_name
}

module "collector_lb" {
  source  = "snowplow-devops/lb/azurerm"
  version = "0.1.0"

  name                = "collector-lb"
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_for_agw

  probe_path = "/health"
}

module "collector_event_hub" {
  source  = "snowplow-devops/collector-event-hub-vmss/azurerm"

  name                = "collector-server"
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_for_servers

  application_gateway_backend_address_pool_ids = [module.collector_lb.agw_backend_address_pool_id]

  ingress_port = module.collector_lb.agw_backend_egress_port

  good_topic_name                           = module.raw_eh_topic.name
  bad_topic_name                            = module.bad_1_eh_topic.name
  eh_namespace_broker                       = module.pipeline_eh_namespace.broker
  eh_namespace_read_write_connection_string = module.pipeline_eh_namespace.read_write_primary_connection_string

  ssh_public_key   = "your-public-key-here"
  ssh_ip_allowlist = ["0.0.0.0/0"]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.58.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.58.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service"></a> [service](#module\_service) | snowplow-devops/service-vmss/azurerm | 0.1.0 |
| <a name="module_telemetry"></a> [telemetry](#module\_telemetry) | snowplow-devops/telemetry/snowplow | 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.egress_tcp_443](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.egress_tcp_80](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.egress_udp_123](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.ingress_tcp_22](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bad_topic_name"></a> [bad\_topic\_name](#input\_bad\_topic\_name) | The name of the bad Event Hubs topic that the collector will insert failed data into | `string` | n/a | yes |
| <a name="input_eh_namespace_broker"></a> [eh\_namespace\_broker](#input\_eh\_namespace\_broker) | The broker to configure for access to the Event Hubs namespace | `string` | n/a | yes |
| <a name="input_eh_namespace_read_write_connection_string"></a> [eh\_namespace\_read\_write\_connection\_string](#input\_eh\_namespace\_read\_write\_connection\_string) | The connection string to use for access to the Event Hubs namespace | `string` | n/a | yes |
| <a name="input_good_topic_name"></a> [good\_topic\_name](#input\_good\_topic\_name) | The name of the good Event Hubs topic that the collector will insert good data into | `string` | n/a | yes |
| <a name="input_ingress_port"></a> [ingress\_port](#input\_ingress\_port) | The port that the collector will be bound to and expose over HTTP | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A name which will be pre-pended to the resources created | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to deploy the service into | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The SSH public key attached for access to the servers | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet id to deploy the load balancer across | `string` | n/a | yes |
| <a name="input_application_gateway_backend_address_pool_ids"></a> [application\_gateway\_backend\_address\_pool\_ids](#input\_application\_gateway\_backend\_address\_pool\_ids) | The ID of an Application Gateway backend address pool to bind the VM scale-set to the load balancer | `list(string)` | `[]` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to this instance | `bool` | `true` | no |
| <a name="input_byte_limit"></a> [byte\_limit](#input\_byte\_limit) | The amount of bytes to buffer events before pushing them to Kinesis | `number` | `1000000` | no |
| <a name="input_cookie_domain"></a> [cookie\_domain](#input\_cookie\_domain) | Optional first party cookie domain for the collector to set cookies on (e.g. acme.com) | `string` | `""` | no |
| <a name="input_custom_paths"></a> [custom\_paths](#input\_custom\_paths) | Optional custom paths that the collector will respond to, typical paths to override are '/com.snowplowanalytics.snowplow/tp2', '/com.snowplowanalytics.iglu/v1' and '/r/tp2'. e.g. { "/custom/path/" : "/com.snowplowanalytics.snowplow/tp2"} | `map(string)` | `{}` | no |
| <a name="input_java_opts"></a> [java\_opts](#input\_java\_opts) | Custom JAVA Options | `string` | `"-Dorg.slf4j.simpleLogger.defaultLogLevel=info -XX:MinRAMPercentage=50 -XX:MaxRAMPercentage=75"` | no |
| <a name="input_record_limit"></a> [record\_limit](#input\_record\_limit) | The number of events to buffer before pushing them to Kinesis | `number` | `500` | no |
| <a name="input_ssh_ip_allowlist"></a> [ssh\_ip\_allowlist](#input\_ssh\_ip\_allowlist) | The comma-seperated list of CIDR ranges to allow SSH traffic from | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to this resource | `map(string)` | `{}` | no |
| <a name="input_telemetry_enabled"></a> [telemetry\_enabled](#input\_telemetry\_enabled) | Whether or not to send telemetry information back to Snowplow Analytics Ltd | `bool` | `true` | no |
| <a name="input_time_limit_ms"></a> [time\_limit\_ms](#input\_time\_limit\_ms) | The amount of time to buffer events before pushing them to Kinesis | `number` | `500` | no |
| <a name="input_user_provided_id"></a> [user\_provided\_id](#input\_user\_provided\_id) | An optional unique identifier to identify the telemetry events emitted by this stack | `string` | `""` | no |
| <a name="input_vm_instance_count"></a> [vm\_instance\_count](#input\_vm\_instance\_count) | The instance type to use | `number` | `1` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | The instance type to use | `string` | `"Standard_B1ms"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | ID of the network security group attached to the Collector Server nodes |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | ID of the VM scale-set |

# Copyright and license

The Terraform Azurerm Collector EventHub on VMSS project is Copyright 2023-present Snowplow Analytics Ltd.

Licensed under the [Snowplow Community License](https://docs.snowplow.io/community-license-1.0). _(If you are uncertain how it applies to your use case, check our answers to [frequently asked questions](https://docs.snowplow.io/docs/contributing/community-license-faq/).)_

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[release]: https://github.com/snowplow-devops/terraform-azurerm-collector-event-hub-vmss/releases/latest
[release-image]: https://img.shields.io/github/v/release/snowplow-devops/terraform-azurerm-collector-event-hub-vmss

[ci]: https://github.com/snowplow-devops/terraform-azurerm-collector-event-hub-vmss/actions?query=workflow%3Aci
[ci-image]: https://github.com/snowplow-devops/terraform-azurerm-collector-event-hub-vmss/workflows/ci/badge.svg

[license]: https://docs.snowplow.io/docs/contributing/community-license-faq/
[license-image]: https://img.shields.io/badge/license-Snowplow--Community-blue.svg?style=flat

[registry]: https://registry.terraform.io/modules/snowplow-devops/collector-event-hub-vmss/azurerm/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform

[source]: https://github.com/snowplow/stream-collector
[source-image]: https://img.shields.io/static/v1?label=Snowplow&message=Stream%20Collector&color=0E9BA4&logo=GitHub

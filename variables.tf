variable "name" {
  description = "A name which will be pre-pended to the resources created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the service into"
  type        = string
}

variable "subnet_id" {
  description = "The subnet id to deploy the load balancer across"
  type        = string
}

variable "application_gateway_backend_address_pool_ids" {
  description = "The ID of an Application Gateway backend address pool to bind the VM scale-set to the load balancer"
  type        = list(string)
  default     = []
}

variable "ingress_port" {
  description = "The port that the collector will be bound to and expose over HTTP"
  type        = number
}

variable "vm_sku" {
  description = "The instance type to use"
  type        = string
  default     = "Standard_B1ms"
}

variable "vm_instance_count" {
  description = "The instance type to use"
  type        = number
  default     = 1
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public ip address to this instance"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "The SSH public key attached for access to the servers"
  type        = string
}

variable "ssh_ip_allowlist" {
  description = "The comma-seperated list of CIDR ranges to allow SSH traffic from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "The tags to append to this resource"
  default     = {}
  type        = map(string)
}

variable "java_opts" {
  description = "Custom JAVA Options"
  default     = "-Dorg.slf4j.simpleLogger.defaultLogLevel=info -XX:MinRAMPercentage=50 -XX:MaxRAMPercentage=75"
  type        = string
}

# --- Configuration options

variable "good_topic_name" {
  description = "The name of the good Event Hubs topic that the collector will insert good data into"
  type        = string
}

variable "bad_topic_name" {
  description = "The name of the bad Event Hubs topic that the collector will insert failed data into"
  type        = string
}

variable "eh_namespace_broker" {
  description = "The broker to configure for access to the Event Hubs namespace"
  type        = string
}

variable "eh_namespace_read_write_connection_string" {
  description = "The connection string to use for access to the Event Hubs namespace"
  type        = string
}

variable "custom_paths" {
  description = "Optional custom paths that the collector will respond to, typical paths to override are '/com.snowplowanalytics.snowplow/tp2', '/com.snowplowanalytics.iglu/v1' and '/r/tp2'. e.g. { \"/custom/path/\" : \"/com.snowplowanalytics.snowplow/tp2\"}"
  default     = {}
  type        = map(string)
}

variable "cookie_domain" {
  description = "Optional first party cookie domain for the collector to set cookies on (e.g. acme.com)"
  default     = ""
  type        = string
}

variable "byte_limit" {
  description = "The amount of bytes to buffer events before pushing them to Kinesis"
  default     = 1000000
  type        = number
}

variable "record_limit" {
  description = "The number of events to buffer before pushing them to Kinesis"
  default     = 500
  type        = number
}

variable "time_limit_ms" {
  description = "The amount of time to buffer events before pushing them to Kinesis"
  default     = 500
  type        = number
}

# --- Telemetry

variable "telemetry_enabled" {
  description = "Whether or not to send telemetry information back to Snowplow Analytics Ltd"
  type        = bool
  default     = true
}

variable "user_provided_id" {
  description = "An optional unique identifier to identify the telemetry events emitted by this stack"
  type        = string
  default     = ""
}
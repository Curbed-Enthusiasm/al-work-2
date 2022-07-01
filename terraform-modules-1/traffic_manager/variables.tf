variable "profile_name" {
  description = "The name the profile will have, DNS wil be this"
  type = string
}

variable "profile_resource_group" {
  description = "Resource group to save the profile and all the endpoints"
  type = string
}

variable "ttl" {
  description = "TTL"
  type = number
}

variable "protocol" {
  description = "Protocol"
  type = string
}

variable "port" {
  description = "Port"
  type = number
}

variable "path" {
  description = "Path"
  type = string
}

variable "interval_in_seconds" {
  description = "Interval in secods"
  type = number
}

variable "timeout_in_seconds" {
  description = "Timeout in seconds"
  type = number
}

variable "tolerated_number_of_failures" {
  description = "Tolerated number of failures"
  type = number
}

variable "apps_to_route" {
  description = "List of apps to use behind the traffic manager with a structure { name = string, rg = string, weight = number }"
  type = list(object({
    name = string,
    rg = string,
    weight = number
  }))
}
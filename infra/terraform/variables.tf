variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "environment_name" {
  description = "The name of the azd environment to be deployed"
  type        = string
}

variable "subscription_id" {
  description = "The subscription id where the resources will be deployed"
  type        = string
}
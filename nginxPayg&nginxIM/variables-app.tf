#############################
## Application - Variables ##
#############################

# Unique Deployment Name 
variable "deployName" {
  type        = string
  description = "This variable defines a unique name for deployment"
}

# Deploy prefix 
variable "prefix" {
  type        = string
  description = "This variable defines a unique name prefix for deployment"
}

# azure region
variable "location" {
  type        = string
  description = "Azure region where the resource group will be created"
  default     = "centralus"
}

# azure region shortname
variable "region" {
  type        = string
  description = "Azure region where the resource group will be created"
  default     = "centralus"
}

# owner
variable "owner" {
  type        = string
  description = "Specify the owner of the resource"
}

# description
variable "description" {
  type        = string
  description = "Provide a description of the resource"
}

# application environment
variable "environment" {
  type        = string
  description = "This variable defines the environment to be built"
}
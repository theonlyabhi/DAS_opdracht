variable "prefix" {
  description = "Naam prefix voor alle resources"
  type        = string
}

variable "location" {
  description = "Azure locatie"
  type        = string
  default     = "westeurope"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "image_name" {
  description = "Naam van de image in ACR"
  type        = string
}

variable "environment" {
  description = "De omgeving van de resources (dev, test, prod)"
  type        = string
}

variable "project" {
  description = "Naam van het project"
  type        = string
}

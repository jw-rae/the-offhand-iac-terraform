variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "container_image" {
  description = "Full GHCR image URL (e.g. ghcr.io/username/the-offhand:latest)"
  type        = string
}

variable "ghcr_username" {
  description = "GitHub username for GHCR authentication (only needed for private images)"
  type        = string
  default     = ""
}

variable "ghcr_token" {
  description = "GitHub PAT with read:packages scope (only needed for private images)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "neon_connection_string" {
  description = "Neon PostgreSQL connection string"
  type        = string
  sensitive   = true
}

variable "payload_secret" {
  description = "Payload CMS secret"
  type        = string
  sensitive   = true
}

variable "nextauth_url" {
  description = "Public URL of the site (e.g. https://the-offhand.com)"
  type        = string
}

variable "nextauth_secret" {
  description = "NextAuth secret"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    project     = "the-offhand"
    environment = "prod"
  }
}

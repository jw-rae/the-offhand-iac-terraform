resource "azurerm_resource_group" "main" {
  name     = "the-offhand-rg-001"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "media" {
  name                     = "theoffhandmedia001"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_storage_container" "media" {
  name                  = "media"
  storage_account_name  = azurerm_storage_account.media.name
  container_access_type = "private"
}

resource "azurerm_container_app_environment" "main" {
  name                = "the-offhand-env-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_container_app" "main" {
  name                         = "the-offhand-app-001"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = var.tags

  secret {
    name  = "neon-connection-string"
    value = var.neon_connection_string
  }

  secret {
    name  = "payload-secret"
    value = var.payload_secret
  }

  secret {
    name  = "nextauth-secret"
    value = var.nextauth_secret
  }

  secret {
    name  = "s3-access-key"
    value = azurerm_storage_account.media.primary_access_key
  }

  dynamic "secret" {
    for_each = var.ghcr_token != "" ? [1] : []
    content {
      name  = "ghcr-token"
      value = var.ghcr_token
    }
  }

  dynamic "registry" {
    for_each = var.ghcr_token != "" ? [1] : []
    content {
      server               = "ghcr.io"
      username             = var.ghcr_username
      password_secret_name = "ghcr-token"
    }
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "the-offhand"
      image  = var.container_image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name  = "PORT"
        value = "3000"
      }

      env {
        name        = "DATABASE_URL"
        secret_name = "neon-connection-string"
      }

      env {
        name        = "PAYLOAD_SECRET"
        secret_name = "payload-secret"
      }

      env {
        name        = "NEXTAUTH_SECRET"
        secret_name = "nextauth-secret"
      }

      env {
        name  = "NEXTAUTH_URL"
        value = var.nextauth_url
      }

      env {
        name  = "NEXT_PUBLIC_SITE_URL"
        value = var.nextauth_url
      }

      env {
        name  = "S3_ENDPOINT"
        value = "https://${azurerm_storage_account.media.name}.blob.core.windows.net"
      }

      env {
        name  = "S3_BUCKET"
        value = azurerm_storage_container.media.name
      }

      env {
        name        = "S3_ACCESS_KEY"
        secret_name = "s3-access-key"
      }

      env {
        name        = "S3_SECRET_KEY"
        secret_name = "s3-access-key"
      }

      volume_mounts {
        name = "tmp"
        path = "/tmp"
      }
    }

    volume {
      name         = "tmp"
      storage_type = "EmptyDir"
      storage_name = "tmp"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

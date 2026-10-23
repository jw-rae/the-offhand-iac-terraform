# the-offhand — Terraform Infrastructure

Terraform manages the Azure infrastructure for **the-offhand**:

- Azure Resource Group
- Azure Container Apps Environment
- Azure Container App (Next.js + Payload CMS)
- Azure Storage Account and media container

The Container App serves the site on `theoffhand.com` and `www.theoffhand.com`.
It uses Neon PostgreSQL for the database and Azure Blob Storage for media.

## Architecture

```
Namecheap DNS
    ├── theoffhand.com ──────┐
    └── www.theoffhand.com ──┴──► Azure Container App
                                      ├── Next.js + Payload CMS
                                      ├── Neon PostgreSQL
                                      └── Azure Blob Storage

GitHub Actions (the-offhand-app/ci.yml)
    └── builds an image, pushes it to GHCR, deploys it to the Container App
```

Custom domains and their managed certificates are configured on the Container
App in Azure. Terraform intentionally ignores changes to the Container App's
image, replica counts, and custom-domain bindings: the app pipeline manages
image deployments, replicas are adjusted separately, and the existing domains
are retained in Azure.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) authenticated (`az login`)
- A GHCR image pushed by the app repository's CI workflow
- Neon PostgreSQL database provisioned separately

## Azure Authentication

```bash
az login
az account set --subscription "<your-subscription-id>"
```

Or use service principal environment variables:

```bash
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

## Setup

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Description | Sensitive | Required |
|---|---|---|---|
| `container_image` | Initial GHCR image URL | No | Yes |
| `neon_connection_string` | Neon PostgreSQL connection string | Yes | Yes |
| `payload_secret` | Payload CMS secret | Yes | Yes |
| `nextauth_url` | Public app URL (e.g. `https://www.theoffhand.com`) | No | Yes |
| `nextauth_secret` | NextAuth secret | Yes | Yes |
| `ghcr_enabled` | Enable GHCR registry auth for a private image | No | No |
| `ghcr_username` | GitHub username for private GHCR images | No | No |
| `ghcr_token` | GitHub PAT with `read:packages` scope | Yes | No |
| `location` | Azure region (default: `westeurope`) | No | No |

## Outputs

| Output | Description |
|---|---|
| `resource_group_name` | Resource group name |
| `container_app_environment_name` | Container Apps environment name |
| `container_app_name` | Container App name |
| `container_app_fqdn` | Default Container App FQDN |

## Container App secrets

Terraform configures these secrets on the Container App:

| Secret | Description |
|---|---|
| `neon-connection-string` | Neon PostgreSQL connection string |
| `payload-secret` | Payload CMS secret |
| `nextauth-secret` | NextAuth secret |
| `azure-storage-connection-string` | Azure Storage connection string |
| `ghcr-token` | Added only when private GHCR authentication is enabled |

## CI/CD

The app repository's `ci.yml` workflow builds the CMS image, pushes it to GHCR,
and deploys the commit-tagged image to the Container App. Terraform provisions
the app but ignores later image changes so it does not roll back pipeline
deployments.

## Destroy

```bash
terraform destroy
```

This removes Azure resources managed by Terraform. Neon, GitHub, and Namecheap
are managed separately.

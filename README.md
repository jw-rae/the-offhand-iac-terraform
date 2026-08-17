# the-offhand — Terraform Infrastructure

Azure Container Apps deployment for **the-offhand** (Next.js + Payload CMS on Neon PostgreSQL).

## Architecture

```
Namecheap (DNS configured manually)
    │
    ▼
Azure Container Apps  ──►  Next.js + Payload CMS  ──►  Neon PostgreSQL
                              │
                              ▼
                        Azure Blob Storage
                         (media container)
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) authenticated (`az login`)
- A GHCR image pushed (e.g. `ghcr.io/yourusername/the-offhand:latest`)
- Neon PostgreSQL database provisioned manually

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
```

## Commands

```bash
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Description | Sensitive | Required |
|---|---|---|---|
| `container_image` | GHCR image URL (e.g. `ghcr.io/user/repo:tag`) | No | Yes |
| `neon_connection_string` | Neon PostgreSQL connection string | Yes | Yes |
| `payload_secret` | Payload CMS secret | Yes | Yes |
| `nextauth_url` | Public site URL (e.g. `https://the-offhand.com`) | No | Yes |
| `nextauth_secret` | NextAuth secret | Yes | Yes |
| `ghcr_username` | GitHub username for private GHCR images | No | No |
| `ghcr_token` | GitHub PAT with `read:packages` scope | Yes | No |
| `location` | Azure region (default: `westeurope`) | No | No |

## Outputs

| Output | Description |
|---|---|
| `resource_group_name` | Azure resource group name |
| `container_app_environment_name` | Container Apps environment name |
| `container_app_name` | Container App name |
| `container_app_latest_revision_name` | Latest revision name |
| `container_app_fqdn` | FQDN for DNS CNAME configuration |

## Secrets

Secrets are stored as Container App secrets (never committed to git):

| Secret | Description |
|---|---|
| `neon-connection-string` | Neon PostgreSQL connection string |
| `payload-secret` | Payload CMS secret |
| `nextauth-secret` | NextAuth secret |
| `s3-access-key` | Azure Storage access key (used for both S3_ACCESS_KEY and S3_SECRET_KEY) |

If your GHCR image is private, a fifth secret `ghcr-token` is also created.

## DNS (Namecheap)

After `terraform apply`, configure Namecheap DNS:

1. Go to Namecheap **Domain List** → **Manage** → **Advanced DNS**
2. Add a **CNAME record**: `www` → `<container_app_fqdn>` from Terraform output
3. Or add **A records** pointing to the Container App IP addresses

## Cost Estimate

| Resource | Spec | Approx. Cost |
|---|---|---|
| Container App (Consumption) | 0.25 vCPU / 0.5 GiB, 0-1 replicas | ~$0-5/mo |
| Container Apps Environment | Consumption only | Free tier |
| Blob Storage | Standard LRS, pay-per-use | ~$0-1/mo |

Total: **under $5/month** for a low-traffic personal site. Scales to zero when idle.

## Destroy

```bash
terraform destroy
```

This removes all Azure resources. Neon and Namecheap are managed separately.

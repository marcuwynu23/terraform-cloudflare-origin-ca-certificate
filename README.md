# terraform-cloudflare-origin-ca-certificate

This Terraform project provisions a Cloudflare Origin CA Certificate using the official Cloudflare Terraform provider. It generates a private key, creates a CSR, and submits it to Cloudflare to obtain an Origin CA certificate for securing traffic between Cloudflare and your origin server.

## Features

- Generates an RSA private key and Certificate Signing Request (CSR)
- Provisions a Cloudflare Origin CA Certificate via Infrastructure as Code
- Configurable hostnames, request type, and certificate validity
- Optionally enforces Full (Strict) SSL mode on your zone
- Exports certificate and private key as local files for origin server configuration
- Sensitive values (API token, private key, certificate) are marked sensitive

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.0`
- A [Cloudflare account](https://dash.cloudflare.com/sign-up)
- A Cloudflare API Token with **Zone SSL and Certificates Edit** permissions
- Your Cloudflare **Zone ID**

### How to get your Cloudflare API Token

1. Log in to the [Cloudflare dashboard](https://dash.cloudflare.com/).
2. Go to **My Profile** → **API Tokens**, or open [this direct link](https://dash.cloudflare.com/profile/api-tokens).
3. Click **Create Token**.
4. Under **Custom token**, click **Get started**.
5. Give the token a descriptive name (e.g., `terraform-origin-ca`).
6. Under **Permissions**, add:
   - `Zone` → `SSL and Certificates` → `Edit`
7. Under **Zone Resources**, select the zone you want this token scoped to (e.g., `Include` → `Specific zone` → `example.com`).
8. (Optional) Set **TTL** and **IP Address Filtering** as needed.
9. Click **Continue to summary** → **Create Token**.
10. Copy the generated token immediately and store it securely — it won't be shown again.

> Use a scoped API token rather than your Global API Key for least-privilege access.

### How to get your Cloudflare Zone ID

1. Log in to the [Cloudflare dashboard](https://dash.cloudflare.com/).
2. Select the domain (zone) you want to manage.
3. On the **Overview** page, find **Zone ID** in the right sidebar under the **API** section.
4. Click the copy icon to copy it.

## Usage

### 1. Clone and configure

```bash
git clone https://github.com/marcuwynu23/terraform-cloudflare-origin-ca-certificate.git
cd terraform-cloudflare-origin-ca-certificate
cp terraform.tfvars.example terraform.tfvars
```

### 2. Set your values in `terraform.tfvars`

```hcl
cloudflare_api_token = "your-api-token-here"
zone_id              = "your-zone-id-here"
hostnames            = ["example.com", "*.example.com"]
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Preview changes

```bash
terraform plan
```

### 5. Apply

```bash
terraform apply
```

After applying, the certificate and private key files will be written to the module directory (`origin.pem` and `private.key`). Install these on your origin server.

### 6. Destroy (when no longer needed)

```bash
terraform destroy
```

## Variables

| Name                   | Description                                          | Type           | Default                            | Required |
| ---------------------- | ---------------------------------------------------- | -------------- | ---------------------------------- | :------: |
| `cloudflare_api_token` | Cloudflare API Token with SSL/Certificates Edit perm | `string`       | n/a                                |   yes    |
| `zone_id`              | Cloudflare Zone ID                                   | `string`       | n/a                                |   yes    |
| `hostnames`            | Hostnames to include in the certificate              | `list(string)` | `["example.com", "*.example.com"]` |    no    |
| `request_type`         | Certificate type: `origin-rsa` or `origin-ecc`       | `string`       | `origin-rsa`                       |    no    |
| `requested_validity`   | Certificate validity in days (max 5475 ≈ 15 years)   | `number`       | `5475`                             |    no    |

## Outputs

| Name                 | Description                           |
| -------------------- | ------------------------------------- |
| `origin_certificate` | The PEM-encoded Origin CA certificate |
| `private_key`        | The PEM-encoded private key (RSA)     |

## How It Works

1. **Private Key** — A 2048-bit RSA key is generated using the `tls_private_key` resource.
2. **CSR** — A Certificate Signing Request is created with the specified hostnames.
3. **Origin CA Certificate** — The CSR is submitted to Cloudflare, which issues an Origin CA certificate valid for the requested duration.
4. **SSL Mode** — The zone's SSL setting is set to `strict` (Full Strict) to enforce end-to-end encryption.
5. **Local Files** — The certificate and private key are written to local files for installation on your origin server.

## Installing on Your Origin Server

After `terraform apply`, copy the generated files to your server:

- `origin.pem` — the Origin CA certificate
- `private.key` — the private key

Example Nginx configuration:

```nginx
server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate     /etc/ssl/origin.pem;
    ssl_certificate_key /etc/ssl/private.key;

    # ...
}
```

## Security Notes

- `terraform.tfvars` and `*.tfstate` files are gitignored — never commit secrets
- The API token and private key variables are marked `sensitive` to prevent accidental log exposure
- The private key file is written with `0600` permissions
- Use a scoped API token rather than a Global API Key

## References

- [Cloudflare Origin CA certificates](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/)
- [Cloudflare Terraform provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [cloudflare_origin_ca_certificate resource](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/origin_ca_certificate)

## License

MIT

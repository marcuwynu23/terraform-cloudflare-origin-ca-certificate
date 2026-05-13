# Step 1: Generate a private key
resource "tls_private_key" "origin_ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Step 2: Create a Certificate Signing Request (CSR)
resource "tls_cert_request" "origin_ca" {
  private_key_pem = tls_private_key.origin_ca.private_key_pem

  subject {
    common_name  = var.hostnames[0]
    organization = "Origin CA"
  }

  dns_names = var.hostnames
}

# Step 3: Submit the CSR to Cloudflare and get an Origin CA cert
resource "cloudflare_origin_ca_certificate" "this" {
  csr                = tls_cert_request.origin_ca.cert_request_pem
  hostnames          = var.hostnames
  request_type       = var.request_type
  requested_validity = var.requested_validity
}

# Step 4: Set SSL mode to Full (Strict) on the zone
resource "cloudflare_zone_setting" "ssl" {
  zone_id    = var.zone_id
  setting_id = "ssl"
  value      = "strict"
}

# Step 5: Write certificate and key to local files
resource "local_file" "origin_cert" {
  content  = cloudflare_origin_ca_certificate.this.certificate
  filename = "${path.module}/origin.pem"
}

resource "local_file" "private_key" {
  content         = tls_private_key.origin_ca.private_key_pem
  filename        = "${path.module}/private.key"
  file_permission = "0600"
}

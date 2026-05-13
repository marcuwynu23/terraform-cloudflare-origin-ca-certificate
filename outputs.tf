output "origin_certificate" {
  description = "The PEM-encoded Origin CA certificate"
  value       = cloudflare_origin_ca_certificate.this.certificate
  sensitive   = true
}

output "private_key" {
  description = "The PEM-encoded private key"
  value       = tls_private_key.origin_ca.private_key_pem
  sensitive   = true
}

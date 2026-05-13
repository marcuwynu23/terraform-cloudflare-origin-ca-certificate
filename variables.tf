variable "cloudflare_api_token" {
  description = "Cloudflare API Token with SSL and Certificates Edit permissions"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
}

variable "hostnames" {
  description = "List of hostnames to include in the Origin CA certificate"
  type        = list(string)
  default     = ["example.com", "*.example.com"]
}

variable "request_type" {
  description = "Certificate request type: origin-rsa or origin-ecc"
  type        = string
  default     = "origin-rsa"
}

variable "requested_validity" {
  description = "Certificate validity in days (max 5475 = ~15 years)"
  type        = number
  default     = 5475
}

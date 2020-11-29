resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "cert" {
  key_algorithm   = tls_private_key.key.algorithm
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "Sonatina Examples"
  }

  # Certificate expires after one year.
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret" "certificate" {
  metadata {
    name = "ssl-certificate"
  }

  data = {
    "key.pem"  = tls_private_key.key.private_key_pem
    "cert.pem" = tls_self_signed_cert.cert.cert_pem
  }
}

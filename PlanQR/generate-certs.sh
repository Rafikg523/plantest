#!/bin/bash

# Script to generate self-signed SSL certificates for development
# Usage: ./generate-certs.sh [domain]

DOMAIN=${1:-localhost}
CERT_DIR="./certs"
DAYS_VALID=365

echo "Generating self-signed SSL certificates for: $DOMAIN"
echo "Certificates will be valid for $DAYS_VALID days"

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

# Generate private key
openssl genrsa -out "$CERT_DIR/cert.key" 2048

# Create OpenSSL configuration file with SAN extension
cat > "$CERT_DIR/openssl.cnf" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=PL
ST=West Pomeranian
L=Szczecin
O=PlanQR
CN=$DOMAIN

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = localhost
DNS.3 = *.localhost
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

# Generate certificate signing request with SAN
openssl req -new -key "$CERT_DIR/cert.key" -out "$CERT_DIR/cert.csr" -config "$CERT_DIR/openssl.cnf"

# Generate self-signed certificate with SAN extension
openssl x509 -req -days $DAYS_VALID -in "$CERT_DIR/cert.csr" -signkey "$CERT_DIR/cert.key" -out "$CERT_DIR/cert.pem" -extensions v3_req -extfile "$CERT_DIR/openssl.cnf"

# Generate PFX file for .NET (with password)
read -s -p "Enter password for PFX certificate: " PFX_PASSWORD
echo
openssl pkcs12 -export -out "$CERT_DIR/cert.pfx" -inkey "$CERT_DIR/cert.key" -in "$CERT_DIR/cert.pem" -password pass:$PFX_PASSWORD

# Clean up temporary files
rm "$CERT_DIR/cert.csr"
rm "$CERT_DIR/openssl.cnf"

echo ""
echo "✓ Certificates generated successfully in $CERT_DIR/"
echo "  - cert.key (Private Key)"
echo "  - cert.pem (Certificate)"
echo "  - cert.pfx (PFX for .NET)"
echo ""
echo "⚠ Remember to update the CertificateSettings__PfxPassword in your .env file"
echo "⚠ These are self-signed certificates for DEVELOPMENT only"

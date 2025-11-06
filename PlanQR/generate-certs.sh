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

# Generate certificate signing request
openssl req -new -key "$CERT_DIR/cert.key" -out "$CERT_DIR/cert.csr" -subj "/C=PL/ST=West Pomeranian/L=Szczecin/O=PlanQR/CN=$DOMAIN"

# Generate self-signed certificate
openssl x509 -req -days $DAYS_VALID -in "$CERT_DIR/cert.csr" -signkey "$CERT_DIR/cert.key" -out "$CERT_DIR/cert.pem"

# Generate PFX file for .NET (with password)
read -s -p "Enter password for PFX certificate: " PFX_PASSWORD
echo
openssl pkcs12 -export -out "$CERT_DIR/cert.pfx" -inkey "$CERT_DIR/cert.key" -in "$CERT_DIR/cert.pem" -password pass:$PFX_PASSWORD

# Clean up CSR file
rm "$CERT_DIR/cert.csr"

echo ""
echo "✓ Certificates generated successfully in $CERT_DIR/"
echo "  - cert.key (Private Key)"
echo "  - cert.pem (Certificate)"
echo "  - cert.pfx (PFX for .NET)"
echo ""
echo "⚠ Remember to update the CertificateSettings__PfxPassword in your .env file"
echo "⚠ These are self-signed certificates for DEVELOPMENT only"

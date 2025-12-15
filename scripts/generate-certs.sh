#!/bin/bash

# =============================================================================
# Enterprise mTLS Certificate Generator
# Generates complete PKI infrastructure for secure microservices communication
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="${SCRIPT_DIR}/../certs"
VALIDITY_DAYS=365
KEY_SIZE=2048

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          Enterprise mTLS Certificate Generator               ║"
    echo "║              Secure Microservices Infrastructure             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Clean up existing certificates
cleanup() {
    log_info "Cleaning up existing certificates..."
    rm -rf "${CERTS_DIR}"
    mkdir -p "${CERTS_DIR}"
    mkdir -p "${CERTS_DIR}/ca"
    mkdir -p "${CERTS_DIR}/backend"
    mkdir -p "${CERTS_DIR}/middleware"
    mkdir -p "${CERTS_DIR}/bff-user"
    mkdir -p "${CERTS_DIR}/bff-order"
}

# Generate Root CA
generate_root_ca() {
    log_info "Generating Root Certificate Authority..."
    
    # CA Private Key
    openssl genrsa -out "${CERTS_DIR}/ca/ca.key" ${KEY_SIZE}
    
    # CA Certificate
    openssl req -x509 -new -nodes \
        -key "${CERTS_DIR}/ca/ca.key" \
        -sha256 -days ${VALIDITY_DAYS} \
        -out "${CERTS_DIR}/ca/ca.crt" \
        -subj "/C=US/ST=Enterprise/L=Platform/O=TelecomPortal/OU=Security/CN=Enterprise-Root-CA"
    
    log_info "Root CA generated successfully"
}

# Generate certificate for a service
generate_service_cert() {
    local SERVICE_NAME=$1
    local SERVICE_DIR="${CERTS_DIR}/${SERVICE_NAME}"
    local CN=$2
    local SAN=$3
    
    log_info "Generating certificate for ${SERVICE_NAME}..."
    
    # Generate private key
    openssl genrsa -out "${SERVICE_DIR}/${SERVICE_NAME}.key" ${KEY_SIZE}
    
    # Create CSR config with SAN
    cat > "${SERVICE_DIR}/${SERVICE_NAME}.cnf" << EOF
[req]
default_bits = ${KEY_SIZE}
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
C = US
ST = Enterprise
L = Platform
O = TelecomPortal
OU = ${SERVICE_NAME}
CN = ${CN}

[req_ext]
subjectAltName = ${SAN}

[v3_ext]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = ${SAN}
EOF
    
    # Generate CSR
    openssl req -new \
        -key "${SERVICE_DIR}/${SERVICE_NAME}.key" \
        -out "${SERVICE_DIR}/${SERVICE_NAME}.csr" \
        -config "${SERVICE_DIR}/${SERVICE_NAME}.cnf"
    
    # Sign with CA
    openssl x509 -req \
        -in "${SERVICE_DIR}/${SERVICE_NAME}.csr" \
        -CA "${CERTS_DIR}/ca/ca.crt" \
        -CAkey "${CERTS_DIR}/ca/ca.key" \
        -CAcreateserial \
        -out "${SERVICE_DIR}/${SERVICE_NAME}.crt" \
        -days ${VALIDITY_DAYS} \
        -sha256 \
        -extensions v3_ext \
        -extfile "${SERVICE_DIR}/${SERVICE_NAME}.cnf"
    
    # Create PKCS12 keystore
    openssl pkcs12 -export \
        -in "${SERVICE_DIR}/${SERVICE_NAME}.crt" \
        -inkey "${SERVICE_DIR}/${SERVICE_NAME}.key" \
        -out "${SERVICE_DIR}/${SERVICE_NAME}.p12" \
        -name "${SERVICE_NAME}" \
        -CAfile "${CERTS_DIR}/ca/ca.crt" \
        -caname root \
        -password pass:changeit
    
    log_info "${SERVICE_NAME} certificate generated successfully"
}

# Create truststore with CA certificate
create_truststore() {
    log_info "Creating truststore with CA certificate..."
    
    # Convert CA cert to PKCS12 then to JKS truststore
    keytool -import -trustcacerts \
        -alias ca-root \
        -file "${CERTS_DIR}/ca/ca.crt" \
        -keystore "${CERTS_DIR}/truststore.p12" \
        -storetype PKCS12 \
        -storepass changeit \
        -noprompt
    
    # Copy truststore to each service directory
    cp "${CERTS_DIR}/truststore.p12" "${CERTS_DIR}/backend/"
    cp "${CERTS_DIR}/truststore.p12" "${CERTS_DIR}/middleware/"
    cp "${CERTS_DIR}/truststore.p12" "${CERTS_DIR}/bff-user/"
    cp "${CERTS_DIR}/truststore.p12" "${CERTS_DIR}/bff-order/"
    
    log_info "Truststore created and distributed"
}

# Verify certificates
verify_certificates() {
    log_info "Verifying certificate chain..."
    
    for service in backend middleware bff-user bff-order; do
        openssl verify -CAfile "${CERTS_DIR}/ca/ca.crt" "${CERTS_DIR}/${service}/${service}.crt"
    done
    
    log_info "All certificates verified successfully"
}

# Print summary
print_summary() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              Certificate Generation Complete                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "Generated certificates:"
    echo "  📁 ${CERTS_DIR}/ca/           - Root CA"
    echo "  📁 ${CERTS_DIR}/backend/      - Backend Service"
    echo "  📁 ${CERTS_DIR}/middleware/   - Security Gateway"
    echo "  📁 ${CERTS_DIR}/bff-user/     - User BFF"
    echo "  📁 ${CERTS_DIR}/bff-order/    - Order BFF"
    echo ""
    echo "Keystore password: changeit"
    echo "Truststore password: changeit"
    echo ""
    echo "mTLS Flow:"
    echo "  BFF → Middleware → Backend"
    echo ""
}

# Main execution
main() {
    print_header
    
    # Check for required tools
    command -v openssl >/dev/null 2>&1 || { log_error "OpenSSL is required but not installed."; exit 1; }
    command -v keytool >/dev/null 2>&1 || { log_error "keytool (Java) is required but not installed."; exit 1; }
    
    cleanup
    generate_root_ca
    
    # Generate service certificates with appropriate SANs
    generate_service_cert "backend" "backend.local" "DNS:localhost,DNS:backend.local,IP:127.0.0.1"
    generate_service_cert "middleware" "middleware.local" "DNS:localhost,DNS:middleware.local,IP:127.0.0.1"
    generate_service_cert "bff-user" "bff-user.local" "DNS:localhost,DNS:bff-user.local,IP:127.0.0.1"
    generate_service_cert "bff-order" "bff-order.local" "DNS:localhost,DNS:bff-order.local,IP:127.0.0.1"
    
    create_truststore
    verify_certificates
    print_summary
}

main "$@"

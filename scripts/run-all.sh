#!/bin/bash

# =============================================================================
# Enterprise Platform - Full Stack Launcher
# Starts all microservices with proper mTLS configuration
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."

# Service ports
BACKEND_PORT=9443
MIDDLEWARE_PORT=8443
BFF_USER_PORT=8081
BFF_ORDER_PORT=8082
FRONTEND_PORT=5173

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# PID tracking
PIDS=()
LOG_DIR="${PROJECT_ROOT}/logs"

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ████████╗███████╗██╗     ███████╗ ██████╗ ██████╗ ███╗   ███╗             ║
║   ╚══██╔══╝██╔════╝██║     ██╔════╝██╔════╝██╔═══██╗████╗ ████║             ║
║      ██║   █████╗  ██║     █████╗  ██║     ██║   ██║██╔████╔██║             ║
║      ██║   ██╔══╝  ██║     ██╔══╝  ██║     ██║   ██║██║╚██╔╝██║             ║
║      ██║   ███████╗███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║             ║
║      ╚═╝   ╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝             ║
║                                                                              ║
║              ENTERPRISE PORTAL - SECURE MICROSERVICES PLATFORM               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
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

log_service() {
    local service=$1
    local message=$2
    echo -e "${MAGENTA}[${service}]${NC} ${message}"
}

# Cleanup function for graceful shutdown
cleanup() {
    echo ""
    log_warn "Shutting down all services..."
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
    done
    log_info "All services stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :${port} -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Wait for service to be ready
wait_for_service() {
    local port=$1
    local service=$2
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if check_port "$port"; then
            log_service "$service" "Ready on port ${port}"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    log_error "${service} failed to start on port ${port}"
    return 1
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Java
    if ! command -v java &> /dev/null; then
        log_error "Java is required but not installed"
        exit 1
    fi
    
    JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 17 ]; then
        log_error "Java 17+ is required. Found version: $JAVA_VERSION"
        exit 1
    fi
    log_info "Java ${JAVA_VERSION} detected ✓"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is required but not installed"
        exit 1
    fi
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    log_info "Node.js v${NODE_VERSION} detected ✓"
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        log_error "npm is required but not installed"
        exit 1
    fi
    log_info "npm detected ✓"
    
    # Check certificates
    if [ ! -d "${PROJECT_ROOT}/certs/ca" ]; then
        log_warn "Certificates not found. Generating..."
        bash "${SCRIPT_DIR}/generate-certs.sh"
    fi
    log_info "Certificates present ✓"
}

# Check and kill process on port if needed
ensure_port_available() {
    local port=$1
    local service=$2
    
    if check_port "$port"; then
        log_warn "Port ${port} is in use. Attempting to free it..."
        local pid=$(lsof -Pi :${port} -sTCP:LISTEN -t 2>/dev/null)
        if [ -n "$pid" ]; then
            kill -9 "$pid" 2>/dev/null || true
            sleep 2
        fi
    fi
}

# Create logs directory
setup_logging() {
    mkdir -p "${LOG_DIR}"
    log_info "Logs directory: ${LOG_DIR}"
}

# Start Backend Service
start_backend() {
    log_service "BACKEND" "Starting on port ${BACKEND_PORT}..."
    
    ensure_port_available ${BACKEND_PORT} "Backend"
    
    cd "${PROJECT_ROOT}/backend"
    
    if [ ! -f "target/backend-0.0.1-SNAPSHOT.jar" ]; then
        log_service "BACKEND" "Building..."
        ./mvnw clean package -DskipTests -q
    fi
    
    java -jar target/backend-0.0.1-SNAPSHOT.jar \
        --server.port=${BACKEND_PORT} \
        > "${LOG_DIR}/backend.log" 2>&1 &
    
    PIDS+=($!)
    wait_for_service ${BACKEND_PORT} "BACKEND"
}

# Start Middleware (Security Gateway)
start_middleware() {
    log_service "MIDDLEWARE" "Starting Security Gateway on port ${MIDDLEWARE_PORT}..."
    
    ensure_port_available ${MIDDLEWARE_PORT} "Middleware"
    
    cd "${PROJECT_ROOT}/middleware"
    
    if [ ! -f "target/middleware-0.0.1-SNAPSHOT.jar" ]; then
        log_service "MIDDLEWARE" "Building..."
        ./mvnw clean package -DskipTests -q
    fi
    
    java -jar target/middleware-0.0.1-SNAPSHOT.jar \
        --server.port=${MIDDLEWARE_PORT} \
        > "${LOG_DIR}/middleware.log" 2>&1 &
    
    PIDS+=($!)
    wait_for_service ${MIDDLEWARE_PORT} "MIDDLEWARE"
}

# Start User BFF
start_bff_user() {
    log_service "BFF-USER" "Starting on port ${BFF_USER_PORT}..."
    
    ensure_port_available ${BFF_USER_PORT} "BFF-User"
    
    cd "${PROJECT_ROOT}/bff-user"
    
    if [ ! -f "target/bff-user-0.0.1-SNAPSHOT.jar" ]; then
        log_service "BFF-USER" "Building..."
        ./mvnw clean package -DskipTests -q
    fi
    
    java -jar target/bff-user-0.0.1-SNAPSHOT.jar \
        --server.port=${BFF_USER_PORT} \
        > "${LOG_DIR}/bff-user.log" 2>&1 &
    
    PIDS+=($!)
    wait_for_service ${BFF_USER_PORT} "BFF-USER"
}

# Start Order BFF
start_bff_order() {
    log_service "BFF-ORDER" "Starting on port ${BFF_ORDER_PORT}..."
    
    ensure_port_available ${BFF_ORDER_PORT} "BFF-Order"
    
    cd "${PROJECT_ROOT}/bff-order"
    
    if [ ! -f "target/bff-order-0.0.1-SNAPSHOT.jar" ]; then
        log_service "BFF-ORDER" "Building..."
        ./mvnw clean package -DskipTests -q
    fi
    
    java -jar target/bff-order-0.0.1-SNAPSHOT.jar \
        --server.port=${BFF_ORDER_PORT} \
        > "${LOG_DIR}/bff-order.log" 2>&1 &
    
    PIDS+=($!)
    wait_for_service ${BFF_ORDER_PORT} "BFF-ORDER"
}

# Start Frontend
start_frontend() {
    log_service "FRONTEND" "Starting on port ${FRONTEND_PORT}..."
    
    ensure_port_available ${FRONTEND_PORT} "Frontend"
    
    cd "${PROJECT_ROOT}/frontend"
    
    if [ ! -d "node_modules" ]; then
        log_service "FRONTEND" "Installing dependencies..."
        npm install --silent
    fi
    
    npm run dev > "${LOG_DIR}/frontend.log" 2>&1 &
    
    PIDS+=($!)
    wait_for_service ${FRONTEND_PORT} "FRONTEND"
}

# Print service URLs
print_urls() {
    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                         ALL SERVICES RUNNING                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${CYAN}🌐 Frontend (Enterprise Portal):${NC}"
    echo -e "   ${GREEN}http://localhost:${FRONTEND_PORT}${NC}"
    echo ""
    echo -e "${CYAN}🔌 API Endpoints:${NC}"
    echo -e "   User BFF:      ${GREEN}http://localhost:${BFF_USER_PORT}${NC}"
    echo -e "   Order BFF:     ${GREEN}http://localhost:${BFF_ORDER_PORT}${NC}"
    echo ""
    echo -e "${CYAN}🔐 Secure Services (mTLS):${NC}"
    echo -e "   Middleware:    ${GREEN}https://localhost:${MIDDLEWARE_PORT}${NC}"
    echo -e "   Backend:       ${GREEN}https://localhost:${BACKEND_PORT}${NC}"
    echo ""
    echo -e "${CYAN}📚 API Documentation:${NC}"
    echo -e "   Swagger (User BFF):   ${GREEN}http://localhost:${BFF_USER_PORT}/swagger-ui.html${NC}"
    echo -e "   Swagger (Order BFF):  ${GREEN}http://localhost:${BFF_ORDER_PORT}/swagger-ui.html${NC}"
    echo -e "   GraphQL Playground:   ${GREEN}http://localhost:${BFF_USER_PORT}/graphiql${NC}"
    echo ""
    echo -e "${CYAN}📁 Logs:${NC}"
    echo -e "   ${LOG_DIR}/"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
    echo ""
}

# Main execution
main() {
    print_banner
    check_prerequisites
    setup_logging
    
    log_info "Starting Enterprise Platform..."
    echo ""
    
    # Start services in order (dependencies first)
    start_backend
    start_middleware
    start_bff_user
    start_bff_order
    start_frontend
    
    print_urls
    
    # Keep script running and stream logs
    tail -f "${LOG_DIR}"/*.log 2>/dev/null &
    PIDS+=($!)
    
    # Wait for any process to exit
    wait
}

main "$@"

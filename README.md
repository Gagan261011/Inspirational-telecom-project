# 🚀 TelecomPro - Enterprise Telecom Shopping Platform

A **LOCAL-ONLY**, production-grade, enterprise telecom shopping platform with clean layered architecture, mTLS security, and premium UI inspired by Rogers.com and Proximus.com.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  CLIENT LAYER                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    React + TypeScript + Vite                                 │ │
│  │              TailwindCSS + Radix UI + Framer Motion                         │ │
│  │                        Port: 5173                                            │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────┬─────────────────────────────────────────┘
                                        │ HTTP
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              BFF LAYER (Backend For Frontend)                    │
│  ┌─────────────────────────────┐       ┌─────────────────────────────┐          │
│  │       BFF-User              │       │       BFF-Order             │          │
│  │   Spring Boot 3.2.0         │       │   Spring Boot 3.2.0         │          │
│  │   Port: 8081                │       │   Port: 8082                │          │
│  │                             │       │                             │          │
│  │   • Login/Register          │       │   • Products                │          │
│  │   • Profile Management      │       │   • Cart Operations         │          │
│  │   • Billing Info            │       │   • Order Management        │          │
│  └──────────────┬──────────────┘       └──────────────┬──────────────┘          │
└─────────────────┼──────────────────────────────────────┼────────────────────────┘
                  │ mTLS                                 │ mTLS
                  └──────────────────┬───────────────────┘
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           MIDDLEWARE / GATEWAY LAYER                             │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                     Security Gateway (mTLS)                                  │ │
│  │                     Spring Boot 3.2.0                                        │ │
│  │                     Port: 8443 (HTTPS)                                       │ │
│  │                                                                               │ │
│  │   • mTLS Client Certificate Validation                                       │ │
│  │   • Request Routing & Forwarding                                             │ │
│  │   • Security Enforcement                                                     │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────┬─────────────────────────────────────────┘
                                        │ mTLS
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                 BACKEND LAYER                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                     Core Backend Service                                     │ │
│  │                     Spring Boot 3.2.0                                        │ │
│  │                     Port: 9443 (HTTPS)                                       │ │
│  │                                                                               │ │
│  │   REST API        GraphQL          SOAP           H2 Database                │ │
│  │   /api/v1/*       /graphql         /ws/*          In-Memory                  │ │
│  │                                                                               │ │
│  │   Entities: User, Product, Order, Cart, Billing                              │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Microservice Architecture Overview

<img width="1354" height="617" alt="image" src="https://github.com/user-attachments/assets/dfeab76b-0f53-47d4-a6e9-b158d64392a8" />

<img width="1243" height="464" alt="image" src="https://github.com/user-attachments/assets/5b5de8ca-5779-4935-b69e-548378a5ba2e" />

<img width="1267" height="208" alt="image" src="https://github.com/user-attachments/assets/8e813bc4-a0df-4b8d-b410-259728a27ba1" />

<img width="1322" height="535" alt="image" src="https://github.com/user-attachments/assets/0d0d60f8-9573-4e73-9b34-23da28d4cad1" />

<img width="1334" height="308" alt="image" src="https://github.com/user-attachments/assets/11dd7d2a-f74b-4552-9126-b8a5ba2181ec" />

<img width="1279" height="431" alt="image" src="https://github.com/user-attachments/assets/07b81d6c-0150-40b2-81d6-9215f704ae9c" />

<img width="1213" height="391" alt="image" src="https://github.com/user-attachments/assets/9e8bd76e-c066-41f8-a5b8-3ec63bb3634a" />

<img width="1265" height="488" alt="image" src="https://github.com/user-attachments/assets/bfd29f2a-d2bd-4164-9a07-cdeab89db79c" />

<img width="1268" height="479" alt="image" src="https://github.com/user-attachments/assets/43bb79b9-a3cc-48cd-a381-6b473a321b94" />

<img width="1318" height="622" alt="image" src="https://github.com/user-attachments/assets/24a8ff72-f9ed-44fb-b789-4e0f59c80b17" />










## 🔐 Security Architecture (mTLS)

```
                    Certificate Authority (CA)
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
         Backend          Middleware        BFFs
         Certificate      Certificate      Certificates
              │               │               │
              └───────────────┼───────────────┘
                              │
                    Mutual TLS Handshake
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
         Client Auth     Server Auth    Chain Validation
         Required        Required       Enforced
```

### mTLS Flow:
1. **Certificate Generation**: OpenSSL creates CA, server, and client certificates
2. **Keystore Creation**: PKCS12 keystores generated for each service
3. **Trust Chain**: All services trust the common CA certificate
4. **Mutual Auth**: Both client and server validate certificates

## 🛠️ Technology Stack

## 🛠️ Sanity Report 

https://github.com/user-attachments/assets/bfa9624a-7297-40e8-8a98-07285b83c245







### Backend Services
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Spring Boot | 3.2.0 |
| Language | Java | 17+ |
| Build Tool | Maven | 3.9+ |
| Database | H2 (In-Memory) | Latest |
| API | REST + GraphQL + SOAP | - |

### Frontend
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | React | 18.2+ |
| Language | TypeScript | 5.3+ |
| Build Tool | Vite | 5.0+ |
| Styling | TailwindCSS | 3.4+ |
| UI Components | Radix UI | Latest |
| Animation | Framer Motion | 10+ |
| State | Zustand | 4.4+ |

## 📁 Project Structure

```
Inspirational-telecom-project/
├── 📜 README.md
├── 📂 scripts/
│   ├── generate-certs.sh      # Certificate generation
│   └── run-all.sh             # Full stack orchestration
├── 📂 backend/                 # Core backend service (Port 9443)
│   ├── pom.xml
│   └── src/main/java/com/telecompro/backend/
│       ├── entity/            # JPA Entities
│       ├── repository/        # Spring Data Repositories
│       ├── dto/               # Data Transfer Objects
│       ├── service/           # Business Logic
│       ├── controller/        # REST Controllers
│       ├── graphql/           # GraphQL Resolvers
│       └── config/            # Security & App Config
├── 📂 middleware/              # Security Gateway (Port 8443)
│   ├── pom.xml
│   └── src/main/java/com/telecompro/middleware/
│       ├── config/            # mTLS Configuration
│       └── controller/        # Gateway Controller
├── 📂 bff-user/                # User BFF (Port 8081)
│   ├── pom.xml
│   └── src/main/java/com/telecompro/bffuser/
│       ├── dto/               # User DTOs
│       ├── service/           # User Service
│       └── controller/        # User Controller
├── 📂 bff-order/               # Order BFF (Port 8082)
│   ├── pom.xml
│   └── src/main/java/com/telecompro/bfforder/
│       ├── dto/               # Order DTOs
│       ├── service/           # Order Service
│       └── controller/        # Order Controller
└── 📂 frontend/                # React Frontend (Port 5173)
    ├── package.json
    ├── vite.config.ts
    ├── tailwind.config.js
    └── src/
        ├── components/
        │   ├── ui/            # ShadCN-style components
        │   └── layout/        # Layout components
        ├── pages/             # Page components
        ├── store/             # Zustand store
        ├── lib/               # API & utilities
        └── hooks/             # Custom hooks
```

## 🚀 Quick Start

### Prerequisites
- **Java 17+** (JDK)
- **Node.js 18+** (with npm)
- **OpenSSL** (for certificate generation)
- **Maven 3.9+**
- **Bash** (Git Bash on Windows)

### 1. Generate Certificates

```bash
cd scripts
chmod +x generate-certs.sh
./generate-certs.sh
```

This creates:
- CA certificate and key
- Server certificates for backend, middleware, and BFFs
- PKCS12 keystores with password `changeit`

### 2. Start All Services

```bash
cd scripts
chmod +x run-all.sh
./run-all.sh
```

The script will:
1. Check for port availability
2. Start Backend (9443)
3. Start Middleware (8443)
4. Start BFF-User (8081)
5. Start BFF-Order (8082)
6. Start Frontend (5173)
7. Wait for all health checks

### 3. Access the Application

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:5173 | Main application |
| BFF-User | http://localhost:8081 | User operations |
| BFF-Order | http://localhost:8082 | Order operations |
| Middleware | https://localhost:8443 | Security gateway |
| Backend | https://localhost:9443 | Core API |
| H2 Console | https://localhost:9443/h2-console | Database console |

### Manual Startup (Alternative)

```bash
# Terminal 1 - Backend
cd backend
mvn spring-boot:run

# Terminal 2 - Middleware
cd middleware
mvn spring-boot:run

# Terminal 3 - BFF-User
cd bff-user
mvn spring-boot:run

# Terminal 4 - BFF-Order
cd bff-order
mvn spring-boot:run

# Terminal 5 - Frontend
cd frontend
npm install
npm run dev
```

## 📡 API Endpoints

### User BFF (Port 8081)
```
POST   /api/user/login          - User login
POST   /api/user/register       - User registration
GET    /api/user/{id}           - Get user profile
PUT    /api/user/{id}           - Update user profile
GET    /api/user/{id}/billing   - Get billing info
```

### Order BFF (Port 8082)
```
GET    /api/products            - List products
GET    /api/products/{id}       - Get product details
GET    /api/cart/{userId}       - Get user cart
POST   /api/cart/{userId}/add   - Add to cart
DELETE /api/cart/{userId}/item/{productId} - Remove from cart
GET    /api/orders/{userId}     - Get user orders
POST   /api/orders              - Create order
GET    /api/orders/{id}         - Get order details
POST   /api/payments            - Process payment
```

### Backend GraphQL (Port 9443)
```graphql
query {
  products { id name price category }
  product(id: 1) { id name description }
  users { id email firstName lastName }
}

mutation {
  createUser(input: { ... }) { id }
  createOrder(input: { ... }) { id }
}
```

## 🎨 UI Features

### Premium Design
- **Gradient Accents**: Purple-to-pink gradient theme
- **Glass Morphism**: Modern backdrop blur effects
- **Smooth Animations**: Framer Motion transitions
- **Responsive Layout**: Mobile-first design
- **Dark Mode Ready**: Full theme support

### Components
- Custom Button variants (gradient, outline, ghost)
- Card components with hover effects
- Toast notifications
- Modal dialogs
- Form inputs with validation
- Progress indicators
- Loading spinners

## 🔧 Configuration

### Backend (application.yml)
```yaml
server:
  port: 9443
  ssl:
    enabled: true
    key-store: classpath:certs/backend-keystore.p12
    key-store-password: changeit
    key-store-type: PKCS12
    trust-store: classpath:certs/truststore.p12
    trust-store-password: changeit
    client-auth: need
```

### Frontend Environment
```env
VITE_USER_BFF_URL=http://localhost:8081
VITE_ORDER_BFF_URL=http://localhost:8082
```

## 🧪 Demo Credentials

```
Email: john.doe@example.com
Password: password123
```

## 📊 Data Model

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    User     │────<│    Order    │>────│ OrderItem   │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id          │     │ id          │     │ id          │
│ email       │     │ userId      │     │ orderId     │
│ password    │     │ totalAmount │     │ productId   │
│ firstName   │     │ status      │     │ quantity    │
│ lastName    │     │ createdAt   │     │ price       │
│ phone       │     └─────────────┘     └─────────────┘
│ address     │
└─────────────┘
        │
        └────<┌─────────────┐
              │    Cart     │
              ├─────────────┤
              │ id          │
              │ userId      │>────┌─────────────┐
              │ items       │     │  CartItem   │
              └─────────────┘     ├─────────────┤
                                  │ productId   │
┌─────────────┐                   │ quantity    │
│   Product   │                   └─────────────┘
├─────────────┤
│ id          │
│ name        │
│ description │
│ price       │
│ category    │
│ stock       │
│ imageUrl    │
└─────────────┘
```

## 🛡️ Security Features

- **mTLS**: Mutual TLS authentication between all services
- **HTTPS**: All internal traffic encrypted
- **CORS**: Configured for frontend origin
- **Input Validation**: Server-side validation
- **Password Hashing**: BCrypt encryption

## 📝 Development Notes

### Adding New Features
1. Add entity/DTO in backend
2. Create repository and service
3. Add REST/GraphQL endpoint
4. Update BFF service
5. Add frontend components
6. Update store and API lib

### Troubleshooting
- **Port conflicts**: Check `netstat -an | grep LISTEN`
- **Certificate issues**: Regenerate with `generate-certs.sh`
- **Build failures**: Clear Maven cache `mvn clean`
- **Frontend errors**: Delete `node_modules` and reinstall

## 📄 License

MIT License - See LICENSE file for details.

---

Built with ❤️ using Spring Boot, React, and modern web technologies.

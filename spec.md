# Crypto Accounting Backend - Technical Specification

## Project Overview
A comprehensive Django-based cryptocurrency accounting system that integrates blockchain technology, AI analysis, and financial management tools. The system provides secure cryptocurrency transaction management, automated AI-powered analysis, real-time portfolio tracking, and comprehensive financial reporting capabilities for businesses and individuals managing cryptocurrency assets.

## Project Structure
```
crypto_accounting/
├── manage.py
├── master_automation.py
├── start.py
├── requirements.txt
├── README.md
├── crypto_project/                    # Django Project Configuration
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── wsgi.py
│   ├── asgi.py                       # WebSocket support
│   └── routing.py                    # WebSocket routing
├── crypto_api/                       # Main Django Application
│   ├── __init__.py
│   ├── apps.py
│   ├── urls.py
│   ├── controllers/                  # Business Logic Controllers
│   │   ├── __init__.py
│   │   ├── auth_controller.py
│   │   └── transaction_controller.py
│   ├── middleware/                   # Custom Middleware
│   │   ├── __init__.py
│   │   ├── auth_middleware.py
│   │   ├── request_middleware.py
│   │   ├── secure_middleware.py
│   │   └── websocket_middleware.py
│   ├── models/                       # Data Models
│   │   ├── __init__.py
│   │   ├── auth_legacy.py
│   │   ├── blockchain_models.py
│   │   ├── financial_models.py
│   │   ├── legacy_models.py
│   │   ├── payroll_models.py
│   │   ├── transaction_models.py
│   │   └── user_models.py
│   ├── services/                     # Service Layer
│   │   ├── __init__.py
│   │   ├── ai_service.py
│   │   ├── auth_service.py
│   │   ├── balance_sheet_service.py
│   │   ├── blockchain_service.py
│   │   ├── cash_flow_service.py
│   │   ├── contract_audit_service.py
│   │   ├── exchange_rate_service.py
│   │   ├── invoice_service.py
│   │   ├── notification_service.py
│   │   ├── payroll_service.py
│   │   ├── payslip_service.py
│   │   ├── task_queue_service.py
│   │   ├── tax_report_service.py
│   │   └── transaction_service.py
│   ├── urls/                         # URL Configuration
│   │   ├── __init__.py
│   │   ├── admin_urls.py
│   │   └── auth_urls.py
│   ├── utils/                        # Utility Functions
│   │   ├── __init__.py
│   │   ├── error_handlers.py
│   │   ├── eth_utils.py
│   │   ├── mongodb_utils.py
│   │   ├── serializers.py
│   │   └── token_utils.py
│   ├── views/                        # API Views
│   │   ├── __init__.py
│   │   ├── admin_panel_views.py
│   │   ├── admin_views.py
│   │   ├── api_views.py
│   │   ├── auth_views.py
│   │   ├── blockchain_views.py
│   │   ├── eth_endpoint_views.py
│   │   ├── integration_views.py
│   │   └── websocket_views.py
│   ├── management/                   # Django Management Commands
│   │   ├── __init__.py
│   │   └── commands/
│   └── tests/                        # Test Suite
│       └── __init__.py
├── mongodb_config/                   # MongoDB Configuration
│   └── mongod.conf
└── logs/                            # Application Logs
    ├── crypto_accounting.log
    └── security.log
```

## Technology Stack

### Backend Framework
- **Django 5.2.4**: Web application framework with REST API capabilities
- **Django REST Framework 3.16.0**: RESTful API development
- **Channels 4.0.0**: WebSocket support for real-time features
- **Channels Redis 4.1.0**: Redis channel layer for WebSocket scaling
- **ASGI/WSGI**: Asynchronous and synchronous server gateway interfaces
- **Uvicorn 0.30.6**: ASGI server for production deployment

### Database & Storage
- **MongoDB Atlas**: Primary database for flexible document storage
- **PyMongo 4.13.2**: MongoDB driver for Python
- **Djongo 1.2.31**: Django-MongoDB connector (hybrid ORM approach)
- **MongoEngine 0.29.1**: Document-Object Mapper for MongoDB

### Blockchain & Cryptocurrency
- **eth-account 0.12.0**: Ethereum account management and signing
- **Web3.py**: Ethereum blockchain interaction (via Infura/Ganache)
- **Infura API**: Ethereum mainnet access
- **Ganache**: Local blockchain for testing

### AI & Machine Learning
- **Local LLM Integration**: Custom AI service for transaction analysis
- **Granite 3.3 Model**: Local language model for classification
- **AI-powered analysis**: Transaction categorization and smart contract auditing

### Security & Authentication
- **bcrypt 4.1.2**: Password hashing
- **JWT Tokens**: JSON Web Token authentication
- **PyCryptodome 3.20.0**: Cryptographic operations
- **Custom Security Middleware**: Enhanced security headers and monitoring

### File Processing & Reports
- **openpyxl 3.1.2**: Excel file generation and processing
- **ReportLab 4.0.4**: PDF generation for reports and invoices
- **Schedule 1.2.0**: Task scheduling for automated processes

### External Integrations
- **Requests 2.31.0**: HTTP client for API integrations
- **python-dateutil 2.8.2**: Date/time parsing and manipulation
- **pytz 2025.2**: Timezone handling
- **dnspython 2.7.0**: DNS resolution utilities

## Database Schema

### Users Collection
```json
{
  "_id": "ObjectId",
  "username": "string (required, unique)",
  "email": "string (required, unique)",
  "password": "string (hashed with bcrypt)",
  "first_name": "string (required)",
  "last_name": "string (required)",
  "is_staff": "boolean (default: false)",
  "is_superuser": "boolean (default: false)",
  "role": "string (USER, MANAGER, ADMIN)",
  "is_active": "boolean (default: true)",
  "date_joined": "datetime",
  "last_login": "datetime",
  "email_verified": "boolean (default: false)",
  "verification_token": "string",
  "reset_password_token": "string",
  "reset_password_expires": "datetime",
  "session_token": "string",
  "session_approved": "boolean (default: false)",
  "max_wallets": "number (default: 10)",
  "wallet_address": "string", // Primary wallet address
  "company": "string", // Company name
  "department": "string", // Department
  "employee_id": "string (unique)", // Internal employee ID
  "phone_number": "string", // Contact number
  "last_login_ip": "string", // Last login IP address
  "failed_login_attempts": "number (default: 0)",
  "account_locked_until": "datetime", // Account lockout timestamp
  "manager_id": "ObjectId (ref: User)", // Manager reference
  "is_verified_by_manager": "boolean (default: false)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Wallets Collection
```json
{
  "_id": "ObjectId",
  "name": "string (required)",
  "address": "string (required, unique)", // Ethereum address
  "user_id": "ObjectId (ref: User, indexed)",
  "wallet_type": "string (required)", // "Private Key", "MetaMask", etc.
  "private_key": "string (encrypted)", // Stored encrypted
  "is_active": "boolean (default: true)",
  "balance": "decimal (default: 0)",
  "last_authenticated": "datetime",
  "monitoring_enabled": "boolean (default: false)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Cryptocurrencies Collection
```json
{
  "_id": "ObjectId",
  "name": "string (required)", // "Ethereum"
  "symbol": "string (required, unique, indexed)", // "ETH"
  "current_price": "decimal", // Current USD price
  "market_cap": "decimal",
  "volume_24h": "decimal",
  "price_change_24h": "decimal",
  "last_updated": "datetime",
  "is_active": "boolean (default: true)",
  "created_at": "datetime"
}
```

### Transactions Collection
```json
{
  "_id": "ObjectId",
  "transaction_type": "string (required)", // BUY, SELL, TRANSFER, INCOME, EXPENSE
  "wallet_id": "ObjectId (ref: Wallet, indexed)",
  "cryptocurrency_id": "ObjectId (ref: Cryptocurrency, indexed)",
  "amount": "decimal (required)", // Amount of cryptocurrency
  "price_at_transaction": "decimal", // Price when transaction occurred
  "transaction_date": "datetime (indexed)",
  "description": "string",
  "fee": "decimal (default: 0)", // Transaction fee
  "hash": "string", // Blockchain transaction hash
  "from_address": "string", // Source wallet address
  "to_address": "string", // Destination wallet address
  "gas_fee": "decimal",
  "gas_price": "decimal",
  "gas_used": "number",
  "block_number": "number",
  "status": "string (PENDING, CONFIRMED, FAILED)",
  // AI Classification Fields
  "ai_category": "string",
  "ai_subcategory": "string",
  "ai_confidence": "decimal",
  "ai_description": "string",
  "is_classified": "boolean (default: false)",
  // Business Fields
  "business_purpose": "string",
  "tax_category": "string",
  "is_business_expense": "boolean",
  // Exchange Rate Data
  "eth_usd_rate": "decimal",
  "usd_value": "decimal",
  "total_cost_usd": "decimal",
  "rate_timestamp": "datetime",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Portfolio Balances Collection
```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId (ref: User, indexed)",
  "cryptocurrency_id": "ObjectId (ref: Cryptocurrency, indexed)",
  "balance": "decimal (required)", // Current balance
  "avg_buy_price": "decimal", // Average purchase price
  "total_invested": "decimal", // Total amount invested
  "current_value": "decimal", // Current market value
  "unrealized_gain_loss": "decimal", // Unrealized P&L
  "last_updated": "datetime",
  "created_at": "datetime"
}
```

### Tax Reports Collection
```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId (ref: User, indexed)",
  "report_type": "string (DAILY, WEEKLY, MONTHLY, QUARTERLY, ANNUAL, CUSTOM)",
  "start_date": "date",
  "end_date": "date",
  "generated_at": "datetime",
  "total_gains": "decimal",
  "total_losses": "decimal",
  "net_gain_loss": "decimal",
  "taxable_events": "number",
  "total_fees": "decimal",
  "file_path": "string", // Path to generated PDF report
  "status": "string (GENERATING, COMPLETED, FAILED)",
  "ai_analysis": "string", // AI-generated analysis
  "tax_year": "number",
  "created_at": "datetime"
}
```

### Invoices Collection
```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId (ref: User)",
  "invoice_number": "string (required, unique)",
  "client_name": "string (required)",
  "client_email": "string",
  "client_address": "string",
  "issue_date": "date",
  "due_date": "date",
  "status": "string (DRAFT, SENT, PAID, OVERDUE, CANCELLED)",
  "subtotal": "decimal",
  "tax_rate": "decimal",
  "tax_amount": "decimal",
  "total_amount": "decimal",
  "currency": "string (default: USD)",
  "crypto_payment_address": "string", // Wallet address for crypto payments
  "crypto_currency": "string", // ETH, BTC, etc.
  "crypto_amount": "decimal",
  "items": [
    {
      "description": "string",
      "quantity": "number",
      "unit_price": "decimal",
      "total": "decimal"
    }
  ],
  "notes": "string",
  "file_path": "string", // Generated PDF path
  "sent_at": "datetime",
  "paid_at": "datetime",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Payroll Entries Collection
```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId (ref: User)",
  "employee_name": "string (required)",
  "employee_wallet": "string (required)", // Employee's crypto wallet
  "amount": "decimal (required)",
  "cryptocurrency": "string (required)", // ETH, BTC, etc.
  "pay_period_start": "date",
  "pay_period_end": "date",
  "payment_date": "date",
  "status": "string (PENDING, PROCESSING, COMPLETED, FAILED)",
  "transaction_hash": "string", // Blockchain transaction hash
  "gas_fee": "decimal",
  "net_amount": "decimal", // Amount after fees
  "description": "string",
  "employee_id": "string", // Internal employee ID
  "department": "string",
  "position": "string",
  "hourly_rate": "decimal",
  "hours_worked": "decimal",
  "overtime_hours": "decimal",
  "overtime_rate": "decimal",
  "deductions": [
    {
      "type": "string",
      "amount": "decimal",
      "description": "string"
    }
  ],
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Recurring Payments Collection
```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId (ref: User)",
  "payment_name": "string (required)",
  "recipient_name": "string (required)",
  "recipient_wallet": "string (required)",
  "amount": "decimal (required)",
  "cryptocurrency": "string (required)",
  "frequency": "string (DAILY, WEEKLY, MONTHLY, QUARTERLY, ANNUALLY)",
  "start_date": "date",
  "end_date": "date",
  "next_payment_date": "date",
  "last_payment_date": "date",
  "total_payments_made": "number (default: 0)",
  "is_active": "boolean (default: true)",
  "description": "string",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Financial Accounts Collection
```json
{
  "_id": "ObjectId",
  "account_code": "string (required, unique)", // "1000", "2000", etc.
  "account_name": "string (required)", // "Cash", "Accounts Payable"
  "account_type": "string (asset, liability, equity, revenue, expense)",
  "parent_account": "string", // Parent account code
  "description": "string",
  "is_active": "boolean (default: true)",
  "balance": "decimal (default: 0)",
  "currency": "string (default: USD)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Journal Entries Collection
```json
{
  "_id": "ObjectId",
  "entry_id": "string (required, unique)",
  "date": "datetime (required)",
  "description": "string (required)",
  "reference": "string", // Reference number
  "transaction_hash": "string", // Blockchain transaction hash
  "total_debit": "decimal (default: 0)",
  "total_credit": "decimal (default: 0)",
  "currency": "string (default: USD)",
  "status": "string (draft, posted, reversed)",
  "created_by": "string (required)",
  "created_at": "datetime",
  "posted_at": "datetime",
  "line_items": [
    {
      "account_code": "string",
      "description": "string",
      "debit_amount": "decimal",
      "credit_amount": "decimal"
    }
  ]
}
```

### Smart Contracts Collection
```json
{
  "_id": "ObjectId",
  "contract_address": "string (required, unique)", // "0x..."
  "contract_name": "string (required)",
  "contract_symbol": "string", // Token symbol if applicable
  "contract_type": "string (erc20, erc721, erc1155, custom)",
  "abi": "array", // Contract ABI as JSON array
  "bytecode": "string", // Contract bytecode
  "source_code": "string", // Solidity source code
  "compiler_version": "string",
  "network": "string (ethereum, polygon, bsc)",
  "deployment_transaction": "string", // Deployment tx hash
  "deployment_block": "number",
  "deployer_address": "string",
  "is_verified": "boolean (default: false)",
  "is_active": "boolean (default: true)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Payroll Periods Collection
```json
{
  "_id": "ObjectId",
  "period_id": "string (required, unique)",
  "start_date": "datetime (required)",
  "end_date": "datetime (required)",
  "pay_date": "datetime (required)",
  "status": "string (draft, processing, paid, cancelled)",
  "total_amount": "decimal (default: 0)",
  "currency": "string (default: USD)",
  "created_by": "string (required)",
  "created_at": "datetime",
  "processed_at": "datetime"
}
```

### Enhanced Payslips Collection
```json
{
  "_id": "ObjectId",
  "payslip_id": "string (required, unique)",
  "employee_id": "string (required)",
  "payroll_period_id": "string (required)",
  "gross_salary": "decimal (required)",
  "basic_salary": "decimal",
  "allowances": {
    "housing": "decimal",
    "transport": "decimal",
    "others": "decimal"
  },
  "deductions": {
    "tax": "decimal",
    "insurance": "decimal",
    "others": "decimal"
  },
  "overtime_hours": "decimal (default: 0)",
  "overtime_rate": "decimal (default: 0)",
  "overtime_amount": "decimal (default: 0)",
  "bonus_amount": "decimal (default: 0)",
  "net_salary": "decimal",
  "currency": "string (default: USD)",
  "payment_method": "string (crypto, bank, cash)",
  "wallet_address": "string", // For crypto payments
  "bank_details": "object", // For bank payments
  "payment_status": "string (pending, paid, failed)",
  "payment_date": "datetime",
  "payment_transaction_hash": "string",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### User Sessions Collection
```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId (ref: User)",
  "session_token": "string (required, unique)",
  "device_info": "string",
  "ip_address": "string",
  "is_active": "boolean (default: true)",
  "is_approved": "boolean (default: false)",
  "last_activity": "datetime",
  "expires_at": "datetime",
  "created_at": "datetime"
}
```
```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId (ref: User, indexed)",
  "type": "string (TRANSACTION, INVOICE, PAYROLL, SYSTEM, SECURITY)",
  "title": "string (required)",
  "message": "string (required)",
  "is_read": "boolean (default: false)",
  "priority": "string (LOW, MEDIUM, HIGH, CRITICAL)",
  "action_url": "string", // URL for action button
  "action_text": "string", // Text for action button
  "metadata": "object", // Additional data
  "expires_at": "datetime",
  "created_at": "datetime"
}
```

## Feature Specifications

### 1. Authentication & Security System

#### Multi-Factor Authentication
- **Email Verification**: Required for new account activation
- **Password Requirements**: Minimum 8 characters, complexity rules
- **Session Management**: Single-session authentication with approval system
- **Role-Based Access**: USER, MANAGER, ADMIN roles with permissions

#### Security Features
- **Password Hashing**: bcrypt with salt rounds
- **JWT Tokens**: Secure token-based authentication
- **Session Approval**: Device authentication before private key access
- **Security Middleware**: Custom headers, CORS protection, XSS prevention
- **Rate Limiting**: Protection against brute force attacks
- **Audit Logging**: Comprehensive security event logging

#### Employee Management
- **Team Structure**: Managers can add/remove employees
- **Role Assignment**: Dynamic role updates and permissions
- **Access Control**: Hierarchical access to sensitive data

### 2. Cryptocurrency Wallet Management

#### Multi-Wallet Support
- **Wallet Limit**: Up to 10 wallets per user
- **Wallet Types**: Private Key, MetaMask, Hardware wallet support
- **Address Validation**: Ethereum address format validation
- **Balance Tracking**: Real-time balance updates

#### Security Features
- **Private Key Encryption**: Secure storage with advanced encryption
- **Wallet Authentication**: Session approval for private key access
- **Monitoring System**: Automated wallet monitoring for new transactions
- **Address Uniqueness**: One wallet address per user constraint

### 3. Blockchain Integration

#### Ethereum Network Support
- **Mainnet Integration**: Infura API for production
- **Testnet Support**: Ganache for development and testing
- **Transaction Processing**: Send/receive ETH and ERC-20 tokens
- **Gas Management**: Gas price estimation and optimization

#### Transaction Features
- **Real-time Monitoring**: Automatic detection of new transactions
- **Transaction History**: Comprehensive transaction tracking
- **Block Confirmation**: Transaction status monitoring
- **Fee Calculation**: Accurate gas fee computation

### 4. AI-Powered Analysis

#### Transaction Classification
- **Local LLM Integration**: Granite 3.3 model for classification
- **Automated Categorization**: Business, personal, trading categories
- **Confidence Scoring**: AI confidence levels for classifications
- **Manual Override**: User can modify AI classifications

#### Smart Contract Auditing
- **Contract Analysis**: Security vulnerability detection
- **Risk Assessment**: Automated risk scoring
- **Audit Reports**: Detailed security analysis reports
- **Historical Audits**: Audit history and comparison

#### Tax Analysis
- **Period Reports**: Daily, weekly, monthly, quarterly, annual
- **Custom Periods**: User-defined date ranges
- **Gain/Loss Calculation**: Automated P&L computation
- **Tax Optimization**: AI-suggested tax strategies

### 5. Financial Management Tools

#### Invoice Generation
- **Professional Invoices**: PDF generation with company branding
- **Crypto Payments**: Support for cryptocurrency invoice payments
- **Email Integration**: Automated invoice sending
- **Status Tracking**: Invoice lifecycle management
- **Template System**: Customizable invoice templates

#### Payroll Management
- **Crypto Payroll**: Pay employees in cryptocurrency
- **Automated Scheduling**: Recurring payroll processing
- **Tax Calculations**: Payroll tax computation
- **Compliance**: Regulatory compliance features
- **Payslip Generation**: Automated payslip creation and distribution

#### Balance Sheet & Cash Flow
- **Financial Statements**: Automated balance sheet generation
- **Cash Flow Analysis**: Cash flow statement creation
- **Export Options**: Excel and PDF export capabilities
- **Period Comparison**: Historical financial comparison

### 6. Portfolio Management

#### Real-time Tracking
- **Portfolio Valuation**: Live portfolio value calculation
- **Performance Metrics**: ROI, P&L, percentage gains/losses
- **Asset Allocation**: Portfolio composition analysis
- **Historical Performance**: Time-series portfolio analysis

#### Exchange Rate Integration
- **Multi-Currency Support**: Real-time exchange rates
- **Price Alerts**: Cryptocurrency price notifications
- **Historical Rates**: Historical exchange rate data
- **Conversion Tools**: Currency conversion utilities

### 7. Reporting & Analytics

#### Tax Reporting
- **Automated Reports**: AI-generated tax reports
- **Multiple Formats**: PDF, Excel export options
- **Compliance Ready**: Tax authority compliant formats
- **Historical Analysis**: Multi-year tax analysis

#### Dashboard Analytics
- **Real-time Metrics**: Live portfolio and transaction data
- **Visual Charts**: Interactive data visualizations
- **Custom Periods**: Flexible date range selection
- **Export Capabilities**: Data export in multiple formats

### 8. Real-time Features & WebSocket Support

#### Real-time Dashboard Updates
- **Live Statistics**: Real-time dashboard statistics updates
- **Task Monitoring**: Live task execution monitoring
- **User Management**: Real-time user activity tracking
- **Manager Verification**: Live manager approval workflows

#### WebSocket Consumers
- **TaskLogsConsumer**: Real-time task execution logs
- **DashboardStatsConsumer**: Live dashboard statistics
- **UserManagementConsumer**: Real-time user management updates
- **ManagerVerificationConsumer**: Live manager verification workflow

#### Connection Management
- **Auto-reconnection**: Automatic WebSocket reconnection
- **Health Monitoring**: Connection health checks with ping/pong
- **Group Broadcasting**: Targeted message broadcasting to user groups
- **Periodic Updates**: Configurable update intervals (10-30 seconds)

### 9. Enhanced User Management

#### Employee Management System
- **Hierarchical Structure**: Manager-employee relationships
- **Team Management**: Add/remove employees from teams
- **Role Assignment**: Dynamic role updates (USER, MANAGER, ADMIN)
- **Employee Verification**: Manager approval workflow

#### User Profile Extensions
- **Company Information**: Company, department, employee ID
- **Contact Details**: Phone number, additional contact info
- **Security Features**: Failed login attempts, account locking
- **IP Tracking**: Last login IP address tracking

### 10. Advanced Financial Models

#### Chart of Accounts
- **Financial Accounts**: Complete chart of accounts structure
- **Account Types**: Assets, liabilities, equity, revenue, expenses
- **Hierarchical Structure**: Parent-child account relationships
- **Multi-currency Support**: Multiple currency handling

#### Journal Entries
- **Double-entry Bookkeeping**: Complete journal entry system
- **Blockchain Integration**: Link journal entries to blockchain transactions
- **Approval Workflow**: Draft, posted, reversed status tracking
- **Audit Trail**: Complete transaction history

#### Payroll System Enhancement
- **Payroll Periods**: Structured payroll period management
- **Payslip Generation**: Detailed payslip creation
- **Deductions & Allowances**: Flexible deduction and allowance handling
- **Overtime Calculations**: Automated overtime calculations
- **Multi-payment Methods**: Crypto, bank, cash payment options

### 11. Blockchain Model Extensions

#### Smart Contract Management
- **Contract Registry**: Complete smart contract information storage
- **ABI Management**: Contract ABI and bytecode storage
- **Multi-network Support**: Ethereum, Polygon, BSC networks
- **Contract Verification**: Source code verification and auditing
- **Deployment Tracking**: Contract deployment transaction tracking

#### Blockchain Network Support
- **Multi-chain Architecture**: Support for multiple blockchain networks
- **Network Configuration**: Configurable blockchain network settings
- **Cross-chain Operations**: Cross-chain transaction support

### 12. Automation & Scheduling

#### Background Tasks
- **Scheduled Processes**: Automated system maintenance
- **Transaction Monitoring**: Continuous blockchain monitoring
- **Report Generation**: Automated report scheduling
- **Email Notifications**: Automated alert system

#### Workflow Automation
- **Transaction Processing**: Automated transaction workflows
- **Classification Pipeline**: AI classification automation
- **Notification System**: Event-driven notifications
- **Data Synchronization**: Automated data updates

## API Endpoints

### Authentication Endpoints
```
POST /api/auth/register/                    # User registration
POST /api/auth/login/                       # User login
POST /api/auth/logout/                      # User logout
POST /api/auth/verify-email/                # Email verification
POST /api/auth/forgot-password/             # Password reset request
POST /api/auth/reset-password/              # Password reset
POST /api/auth/change-password/             # Password change
GET  /api/auth/profile/                     # Get user profile
PUT  /api/auth/profile/                     # Update user profile
POST /api/auth/confirm-password/            # Session approval
```

### Employee Management Endpoints
```
POST /api/auth/employees/add/               # Add new employee
GET  /api/auth/employees/                   # Get employees by manager
PUT  /api/auth/employees/{id}/status/       # Update employee status
POST /api/auth/employees/add-existing/      # Add existing employee to team
DELETE /api/auth/employees/{id}/remove/     # Remove employee from team
```

### Wallet Management Endpoints
```
GET    /api/wallets/                        # List user wallets
POST   /api/wallets/                        # Create new wallet
GET    /api/wallets/{id}/                   # Get wallet details
PUT    /api/wallets/{id}/                   # Update wallet
DELETE /api/wallets/{id}/                   # Delete wallet
GET    /api/wallets/{id}/balance/           # Get wallet balance
POST   /api/wallets/{id}/monitor/           # Enable wallet monitoring
```

### Transaction Endpoints
```
GET    /api/transactions/                   # List transactions
POST   /api/transactions/                   # Create transaction
GET    /api/transactions/{id}/              # Get transaction details
PUT    /api/transactions/{id}/              # Update transaction
DELETE /api/transactions/{id}/              # Delete transaction
GET    /api/transactions/history/           # Transaction history
GET    /api/transactions/category/{cat}/    # Transactions by category
POST   /api/transactions/classify/          # AI classify transaction
```

### Blockchain Endpoints
```
POST /api/blockchain/send-eth/              # Send ETH transaction
GET  /api/blockchain/transaction/{hash}/    # Get transaction details
GET  /api/blockchain/estimate-gas/          # Estimate gas fees
GET  /api/blockchain/transaction-status/{hash}/ # Transaction status
POST /api/blockchain/wallet-monitoring/     # Add wallet monitoring
```

### Portfolio Endpoints
```
GET  /api/portfolio/                        # Get portfolio balances
GET  /api/portfolio/value/                  # Get portfolio value
GET  /api/portfolio/performance/            # Portfolio performance metrics
GET  /api/portfolio/allocation/             # Asset allocation
GET  /api/portfolio/history/                # Portfolio history
```

### Tax Report Endpoints
```
GET    /api/tax-reports/                    # List tax reports
POST   /api/tax-reports/generate/           # Generate tax report
GET    /api/tax-reports/{id}/               # Get tax report
DELETE /api/tax-reports/{id}/               # Delete tax report
POST   /api/tax-reports/daily/              # Generate daily report
POST   /api/tax-reports/weekly/             # Generate weekly report
POST   /api/tax-reports/monthly/            # Generate monthly report
POST   /api/tax-reports/yearly/             # Generate yearly report
POST   /api/tax-reports/custom/             # Generate custom period report
```

### Invoice Management Endpoints
```
GET    /api/invoices/                       # List user invoices
POST   /api/invoices/                       # Create invoice
GET    /api/invoices/{id}/                  # Get invoice details
PUT    /api/invoices/{id}/                  # Update invoice
DELETE /api/invoices/{id}/                  # Delete invoice
POST   /api/invoices/{id}/send/             # Send invoice email
GET    /api/invoices/{id}/pdf/              # Get invoice PDF
PUT    /api/invoices/{id}/status/           # Update invoice status
GET    /api/invoices/templates/             # Get invoice templates
```

### Enhanced Payroll Endpoints
```
GET    /api/payroll/periods/               # List payroll periods
POST   /api/payroll/periods/               # Create payroll period
GET    /api/payroll/periods/{id}/          # Get payroll period details
PUT    /api/payroll/periods/{id}/          # Update payroll period
DELETE /api/payroll/periods/{id}/          # Delete payroll period
POST   /api/payroll/periods/{id}/process/  # Process payroll period

GET    /api/payslips/employee/{id}/        # Get employee payslips
POST   /api/payslips/{id}/approve/         # Approve payslip
GET    /api/payslips/{id}/download/        # Download payslip PDF
```

### Financial Accounting Endpoints
```
GET    /api/accounts/                      # List chart of accounts
POST   /api/accounts/                      # Create financial account
GET    /api/accounts/{id}/                 # Get account details
PUT    /api/accounts/{id}/                 # Update account
DELETE /api/accounts/{id}/                 # Delete account

GET    /api/journal-entries/               # List journal entries
POST   /api/journal-entries/               # Create journal entry
GET    /api/journal-entries/{id}/          # Get journal entry details
PUT    /api/journal-entries/{id}/          # Update journal entry
POST   /api/journal-entries/{id}/post/     # Post journal entry
POST   /api/journal-entries/{id}/reverse/  # Reverse journal entry
```

### Smart Contract Management Endpoints
```
GET    /api/contracts/                     # List smart contracts
POST   /api/contracts/                     # Register smart contract
GET    /api/contracts/{address}/           # Get contract details
PUT    /api/contracts/{address}/           # Update contract info
POST   /api/contracts/{address}/verify/    # Verify contract source
GET    /api/contracts/{address}/abi/       # Get contract ABI
POST   /api/contracts/{address}/interact/  # Interact with contract
```

### Employee Management Endpoints
```
GET    /api/employees/                     # List employees
POST   /api/employees/                     # Create employee
GET    /api/employees/{id}/                # Get employee details
PUT    /api/employees/{id}/                # Update employee
DELETE /api/employees/{id}/                # Delete employee
POST   /api/employees/{id}/verify/         # Verify employee (manager)
GET    /api/employees/team/{manager_id}/   # Get manager's team
```

### Payslip Endpoints
```
GET    /api/payslips/                       # List user payslips
POST   /api/payslips/                       # Create payslip
GET    /api/payslips/{id}/                  # Get payslip details
POST   /api/payslips/{id}/send/             # Send payslip email
GET    /api/payslips/{id}/pdf/              # Generate payslip PDF
POST   /api/payslips/{id}/process-payment/  # Process payslip payment
```

### Financial Reports Endpoints
```
POST /api/reports/balance-sheet/            # Generate balance sheet
POST /api/reports/cash-flow/                # Generate cash flow statement
GET  /api/reports/balance-sheets/           # List balance sheets
GET  /api/reports/cash-flows/               # List cash flow statements
GET  /api/reports/{id}/excel/               # Export report to Excel
GET  /api/reports/{id}/pdf/                 # Export report to PDF
```

### AI & Analysis Endpoints
```
POST /api/ai/classify-transaction/          # Classify transaction with AI
POST /api/ai/audit-contract/                # Audit smart contract
POST /api/ai/upload-contract/               # Upload contract for audit
GET  /api/ai/audits/                        # Get user audits
GET  /api/ai/audits/{id}/                   # Get audit details
GET  /api/ai/audit-statistics/              # Get audit statistics
GET  /api/ai/crypto-news/                   # Get crypto news
```

### Exchange Rate Endpoints
```
GET  /api/exchange-rates/                   # Get current exchange rates
POST /api/exchange-rates/convert/           # Convert crypto to fiat
GET  /api/exchange-rates/portfolio-value/   # Get portfolio value in fiat
```

### Notification Endpoints
```
GET    /api/notifications/                  # Get user notifications
POST   /api/notifications/                  # Create notification
PUT    /api/notifications/{id}/read/        # Mark notification as read
DELETE /api/notifications/{id}/             # Delete notification
```

### WebSocket Endpoints
```
# Real-time WebSocket connections
ws://api/ws/admin/task-logs/              # Real-time task execution logs
ws://api/ws/admin/dashboard-stats/        # Live dashboard statistics  
ws://api/ws/admin/user-management/        # Real-time user management
ws://api/ws/admin/manager-verification/   # Manager verification workflow
```

### Enhanced Dashboard & Analytics Endpoints
```
GET  /api/dashboard/                        # Get dashboard data
GET  /api/dashboard/insights/               # Get financial insights
GET  /api/dashboard/analytics/              # Get analytics data
```

### System Administration Endpoints
```
POST /api/system/run-tasks/                 # Run scheduled tasks
GET  /api/system/health/                    # System health check
POST /api/system/clear-cache/               # Clear system cache
GET  /api/system/automation/status/         # Automation status
POST /api/system/automation/start/          # Start automation
POST /api/system/automation/stop/           # Stop automation
```

## Security Considerations

### Data Protection
- **Encryption at Rest**: Sensitive data encrypted in MongoDB
- **Private Key Security**: Advanced encryption for wallet private keys
- **HTTPS Enforcement**: TLS encryption for all communications
- **Input Validation**: Comprehensive input sanitization
- **SQL Injection Prevention**: MongoDB NoSQL injection protection

### Authentication Security
- **Session Management**: Single-session with approval mechanism
- **Token Security**: JWT with secure signing and expiration
- **Password Requirements**: Strong password policies
- **Rate Limiting**: Brute force attack prevention
- **Device Approval**: Explicit approval for sensitive operations

### Network Security
- **CORS Configuration**: Secure cross-origin resource sharing
- **Security Headers**: Comprehensive security header implementation
- **XSS Protection**: Cross-site scripting prevention
- **CSRF Protection**: Cross-site request forgery protection
- **Content Security Policy**: Strict CSP implementation

### Audit & Monitoring
- **Security Logging**: Comprehensive security event logging
- **Transaction Monitoring**: Automated suspicious activity detection
- **Access Logging**: User action audit trails
- **Error Handling**: Secure error responses without data leakage

## Environment Configuration

### Environment Variables
```bash
# MongoDB Configuration
MONGODB_ATLAS_URI=mongodb+srv://username:password@cluster.mongodb.net/database

# Django Configuration
SECRET_KEY=your-secret-key-here
DEBUG=False
ALLOWED_HOSTS=your-domain.com,localhost

# Blockchain Configuration
INFURA_URL=https://mainnet.infura.io/v3/your-project-id
GANACHE_URL=http://127.0.0.1:7545
GANACHE_CHAIN_ID=1337

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
EMAIL_MOCK_MODE=false

# AI/LLM Configuration
LLM_API_KEY=your-llm-api-key
LLM_BASE_URL=https://your-llm-endpoint.com/v1/agents
LLM_MODEL_NAME=granite3.3

# Frontend URLs
FRONTEND_URL=https://your-frontend-domain.com
BACKEND_URL=https://your-backend-domain.com
```

### Database Indexes
```javascript
// Cryptocurrency Collection
db.cryptocurrency.createIndex({ "symbol": 1 }, { unique: true });

// Wallet Collection
db.wallet.createIndex({ "address": 1 }, { unique: true });
db.wallet.createIndex({ "user_id": 1 });

// Transaction Collection
db.transaction.createIndex({ "wallet_id": 1 });
db.transaction.createIndex({ "cryptocurrency_id": 1 });
db.transaction.createIndex({ "transaction_date": 1 });
db.transaction.createIndex({ "hash": 1 });

// Portfolio Balance Collection
db.portfolio_balance.createIndex({ "user_id": 1, "cryptocurrency_id": 1 }, { unique: true });

// Tax Report Collection
db.tax_report.createIndex({ "user_id": 1 });

// Invoice Collection
db.invoice.createIndex({ "user_id": 1 });
db.invoice.createIndex({ "invoice_number": 1 }, { unique: true });

// Notification Collection
db.notification.createIndex({ "user_id": 1 });
db.notification.createIndex({ "created_at": 1 });

// Financial Accounts Collection
db.financial_accounts.createIndex({ "account_code": 1 }, { unique: true });
db.financial_accounts.createIndex({ "account_type": 1 });
db.financial_accounts.createIndex({ "parent_account": 1 });

// Journal Entries Collection
db.journal_entries.createIndex({ "entry_id": 1 }, { unique: true });
db.journal_entries.createIndex({ "date": 1 });
db.journal_entries.createIndex({ "created_by": 1 });
db.journal_entries.createIndex({ "status": 1 });

// Smart Contracts Collection
db.smart_contracts.createIndex({ "contract_address": 1 }, { unique: true });
db.smart_contracts.createIndex({ "contract_name": 1 });
db.smart_contracts.createIndex({ "network": 1 });
db.smart_contracts.createIndex({ "contract_type": 1 });

// Payroll Periods Collection
db.payroll_periods.createIndex({ "period_id": 1 }, { unique: true });
db.payroll_periods.createIndex({ "start_date": 1 });
db.payroll_periods.createIndex({ "end_date": 1 });
db.payroll_periods.createIndex({ "status": 1 });

// Enhanced Payslips Collection
db.payslips.createIndex({ "payslip_id": 1 }, { unique: true });
db.payslips.createIndex({ "employee_id": 1 });
db.payslips.createIndex({ "payroll_period_id": 1 });
db.payslips.createIndex({ "payment_status": 1 });

// User Sessions Collection
db.user_sessions.createIndex({ "session_token": 1 }, { unique: true });
db.user_sessions.createIndex({ "user_id": 1 });
db.user_sessions.createIndex({ "expires_at": 1 });
```

## Deployment Requirements

### System Requirements
- **Python**: 3.8 or higher
- **MongoDB**: 4.4 or higher (MongoDB Atlas recommended)
- **Memory**: Minimum 2GB RAM (4GB recommended)
- **Storage**: SSD storage recommended for performance
- **Network**: Stable internet connection for blockchain APIs

### Production Deployment
- **WSGI Server**: Gunicorn or uWSGI for production
- **Reverse Proxy**: Nginx for static file serving and load balancing
- **SSL Certificate**: Valid SSL certificate for HTTPS
- **Process Management**: Systemd or Supervisor for process management
- **Monitoring**: Application monitoring and alerting setup

### Scalability Considerations
- **Database Sharding**: MongoDB Atlas auto-scaling capabilities
- **Caching**: Redis for session storage and caching
- **Load Balancing**: Multiple application instances behind load balancer
- **CDN**: Content delivery network for static assets
- **Background Tasks**: Celery with Redis/RabbitMQ for async tasks

This comprehensive technical specification provides a complete overview of the cryptocurrency accounting backend system, including its architecture, features, security considerations, and deployment requirements. The system is designed to be secure, scalable, and feature-rich for managing cryptocurrency assets and financial operations.
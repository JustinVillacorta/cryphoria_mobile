# Cryphoria Mobile - API Endpoints List

## Base URL Configuration
- **Android**: `http://10.250.148.205:8000`
- **iOS**: `http://192.168.5.53:8000`

---

## 1. Authentication Endpoints
**File**: `lib/features/data/data_sources/AuthRemoteDataSource.dart`

```
POST   /api/auth/login/                    # User login (line 59)
POST   /api/auth/register/                 # User registration (line 158)
POST   /api/auth/logout/                   # User logout (line 200)
POST   /api/auth/verify-email/             # Email/OTP verification (line 237)
POST   /api/auth/resend-otp/               # Resend OTP code (line 269)
POST   /api/auth/password-reset-request/   # Request password reset (line 299)
POST   /api/auth/password-reset/           # Reset password with OTP (line 331)
POST   /api/auth/change-password/          # Change current password (line 401)
GET    /api/auth/profile-mongodb/          # Get user profile (line 519)
PUT    /api/auth/profile-mongodb/          # Update user profile (line 467)
GET    /api/auth/sessions/validate/        # Validate current session (line 219)
GET    /api/auth/health/                   # Server health check (line 211)
```

---

## 2. Employee Management Endpoints
**File**: `lib/features/data/data_sources/employee_remote_data_source.dart`

```
GET    /api/auth/users/                    # Get all users/employees (line 40)
GET    /api/auth/employees/list/           # Get manager's team (lines 64, 176, 393)
POST   /api/auth/employees/add/            # Add employee to team (line 100)
PUT    /api/auth/users/update-role/        # Update employee role (line 155)
PUT    /api/auth/employees/update-status/  # Update employee status (line 199)
POST   /api/auth/employees/remove-from-team/ # Remove employee from team (line 581)
GET    /api/manager/payroll/employees/     # Get payroll employee data (line 399)
```

---

## 3. Wallet Management Endpoints
**File**: `lib/features/data/data_sources/walletRemoteDataSource.dart`

```
POST   /api/wallets/connect_wallet/        # Connect wallet with private key (line 18)
GET    /api/wallets/get_wallet_balance/    # Get wallet balance & info (line 49)
POST   /api/wallets/send_eth/              # Send ETH transaction (line 85)
DELETE /api/wallets/disconnect_wallet/     # Disconnect/remove wallet (line 140)
POST   /api/conversion/crypto-to-fiat/     # Convert crypto to fiat currency (line 179)
```

---

## 4. ETH Payment & Transaction Endpoints
**File**: `lib/features/data/data_sources/eth_payment_remote_data_source.dart`

```
POST   /api/eth/send/                      # Send ETH transaction (line 34)
POST   /api/eth/estimate-gas/              # Estimate gas for transaction (line 85)
GET    /api/eth/history/                   # Get transaction history (line 146)
POST   /api/eth/status/                    # Get transaction status (line 181)
GET    /api/eth/history/category/          # Get transactions by category (eth_transaction_data_source.dart line 17)
```

---

## 5. Smart Investment Endpoints
**File**: `lib/features/data/data_sources/smart_invest_remote_data_source.dart`

```
POST   /api/address-book/upsert/           # Add/update address book entry (line 31)
GET    /api/address-book/list/             # Get address book list (line 48)
DELETE /api/address-book/delete/           # Delete address book entry
```

---

## 6. Payroll Endpoints
**File**: `lib/features/data/data_sources/payroll_remote_data_source.dart`

```
GET    /api/payroll/periods/               # Get payroll periods (line 33)
POST   /api/payroll/periods/               # Create payroll period (line 52)
GET    /api/payroll/periods/{id}/          # Get specific period (line 74)
PUT    /api/payroll/periods/{id}/          # Update payroll period (line 92)
DELETE /api/payroll/periods/{id}/          # Delete payroll period (line 114)
POST   /api/payroll/periods/{id}/process/  # Process payroll period (line 132)
GET    /api/payroll/periods/{id}/entries/  # Get period entries (line 152)
GET    /api/payroll/periods/{id}/summary/  # Get payroll summary (line 229)
PUT    /api/payroll/entries/{id}/          # Update payroll entry (line 171)
POST   /api/payroll/entries/{id}/process/  # Process single entry (line 193)
GET    /api/payroll/employees/{id}/history/ # Get employee payroll history (line 211)
GET    /api/payroll/analytics/             # Get payroll analytics (line 262)
POST   /api/payroll/bulk-process/          # Bulk process payroll (line 282)
PUT    /api/payroll/bulk-update/           # Bulk update entries (line 303)
POST   /api/payroll/create/                # Create payroll entry (employee_remote_data_source.dart line 221)
GET    /api/payroll/schedule/              # Get payroll schedule (employee_remote_data_source.dart line 250)
```

---

## 7. Payslip Endpoints
**File**: `lib/features/data/data_sources/payslip_remote_data_source.dart`

```
GET    /api/payslips/list/                 # Get user payslips (line 50)
POST   /api/payslips/create/               # Create payslip (line 121)
POST   /api/payslips/generate-pdf/         # Generate payslip PDF (line 168)
POST   /api/payslips/send-email/           # Send payslip via email (line 204)
POST   /api/payslips/process-payment/      # Process payslip payment (line 237)
GET    /api/payslips/details/              # Get payslip details (line 268)
GET    /api/employee/payroll/details/      # Get employee payroll details (line 304)
GET    /api/employee/payroll/entry-details/ # Get payroll entry details (line 350)
```

---

## 8. AI Audit Endpoints
**File**: `lib/features/data/data_sources/audit_remote_data_source.dart`

```
POST   /api/ai/audit-contract/             # Submit contract for audit (line 47)
GET    /api/ai/audits/details/             # Get audit status/report (lines 79, 128)
GET    /api/ai/audits/list/                # Get user audit reports (line 163)
POST   /api/ai/upload-contract/            # Upload contract file (line 203)
DELETE /api/audit/{id}                     # Cancel audit (line 184)
GET    /api/contracts/{id}                 # Get contract details (line 272)
DELETE /api/contracts/{id}                 # Delete contract (line 287)
GET    /api/contracts/types                # Get supported contract types (line 298)
POST   /api/contracts/validate             # Validate contract code (line 745)
```

---

## 9. Financial Reports Endpoints
**File**: `lib/features/data/data_sources/audit_remote_data_source.dart`

```
GET    /api/financial/tax-report/list/     # Get tax reports (line 769)
GET    /api/balance-sheet/list/            # Get balance sheets (lines 907, 945)
GET    /api/cash-flow/list/                # Get cash flow statements (line 988)
GET    /api/portfolio/value/               # Get portfolio value (line 1457)
GET    /api/financial/income-statement/list/  # Get income statements (line 1544)
GET    /api/financial/investment-report/list/  # Get investment reports (line 1604)
```

---

## 10. Reports Generation Endpoints
**File**: `lib/features/data/data_sources/reports_remote_data_source.dart`

```
POST   /api/reports/generate/              # Generate report (line 25)
GET    /api/reports/status/                # Get report status (line 48)
GET    /api/reports/details/               # Get report details (line 70)
GET    /api/reports/list/                  # Get user reports (line 92)
GET    /api/reports/download/              # Download report (line 115)
POST   /api/reports/email/                 # Email report (line 138)
DELETE /api/reports/delete/                # Delete report (line 159)
```

---

## 11. Invoice Endpoints
**File**: `lib/features/data/data_sources/invoice_remote_data_source.dart`

```
GET    /api/invoices/list/                 # Get user invoices (lines 11, 44)
```

---

## 12. Document Upload Endpoints
**File**: `lib/features/data/data_sources/document_upload_remote_data_source.dart`

```
POST   /api/documents/upload/              # Upload business documents (lines 56, 85, 114)
POST   /api/documents/submit/              # Submit documents for approval (line 171)
GET    /api/documents/my-documents/        # Get user's documents (line 227)
```

---

## 13. Support Endpoints
**File**: `lib/features/data/data_sources/support_remote_data_source.dart`

```
POST   /api/support/submit/                # Submit support ticket (line 63)
GET    /api/support/messages/              # Get support messages (line 132)
```

---

## Summary Statistics
- **Total Endpoints**: 98
- **Authentication**: 12 endpoints
- **Employee Management**: 7 endpoints
- **Wallet & Blockchain**: 9 endpoints
- **Payroll & Payslips**: 24 endpoints
- **Financial Reports & Analysis**: 18 endpoints
- **AI Audit**: 9 endpoints
- **Reports Generation**: 7 endpoints
- **Invoices**: 1 endpoint
- **Documents**: 3 endpoints
- **Support**: 2 endpoints

## HTTP Client Configuration
**Location**: `lib/core/network/dio_client.dart`

- **HTTP Client**: Dio
- **Authentication**: Bearer token (auto-added via interceptor)
- **Timeout Settings**: 
  - Connect: 10 seconds
  - Receive: 90 seconds
- **Excluded from Auth**: `/api/auth/login/`, `/api/auth/register/`

## Standard Response Format
```json
{
  "success": true/false,
  "data": {},
  "message": "string",
  "error": "string (if success is false)"
}
```


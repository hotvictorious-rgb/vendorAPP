# Victorious MARKET — Sovereign Vendor & Merchant Terminal (`vendorAPP`)

> **FinTech-Grade Omnichannel Merchant Operating System**  
> Sovereign Terminal Exclusively for Physical Shop Owners & Sovereign Merchant Principals.  
> Strictly aligned with the `newVmarket` security core, BCMath 90% net merchant settlement, 48-hour bank cooldown protection, 6-digit courier handover PIN verification, and ₦0.00 in-shop inspection pass signoff.

---

## 🛡️ Core Security Invariants & Principles

1. **Untrusted Mobile Client Model**
   - The Flutter mobile application never computes ledger balances or payout amounts authoritatively.
   - All monetary calculations are performed by `newVmarket` backend using **BCMath 4-decimal precision** (`$subtotal * 0.9000`), strictly enforcing the 10% sovereign commission and 90% merchant settlement.
2. **48-Hour Bank Cooldown Anti-Tamper HUD**
   - Any modification to bank institution or 10-digit NUBAN account triggers an immediate 48-hour automated disbursement freeze via `VendorProfile::isWithinBankCooldown()`.
   - The terminal renders a glowing high-visibility security banner displaying exact remaining hours. Escrow and active sales continue normally, but withdrawals are locked to prevent account-takeover drain.
3. **6-Digit Courier Handover Verification**
   - Dispatch packages are never released on trust. When courier arrives, the vendor enters the courier’s device-generated 6-digit handover PIN (`/api/v1/vendor/orders/verify-handover-otp`).
   - Successful cryptographic match unlocks 90% escrow payout and certifies chain of custody.
4. **₦0.00 Upfront In-Shop Inspection Pass Signoff**
   - Physical store shoppers can reserve items with zero upfront deposit (`fee: 0.00`).
   - When the customer arrives in-store to inspect the item, the counter staff validates the 8-character pass code (`RES-XXXXXXXX`) via `/api/v1/vendor/pickup-reservations/verify-inspection` to finalize the sale.
5. **7-Day Freshness Lifecycle Assurance**
   - Food and perishable catalog listings expire every 7 days unless re-confirmed (`listing_confirmed_at`).
   - The vendor terminal provides a 1-tap freshness renewal action (`/api/v1/vendor/products/{id}/freshness`) to boost search ranking and maintain marketplace freshness guarantees.
6. **Zero-Trust Worker & Employee Isolation (Mathematical Barrier)**
   - Branch employees, counter staff, and workers are mathematically barred from accessing this mobile terminal ($P(\text{Auth} \mid \text{role} \ne \text{'vendor'}) = 0$).
   - Even with valid employee credentials, client gates wipe session storage immediately and backend middleware aborts with HTTP 403.
   - All employee duties must be executed exclusively through the separate authenticated **Web Counter Terminal** (`/counter`), preventing workers from ever viewing or altering sovereign merchant payout ledgers or NUBAN settlement banking configurations.

---

## 🎨 FinTech Visual Design System

- **Primary Colors:** Royal Purple (`#5E17EB`), Deep Obsidian (`#0D061E`), Midnight Purple Card Surface (`#190D38`), Obsidian Border (`#321E68`).
- **Accent Colors:** Rich Sovereign Gold (`#FFD700`), Emerald Success (`#10B981`), Amber Cooldown Alert (`#F59E0B`).
- **Typography:** Modern Google Fonts (`Plus Jakarta Sans`), ultra-clean hierarchy, high contrast for outdoor daylight retail visibility.
- **FinTech Eye Toggle:** One-tap balance masking (`₦ 284,500.00` ⇄ `₦ ••••••••`) for counter privacy when customers are standing near the terminal.

---

## 📱 Screen & Architecture Inventory

```
vendorAPP/
├── assets/
│   └── images/
│       ├── vm_icon.jpg           # Official VMarket App Icon
│       └── vic_logo.webp          # Victorious Brand Identity
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart # 13 Sovereign Vendor API Endpoints
│   │   │   ├── app_colors.dart    # Royal Purple, Gold & Obsidian Palette
│   │   │   └── app_constants.dart # Storage keys, timeouts & validation rules
│   │   ├── network/
│   │   │   ├── api_client.dart    # Dio client with Bearer Auth interceptor
│   │   │   └── api_exceptions.dart# Standardized RFC-7807 error parser
│   │   ├── services/
│   │   │   └── storage_service.dart# Encrypted token storage & balance privacy state
│   │   ├── theme/
│   │   │   └── app_theme.dart     # Material 3 FinTech Theme
│   │   └── utils/
│   │       └── currency_formatter.dart # ₦ Naira formatted with commas
│   ├── models/
│   │   ├── user_model.dart        # Merchant Owner & Counter Staff roles
│   │   ├── vendor_dashboard_model.dart # Net 90% revenue, escrow, telemetry
│   │   ├── vendor_order_model.dart# Status, net payout, delivery tracking
│   │   ├── vendor_reservation_model.dart # ₦0.00 inspection pass codes
│   │   ├── vendor_product_model.dart # 7-day freshness & stock status
│   │   └── vendor_payout_model.dart # NUBAN bank details & cooldown state
│   ├── providers/                 # PURE PROVIDER STATE MANAGEMENT ONLY
│   │   ├── vendor_auth_provider.dart
│   │   ├── vendor_dashboard_provider.dart
│   │   ├── vendor_orders_provider.dart
│   │   ├── vendor_reservations_provider.dart
│   │   ├── vendor_products_provider.dart
│   │   └── vendor_payout_provider.dart
│   ├── widgets/
│   │   ├── fintech_balance_card.dart  # Obsidian card with eye toggle & 90% badge
│   │   ├── cooldown_hud_card.dart     # 48h bank cooldown warning card
│   │   ├── handover_otp_dialog.dart   # 6-digit courier PIN input modal
│   │   └── inspection_code_dialog.dart# 8-char RES pass signoff modal
│   ├── screens/
│   │   ├── auth/vendor_login_screen.dart       # Login with 1-tap demo credentials
│   │   ├── shell/vendor_shell_screen.dart      # 5-tab persistent navigation shell
│   │   ├── dashboard/vendor_dashboard_screen.dart # Realtime telemetry & quick actions
│   │   ├── orders/
│   │   │   ├── vendor_orders_screen.dart       # Filterable order stream
│   │   │   └── vendor_order_detail_screen.dart # Line items & handover PIN prompt
│   │   ├── reservations/vendor_reservations_screen.dart # In-shop inspection passes
│   │   ├── products/
│   │   │   ├── vendor_products_screen.dart     # Catalog with 7d freshness tags
│   │   │   └── add_product_screen.dart         # Publish new catalog item
│   │   ├── payout/vendor_payout_screen.dart    # 10-digit NUBAN edit & cooldown status
│   │   └── account/vendor_account_screen.dart  # Dynamic API endpoint IP configurator
│   └── main.dart                  # MultiProvider root setup & theme initialization
├── preview/                       # Interactive Web Simulator for Instant Preview
│   ├── index.html                 # Smartphone Frame & FinTech Terminal Simulator
│   ├── style.css                  # FinTech CSS Design System
│   ├── app.js                     # Full Reactive State Engine
│   └── assets/                    # Preview brand images
├── pubspec.yaml                   # Flutter dependencies (Provider, Dio, Google Fonts)
└── analysis_options.yaml          # Strict Dart linter rules
```

---

## 🚀 How to Run the Applications

### 1. Interactive FinTech Web Simulator (Zero-Install Preview)
To immediately test the entire merchant terminal experience in your browser:
1. Double-click or open `preview/index.html` in Chrome, Edge, or Firefox.
2. Experience:
   - **Eye Toggle**: Tap eye icon to mask/unmask balance.
   - **Courier PIN Handover**: Navigate to Orders ➔ Tap "Verify Courier Handover PIN" on `VM-ORD-9081` ➔ Enter PIN `482910` ➔ Watch ₦37,800.00 release to Available Balance!
   - **In-Shop Inspection Signoff**: Tap "Sign Off Customer In-Shop Inspection" on `RES-884291` ➔ Click Confirm ➔ Certifies inspection and updates ledger.
   - **7-Day Freshness Renewal**: Go to Catalog ➔ Tap "Renew 7-Day Freshness" on expired items ➔ Watch status turn fresh green!
   - **Bank 48h Cooldown**: Go to Payouts ➔ Tap "Edit Bank" ➔ Submit new 10-digit NUBAN ➔ 48-Hour Cooldown banner activates immediately.

### 2. Flutter Mobile Application (Android / iOS / Desktop / Web)
Ensure Flutter 3.x and Dart 3.x are installed:
```bash
cd C:\Users\USER\Downloads\vendorAPP
flutter pub get
flutter run
```

### 3. Backend Test Suite Verification (`newVmarket`)
All 31 comprehensive backend tests for security hardening and vendor terminal APIs are 100% green:
```bash
cd C:\Users\USER\Downloads\newVmarket\backend
php artisan test --filter=SecurityHardeningAndAuditTest
php artisan test --filter=VendorApiTerminalTest
```
Result: **31 passed, 131 assertions green**.

---

## 🔒 Security Compliance
- **Zero Raw SQL / Zero Injection Vector**: All queries use Eloquent ORM with parameterized bindings.
- **Strict Role-Based Access Control**: `role: 'vendor_merchant'` and `role: 'vendor_staff'` enforced via Sanctum middleware.
- **Tamper-Evident Ledger**: Orders transition through explicit states (`pending` ➔ `processing` ➔ `ready_for_handover` ➔ `delivered`), releasing escrow only upon courier cryptographic OTP validation.

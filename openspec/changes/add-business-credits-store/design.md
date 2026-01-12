# Design: Business Credits Store

This document outlines the architectural and UI design for the Business Credits system.

## UI Design

Based on `design/magaza.html`, the `CreditStoreScreen` will feature:

### 1. Header
- Title: "Mağaza"
- Actions: Transaction History icon.

### 2. Balance Section (Premium Card)
- Background: Gradient (Premium look).
- Content:
  - "GOLD İŞLETME" badge.
  - Large balance display (e.g., "2.450 Kredi").
  - "Yükle" button (scrolls to packages).

### 3. Feature Showcase
- Horizontal/Grid display of what credits can be used for:
  - **Mağazada Öne Çık**: Reach top of lists and maps.
  - **Bildirim Gönder**: Send push notifications to followers.
  - **Kampanya Tanıtımı**: Reach thousands of new customers.

### 4. Credit Packages
- List of purchaseable packages:
  - **500 Kredi Paketi**: 299 TL (Başlangıç).
  - **1.000 Kredi Paketi**: 549 TL (En Popüler - Primary border).
  - **5.000 Kredi Paketi**: 2.499 TL (Profesyonel).
- "Satın Al" button for each.

## Database Schema

### `venue_credits`
Stores the current balance for each venue.
- `venue_id`: UUID (Primary Key, references venues.id)
- `balance`: BIGINT (Default 0, min 0)
- `updated_at`: TIMESTAMPTZ

### `credit_packages`
Definitions of packages available for purchase.
- `id`: UUID (Primary Key)
- `name`: TEXT
- `credit_amount`: INTEGER
- `price`: DECIMAL
- `description`: TEXT
- `is_popular`: BOOLEAN

### `credit_transactions`
History of credit changes.
- `id`: UUID (Primary Key)
- `venue_id`: UUID (References venues.id)
- `amount`: INTEGER (Positive for purchases, negative for usage)
- `type`: TEXT (e.g., 'purchase', 'usage_notification', 'usage_featured')
- `description`: TEXT
- `created_at`: TIMESTAMPTZ

## Logic
1. **Purchase**: Click package -> Trigger mock purchase -> Update `venue_credits.balance` -> Log in `credit_transactions`.
2. **State Management**: `CreditProvider` will fetch balance and packages, and handle the "purchase" action.
3. **RLS**: 
   - `venue_credits`: Owners can see their own venue's balance.
   - `credit_packages`: Public read.
   - `credit_transactions`: Owners can see their own venue's transactions.

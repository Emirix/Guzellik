# Tasks: Business Credits Store

Implementation plan for the credit system.

- [x] **Database Setup**
  - [x] Create `venue_credits`, `credit_packages`, and `credit_transactions` tables.
  - [x] Set up RLS policies for the new tables.
  - [x] Seed initial `credit_packages` (500, 1000, 5000 credits).
  - [x] Create a trigger/function to initialize `venue_credits` when a venue is created (or manually for existing).

- [x] **Data Layer (Flutter)**
  - [x] Create `CreditPackage` model.
  - [x] Create `CreditTransaction` model.
  - [x] Implement `CreditRepository` with methods:
    - `getBalance(String venueId)`
    - `getPackages()`
    - `getTransactions(String venueId)`
    - `purchasePackage(String venueId, String packageId)` (Mocked)

- [x] **Business Logic (Flutter)**
  - [x] Implement `CreditProvider` to manage credit state.
  - [x] Handle loading and error states for balance and packages.

- [x] **UI Implementation (Flutter)**
  - [x] Create `CreditStoreScreen` based on `design/magaza.html`.
  - [x] Implement `BalanceCard` component.
  - [x] Implement `FeatureShowcase` component.
  - [x] Implement `PackageList` and `PackageCard` components.
  - [x] Add "Credit Store" to the business bottom navigation or drawer.

- [x] **Verification**
  - [x] Verify credit balance updates after "purchase".
  - [x] Verify transaction logs are created in Supabase.
  - [x] UI visual check against `design/magaza.html`.

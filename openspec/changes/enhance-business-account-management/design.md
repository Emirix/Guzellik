# Design: Enhance Business Account Management

## Overview
This document outlines the architectural design for enhancing the business account management system. The goal is to move from a basic business flag to a robust, tiered subscription and credit-based management system.

## System Architecture

### 1. Subscription Tier System
The core of the enhancement is a tiered subscription model (Standard, Premium, Enterprise).
- **Data Model**: `business_subscriptions` table will store the current tier and a `features` JSONB object.
- **Why JSONB?**: Allows for flexible feature flags without frequent schema changes as new features are added.
- **Caching**: Subscription and feature data will be cached on the client side (e.g., using a Provider with a TTL) to avoid excessive RPC calls.

### 2. Feature Gating Logic
Feature gating will be implemented at multiple levels:
- **UI Level**: Components will use a `FeatureGatingService` to check access before rendering or enabling actions.
- **Application Logic**: Use cases/Repositories will verify access before performing sensitive operations.
- **Database Level (RLS)**: Row Level Security policies will ensure that users can only access data/actions they are entitled to.

### 3. Credit System
A credit-based system for transactional features (like campaign creation).
- **Transactions**: Every credit change (purchase, use, refund) is recorded in `credit_transactions` for auditability.
- **Concurrency**: Credits will be handled via Postgres functions (RPC) to ensure atomicity and prevent race conditions.

### 4. Analytics Pipeline
- **Tracking**: A middleware or dedicated utility will record usage events (venue views, etc.).
- **Storage**: `venue_views` table for raw data.
- **Performance**: Materialized views will be used for aggregated reports (e.g., "views last 30 days") to keep dashboard performance high.

## Technical Decisions

### materializing Analytics
Instead of querying the raw `venue_views` table (which will grow rapidly), we will use materialized views refreshed on a schedule. This balances data freshness with query performance.

### Credit Deduction Strategy
Credits will be deducted *at the moment of action* (e.g., campaign creation). If an action is reversed (e.g., campaign deleted quickly), a "Refund" transaction is created rather than deleting the original deduction.

## UI/UX Design Patterns

### The "Lock" Pattern
Features unavailable in the current tier will be visible but clearly marked as "Premium". This encourages upgrades by showing users what they are missing.

### Proactive Subscription Management
The system will detect expiring subscriptions and show contextual banners rather than total access cut-offs when possible (grace periods).

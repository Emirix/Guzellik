# Design: Supabase Backend Architecture

## Context
The application requires a scalable backend to manage venue information, user profiles, and a following system for notifications. Supabase provides a managed PostgreSQL database and authentication.

## Goals / Non-Goals
- **Goals**:
    - Relational database schema for venues and services.
    - Secure access via RLS policies.
    - Centralized notification dispatching via Edge Functions.
- **Non-Goals**:
    - Complex CMS for venue management (MVP focuses on core schema).
    - Advanced search indexing (initially using PG spatial queries).

## Decisions
- **Decision: Use PostgreSQL geographic types for venue location.**
    - Why: Enables efficient "nearby" searches directly in the database.
- **Decision: Row Level Security (RLS) for all tables.**
    - Why: Ensures data privacy and security at the database level.
- **Decision: JSONB for Complex Metadata.**
    - Why: Fields like `working_hours`, `payment_options`, and `expert_team` will be stored as JSONB to allow flexibility for different venue types without complex join overhead in the MVP.
- **Decision: Edge Function for FCM.**
    - Why: Abstracts FCM logic from the client and allows for future server-side triggers.

## Risks / Trade-offs
- **Risk: Cold starts for Edge Functions.**
    - Mitigation: Keep function logic minimal to minimize latency.

## Migration Plan
1. Apply SQL migrations to Supabase project.
2. Deploy Edge Functions.
3. Update Flutter app with configuration.

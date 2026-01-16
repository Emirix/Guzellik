# Capability: Performance Optimization

## MODIFIED Requirements

### Requirement: Use modern Color API for transparency
The application MUST use the `withValues(alpha: ...)` API instead of the deprecated/discouraged `withOpacity(...)` API for better performance and future compatibility with the Flutter engine.

#### Scenario: Refactor existing color transparency
- **Given** a widget or style using `Color.withOpacity(0.5)`
- **When** the performance refactor is applied
- **Then** it should be changed to `Color.withValues(alpha: 0.5)`
- **And** the visual appearance must remain identical

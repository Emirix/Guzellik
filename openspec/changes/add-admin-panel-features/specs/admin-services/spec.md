# Spec: Admin Services Management

## ADDED Requirements

### Requirement: Service Selection and Management
Venue owners must be able to select services from the service catalog and manage them through the admin panel.

#### Scenario: Viewing available services
**Given** a venue owner is logged into the admin panel  
**When** they navigate to the Services page  
**Then** they should see a list of all service categories  
**And** they should see which services they currently offer  
**And** they should see an "Add Service" button

#### Scenario: Adding a service from catalog
**Given** a venue owner clicks "Add Service"  
**When** they select a service from the `service_categories` catalog  
**Then** a new record should be created in `venue_services` table  
**And** the service should appear in their services list  
**And** the service should use default values from `service_categories`

#### Scenario: Customizing service details
**Given** a venue owner has added a service  
**When** they choose to customize pricing or duration  
**Then** they should be able to set `custom_price` and `custom_duration_minutes` in `venue_services`  
**And** these custom values should override the defaults from `service_categories`

#### Scenario: Adding custom photo and description
**Given** a venue owner wants to showcase a specific service  
**When** they upload a custom photo and enter a description  
**Then** a new record should be created in the `services` table  
**And** the photo and description should be associated with the `venue_service_id`  
**And** if no custom values are provided, defaults from `service_categories` should be used

#### Scenario: Reordering services
**Given** a venue owner has multiple services  
**When** they drag and drop to reorder services  
**Then** the display order should be updated  
**And** the new order should be reflected in the mobile app

#### Scenario: Disabling a service
**Given** a venue owner wants to temporarily hide a service  
**When** they toggle the service availability  
**Then** `venue_services.is_available` should be set to `false`  
**And** the service should not appear in mobile app search results  
**And** the service should still be visible in admin panel as "disabled"

#### Scenario: Removing a service
**Given** a venue owner wants to remove a service permanently  
**When** they delete the service  
**Then** the record should be removed from `venue_services` table  
**And** any associated custom data in `services` table should be cascade deleted  
**And** the service should no longer appear in the mobile app

### Requirement: Mobile App Integration
Services managed in the admin panel must be dynamically displayed in the Flutter mobile app.

#### Scenario: Displaying services in venue details
**Given** a venue has services configured in the admin panel  
**When** a user views the venue in `VenueDetailsScreen`  
**Then** all available services should be displayed in the Services tab  
**And** custom photos and descriptions should be shown when available  
**And** pricing and duration should reflect custom values if set

#### Scenario: Filtering venues by service
**Given** services are configured for multiple venues  
**When** a user filters search results by a specific service  
**Then** only venues offering that service (with `is_available = true`) should appear  
**And** the service should be highlighted in the search results

#### Scenario: Service data synchronization
**Given** a venue owner updates services in the admin panel  
**When** the changes are saved  
**Then** the mobile app should reflect the changes immediately  
**And** no app restart should be required  
**And** cached data should be invalidated

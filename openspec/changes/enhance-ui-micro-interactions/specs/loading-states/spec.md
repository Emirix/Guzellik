# Spec: Loading States

## ADDED Requirements

### Requirement: Shimmer Image Placeholders
Image loading placeholders must use shimmer effects instead of circular progress indicators to reduce perceived wait time and provide content structure hints.

#### Scenario: User views venue gallery
**Given** the user is viewing a venue detail page  
**And** the venue has gallery photos  
**When** gallery images are loading  
**Then** each image placeholder must display a shimmer effect  
**And** the shimmer must sweep from left to right  
**And** the shimmer base color must be `AppColors.gray200`  
**And** the shimmer highlight color must be `AppColors.gray100`  
**And** the shimmer animation duration must be 1.5 seconds  
**And** the placeholder shape must match the final image dimensions and border radius (12px)

#### Scenario: User views expert avatars
**Given** the user is viewing the expert team section  
**When** expert avatar images are loading  
**Then** each avatar placeholder must display a circular shimmer effect  
**And** the shimmer must sweep across the circular shape  
**And** the shimmer colors must match gallery shimmer (`gray200` base, `gray100` highlight)

#### Scenario: Image load failure
**Given** an image is loading with shimmer placeholder  
**When** the image fails to load (network error, broken URL)  
**Then** the shimmer must stop  
**And** an error icon (`Icons.image_not_supported`) must appear  
**And** the error state background must be `AppColors.gray100`

---

### Requirement: Shimmer Venue Cards
Venue cards in discovery and search screens must use shimmer skeletons while loading to maintain visual consistency and reduce perceived latency.

#### Scenario: User scrolls discovery feed
**Given** the user is on the discovery/home screen  
**And** venue data is being fetched from the server  
**When** the loading state is active  
**Then** 3-5 shimmer skeleton cards must be displayed  
**And** each skeleton must match the structure of a real venue card:  
  - Rectangular image placeholder (16:9 aspect ratio, 12px border radius)  
  - Two horizontal lines for venue name and address  
  - Small circular placeholder for rating badge  
**And** the shimmer animation must be synchronized across all skeleton cards

#### Scenario: User performs search
**Given** the user has entered a search query  
**When** search results are loading  
**Then** shimmer skeleton cards must replace the search results area  
**And** the number of skeletons must match the expected result count (default: 5)  
**And** skeletons must disappear when real results load

---

### Requirement: Accessibility - Reduce Motion Support
Shimmer animations must respect system accessibility settings to avoid triggering vestibular disorders or motion sensitivity.

#### Scenario: Reduce Motion enabled
**Given** the user has enabled "Reduce Motion" in system accessibility settings  
**When** any shimmer placeholder is displayed  
**Then** the sweeping shimmer animation must be disabled  
**And** the placeholder must show a static gradient (base color to highlight color, left to right)  
**Or** the placeholder must show a solid color (`AppColors.gray200`)

#### Scenario: Reduce Motion disabled (default)
**Given** the user has not enabled "Reduce Motion"  
**When** shimmer placeholders are displayed  
**Then** the full shimmer animation must play as designed

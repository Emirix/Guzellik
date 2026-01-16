# Spec: Visual Hierarchy

## ADDED Requirements

### Requirement: Gradient Avatar Backgrounds
Gender-based avatar backgrounds for experts without photos must use subtle gradients instead of flat colors to add depth and premium feel.

#### Scenario: Male expert without photo
**Given** an expert is registered in the system  
**And** the expert's gender is "male"  
**And** the expert has no profile photo  
**When** the expert avatar is displayed  
**Then** the avatar background must use a linear gradient  
**And** the gradient must start with `Color(0xFFE3F2FD)` (light blue) at top-left  
**And** the gradient must end with `Color(0xFFBBDEFB)` (slightly darker blue) at bottom-right  
**And** the avatar icon must be `Icons.person` in `Color(0xFF42A5F5)` (blue)

#### Scenario: Female expert without photo
**Given** an expert is registered in the system  
**And** the expert's gender is "female"  
**And** the expert has no profile photo  
**When** the expert avatar is displayed  
**Then** the avatar background must use a linear gradient  
**And** the gradient must start with `AppColors.avatarFemale` (0xFFFFEAF3) at top-left  
**And** the gradient must end with `Color(0xFFFFD6E8)` (slightly darker pink) at bottom-right  
**And** the avatar icon must be `Icons.person` in `AppColors.primary` (pink)

#### Scenario: Expert with unknown gender
**Given** an expert is registered in the system  
**And** the expert's gender is null or "unknown"  
**And** the expert has no profile photo  
**When** the expert avatar is displayed  
**Then** the avatar background must use a linear gradient  
**And** the gradient must start with `AppColors.gray100` at top-left  
**And** the gradient must end with `AppColors.gray200` at bottom-right  
**And** the avatar icon must be `Icons.person` in `AppColors.gray400`

---

### Requirement: Refined Section Dividers
Section dividers between content blocks must use subtle visual separators instead of solid gray boxes to reduce visual weight.

#### Scenario: User scrolls venue detail page
**Given** the user is viewing a venue detail page  
**When** scrolling through different sections (About, Experts, Working Hours, etc.)  
**Then** section dividers must appear between major content blocks  
**And** each divider must be one of the following styles:  
  - **Option A (Subtle Shadow)**: 8px height, `AppColors.nude` background with 30% opacity, subtle top shadow  
  - **Option B (Dashed Line)**: 1px height, dashed border using `AppColors.gray200`, 4px dash length, 4px gap  
**And** dividers must span the full width of the screen  
**And** dividers must have 24px vertical spacing above and below

#### Scenario: Design consistency check
**Given** section dividers are implemented  
**Then** all dividers must use the same style throughout the app  
**And** the chosen style must match the design prototype (`design/mekan-detay.html`)

---

### Requirement: Database-Driven Featured Experts
Expert highlighting must be driven by a database flag rather than hardcoded position to allow dynamic management.

#### Scenario: Admin marks expert as featured
**Given** an admin is managing a venue's expert team  
**When** the admin marks an expert as "featured" in the database  
**Then** the `specialists` table must have an `is_featured` boolean column  
**And** setting `is_featured = true` must persist to the database  
**And** the expert card must display with featured styling (glow effect) when loaded

#### Scenario: Multiple featured experts
**Given** a venue has multiple experts marked as featured  
**When** the expert team section is displayed  
**Then** all featured experts must show the glow effect  
**And** featured experts must appear before non-featured experts in the list  
**And** within featured experts, sorting must be by creation date (newest first)

#### Scenario: No featured experts
**Given** a venue has no experts marked as featured  
**When** the expert team section is displayed  
**Then** no expert cards must show the glow effect  
**And** experts must be sorted by creation date (newest first)

---

## MODIFIED Requirements

### Requirement: Expert Card Visual Emphasis (Modified from existing)
**Previous**: First expert in list gets a simple border  
**New**: Featured experts (database-driven) get a pink glow effect

#### Scenario: Featured expert display
**Given** an expert is marked as `is_featured = true` in the database  
**When** the expert card is rendered  
**Then** the avatar must have a pink glow shadow effect  
**And** the glow must use `AppColors.primary` with 30% opacity  
**And** the glow must have blur radius of 12px and spread radius of 2px  
**And** non-featured experts must not have any glow effect  
**And** the existing border styling (if any) must be removed in favor of the glow

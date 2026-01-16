# Spec: Empty States

## ADDED Requirements

### Requirement: Branded Empty State Component
The application must provide a reusable empty state component that maintains brand consistency and guides users toward actionable next steps.

#### Scenario: User views venue with no reviews
**Given** the user is viewing a venue's reviews tab  
**And** the venue has zero reviews  
**When** the reviews tab is displayed  
**Then** an empty state component must appear with:  
  - Icon: `Icons.rate_review_outlined` (size: 64px, color: `AppColors.gray400`)  
  - Title: "Henüz Yorum Yok" (18px, bold, `AppColors.gray900`)  
  - Message: "Bu mekan hakkında ilk yorumu siz yapın!" (14px, `AppColors.gray600`)  
  - Action button: "Yorum Yaz" (primary button style)  
**And** tapping the action button must open the review submission dialog

#### Scenario: User views venue with no experts
**Given** the user is viewing a venue's experts tab  
**And** the venue has no registered experts  
**When** the experts tab is displayed  
**Then** an empty state component must appear with:  
  - Icon: `Icons.people_outline` (size: 64px, color: `AppColors.gray400`)  
  - Title: "Uzman Kadrosu Henüz Eklenmedi" (18px, bold, `AppColors.gray900`)  
  - Message: "Bu mekan henüz uzman bilgilerini paylaşmamış." (14px, `AppColors.gray600`)  
  - No action button (user cannot add experts for other venues)

#### Scenario: User views venue with no services
**Given** the user is viewing a venue's services tab  
**And** the venue has no listed services  
**When** the services tab is displayed  
**Then** an empty state component must appear with:  
  - Icon: `Icons.spa_outlined` (size: 64px, color: `AppColors.gray400`)  
  - Title: "Hizmet Listesi Henüz Eklenmedi" (18px, bold, `AppColors.gray900`)  
  - Message: "Bu mekan henüz hizmet bilgilerini paylaşmamış." (14px, `AppColors.gray600`)  
  - No action button

#### Scenario: User has no followed venues
**Given** the user is viewing their followed venues list  
**And** the user has not followed any venues  
**When** the followed venues screen is displayed  
**Then** an empty state component must appear with:  
  - Icon: `Icons.favorite_border` (size: 64px, color: `AppColors.gray400`)  
  - Title: "Henüz Takip Ettiğiniz Mekan Yok" (18px, bold, `AppColors.gray900`)  
  - Message: "Favori mekanlarınızı takip ederek kampanyalardan haberdar olun!" (14px, `AppColors.gray600`)  
  - Action button: "Mekan Keşfet" (primary button style)  
**And** tapping the action button must navigate to the discovery screen

---

### Requirement: Empty State Styling Consistency
All empty state components must follow consistent styling rules to maintain brand identity and visual hierarchy.

#### Scenario: Empty state component structure
**Given** any empty state is displayed  
**Then** the component must be vertically centered on the screen  
**And** the icon must appear above the title  
**And** the title must appear above the message  
**And** the action button (if present) must appear below the message  
**And** vertical spacing must be:  
  - Icon to title: 16px  
  - Title to message: 8px  
  - Message to button: 24px  
**And** horizontal padding must be 32px from screen edges  
**And** text must be center-aligned

#### Scenario: Empty state color palette
**Given** any empty state is displayed  
**Then** icons must use `AppColors.gray400`  
**And** titles must use `AppColors.gray900` with bold weight  
**And** messages must use `AppColors.gray600` with regular weight  
**And** action buttons must use primary button styling (`AppColors.primary` background)

---

### Requirement: Empty State Accessibility
Empty states must be accessible to screen reader users and provide clear context about the missing content.

#### Scenario: Screen reader announces empty state
**Given** a screen reader user navigates to a tab with no content  
**When** the empty state is displayed  
**Then** the screen reader must announce the title and message in sequence  
**And** the action button (if present) must be announced as a button with its label  
**And** the icon must have a semantic label matching the title

#### Scenario: Keyboard navigation
**Given** a user is navigating with a keyboard (e.g., Bluetooth keyboard on tablet)  
**When** an empty state with an action button is displayed  
**Then** the action button must be focusable via Tab key  
**And** pressing Enter or Space on the focused button must trigger the action

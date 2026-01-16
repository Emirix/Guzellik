# Spec: Animations

## ADDED Requirements

### Requirement: Pulsing Status Indicator
The "Open Now" status indicator must use a pulsing animation to convey real-time status and draw user attention.

#### Scenario: User views venue working hours
**Given** the user is viewing a venue's working hours section  
**And** the venue is currently open  
**When** the "Open Now" badge is displayed  
**Then** the status dot must pulse smoothly between full opacity (1.0) and 50% opacity (0.5)  
**And** the animation must repeat infinitely with a 2-second cycle  
**And** the animation must use `Curves.easeInOut` for smooth transitions  
**And** the animation must respect system "Reduce Motion" accessibility settings

#### Scenario: User views closed venue
**Given** the user is viewing a venue's working hours section  
**And** the venue is currently closed  
**When** the "Closed" badge is displayed  
**Then** the status dot must remain static (no pulsing animation)  
**And** the dot color must be red (`Colors.redAccent`)

---

### Requirement: Button Press Feedback
Primary action buttons must provide immediate visual and tactile feedback when pressed to confirm user interaction.

#### Scenario: User taps Follow button
**Given** the user is viewing a venue detail page  
**When** the user presses down on the "Follow" button  
**Then** the button must scale down to 95% of its original size within 100ms  
**And** the device must trigger a medium-impact haptic feedback  
**When** the user releases the button  
**Then** the button must scale back to 100% within 100ms  
**And** the follow action must execute

#### Scenario: User taps Contact button
**Given** the user is viewing a venue detail page  
**When** the user presses down on the "Contact Us" button  
**Then** the button must scale down to 95% of its original size within 100ms  
**And** the device must trigger a medium-impact haptic feedback  
**When** the user releases the button  
**Then** the button must scale back to 100% within 100ms  
**And** the contact options bottom sheet must appear

#### Scenario: Accessibility - Reduce Motion enabled
**Given** the user has enabled "Reduce Motion" in system accessibility settings  
**When** the user taps any primary action button  
**Then** the scale animation must be disabled  
**But** haptic feedback must still trigger (if device supports it)

---

### Requirement: Featured Expert Visual Emphasis
Featured experts must be visually distinguished with a subtle glow effect to draw user attention without overwhelming the design.

#### Scenario: User views expert team section
**Given** the user is viewing a venue's expert team section  
**And** at least one expert is marked as featured (`is_featured: true` in database)  
**When** the expert cards are displayed  
**Then** featured expert avatars must have a pink glow effect  
**And** the glow must use `AppColors.primary` with 30% opacity  
**And** the glow must have a blur radius of 12px and spread radius of 2px  
**And** non-featured experts must not have any glow effect

#### Scenario: No featured experts
**Given** the user is viewing a venue's expert team section  
**And** no experts are marked as featured  
**When** the expert cards are displayed  
**Then** all expert avatars must appear without glow effects  
**And** the first expert in the list may have a subtle border (existing behavior)

---

### Requirement: Glassmorphic Map Preview Button
The map preview overlay button must use a glassmorphic (frosted glass) effect to match modern design standards and improve readability over varied map backgrounds.

#### Scenario: User views map preview
**Given** the user is viewing a venue's location section  
**When** the map preview is displayed  
**Then** the "View on Map" button overlay must have a frosted glass appearance  
**And** the button background must use `BackdropFilter` with 10px blur (sigmaX and sigmaY)  
**And** the button background color must be white with 70% opacity  
**And** the button must have a white border with 30% opacity  
**And** the button must remain readable over any map background

#### Scenario: User taps map preview
**Given** the user is viewing the map preview  
**When** the user taps anywhere on the map preview (including the glassmorphic button)  
**Then** the full-screen map view must open  
**And** the venue location must be centered on the map

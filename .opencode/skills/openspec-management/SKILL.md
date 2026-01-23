---
name: openspec-management
description: Manages OpenSpec change proposals, specifications, and task tracking for the Guzellik project. Use when creating feature proposals, writing specs, managing tasks, or archiving completed changes.
---

# OpenSpec Management

## When to use this skill
- Creating new feature proposals
- Writing or updating specifications
- Managing implementation tasks
- Archiving completed changes
- User mentions "openspec", "proposal", "spec", "task", "feature", "öneri"
- Planning new features or changes

## OpenSpec Structure

### Directory Layout
```
openspec/
├── project.md              # Project context and conventions
├── SPEC_SUMMARY.md         # Summary of all specs
├── AGENTS.md              # Agent-specific guidelines
├── changes/
│   └── <change-id>/
│       ├── proposal.md    # Change proposal
│       ├── tasks.md       # Implementation tasks
│       ├── design.md      # Architecture design (optional)
│       └── specs/
│           └── <capability>/
│               └── spec.md
└── specs/
    └── <capability>/
        └── spec.md        # Approved specs
```

## Workflow: Creating a Proposal

### Step 1: Research and Planning

**Checklist:**
- [ ] Read `openspec/project.md` for project context
- [ ] Run `openspec list` to see existing changes
- [ ] Run `openspec list --specs` to see approved specs
- [ ] Search codebase for related functionality
- [ ] Identify gaps and clarification needs

**Commands:**
```bash
# List all changes
openspec list

# List all specs
openspec list --specs

# Search for related code
rg "keyword" lib/
```

### Step 2: Choose Change ID

**Naming Convention:**
- Use verb-led format: `<verb>-<noun>-<noun>`
- Examples:
  - `enhance-business-account-management`
  - `add-venue-filtering-system`
  - `improve-notification-delivery`

**Turkish Business Terms:**
- Mekan (Venue)
- İşletme (Business)
- Abonelik (Subscription)
- Bildirim (Notification)
- Takip (Follow)

### Step 3: Create Proposal Structure

**Create Files:**
```
openspec/changes/<change-id>/
├── proposal.md
├── tasks.md
└── design.md (if needed)
```

**proposal.md Template:**
```markdown
# [Change Title]

## Problem
[Describe the problem or opportunity in Turkish]

## Solution
[Describe the proposed solution]

## Scope
- What's included
- What's excluded
- Dependencies

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Risks
- Risk 1 and mitigation
- Risk 2 and mitigation
```

**tasks.md Template:**
```markdown
# Implementation Tasks

## Phase 1: [Phase Name]
- [ ] Task 1 - [Description]
  - Validation: [How to verify]
  - Dependencies: [Other tasks]
- [ ] Task 2 - [Description]

## Phase 2: [Phase Name]
- [ ] Task 3 - [Description]
```

### Step 4: Write Spec Deltas

**Create Spec File:**
```
openspec/changes/<change-id>/specs/<capability>/spec.md
```

**Spec Template:**
```markdown
# [Capability Name]

## ADDED Requirements

### Requirement: [Requirement Name]
[Description in Turkish if business logic, English if technical]

#### Scenario: [Scenario Name]
**Given** [Initial state]
**When** [Action]
**Then** [Expected outcome]

## MODIFIED Requirements

### Requirement: [Existing Requirement Name]
[What changed and why]

#### Scenario: [Updated Scenario]
**Given** [Initial state]
**When** [Action]
**Then** [Expected outcome]

## REMOVED Requirements

### Requirement: [Requirement to Remove]
[Why it's being removed]
```

### Step 5: Create Design Document (if needed)

**When to create design.md:**
- Change spans multiple systems
- Introduces new architectural patterns
- Requires trade-off discussion
- Complex technical decisions

**design.md Template:**
```markdown
# Architecture Design: [Change Name]

## Overview
[High-level description]

## Components
### Component 1
- Responsibility
- Dependencies
- Interfaces

### Component 2
- Responsibility
- Dependencies
- Interfaces

## Data Flow
[Describe how data flows through the system]

## Trade-offs
### Option 1
- Pros
- Cons

### Option 2 (Chosen)
- Pros
- Cons
- Why chosen

## Migration Strategy
[How to migrate from current to new design]
```

### Step 6: Validate

**Run Validation:**
```bash
openspec validate <change-id> --strict
```

**Fix Common Issues:**
- Missing required sections
- Invalid requirement format
- Broken cross-references
- Missing scenarios

**Validation Checklist:**
- [ ] All requirements have at least one scenario
- [ ] Scenarios follow Given/When/Then format
- [ ] Cross-references are valid
- [ ] Turkish used for business logic
- [ ] English used for technical details

## Workflow: Applying a Proposal

### Step 1: Review Approval
- Ensure proposal is approved
- Review all tasks
- Understand dependencies

### Step 2: Implement Tasks
- Follow task order
- Mark completed tasks with `[x]`
- Update tasks.md as you progress

### Step 3: Keep Specs in Sync
- Update spec deltas as implementation evolves
- Add new scenarios if needed
- Document any deviations

### Step 4: Test and Validate
- Run tests for each task
- Verify success criteria
- Check that scenarios are satisfied

## Workflow: Archiving a Change

### Step 1: Verify Completion
- [ ] All tasks marked complete
- [ ] All success criteria met
- [ ] Code deployed to production
- [ ] Documentation updated

### Step 2: Move Specs
```bash
# Specs move from changes/ to specs/
mv openspec/changes/<change-id>/specs/<capability> openspec/specs/
```

### Step 3: Update Metadata
- Update `SPEC_SUMMARY.md`
- Add completion date to proposal
- Archive proposal in changes directory

### Step 4: Clean Up
- Remove temporary files
- Update related documentation
- Commit changes

## Common Patterns

### Business Feature Proposal

**Example: İşletme Abonelik Sistemi**

```markdown
# İşletme Abonelik Sistemi

## Problem
İşletme hesapları premium özelliklere erişim için abonelik sistemine ihtiyaç duyuyor.

## Solution
- Abonelik paketleri (Standard, Premium, Enterprise)
- Ödeme entegrasyonu
- Özellik kontrolü sistemi

## Specs
- `business-subscription-management` - Abonelik CRUD
- `subscription-feature-access` - Özellik erişim kontrolü
- `subscription-payment-integration` - Ödeme sistemi
```

### UI Enhancement Proposal

**Example: Venue Card Redesign**

```markdown
# Venue Card Redesign

## Problem
Mevcut mekan kartları yeterince bilgi göstermiyor ve premium hissi vermiyor.

## Solution
- Yeni kart tasarımı (design/ klasöründe mockup)
- Güven rozetleri entegrasyonu
- Gelişmiş bilgi gösterimi

## Specs
- `venue-card-ui` - Kart bileşeni
- `trust-badge-display` - Rozet gösterimi
```

### Database Schema Change

**Example: Add Business Subscriptions Table**

```markdown
# Add Business Subscriptions Table

## Problem
Need to track business account subscriptions and features.

## Solution
- New `business_subscriptions` table
- RPC functions for subscription checks
- RLS policies for data security

## Specs
- `business-subscription-schema` - Database schema
- `subscription-rpc-functions` - RPC functions
- `subscription-security-policies` - RLS policies
```

## Integration with Workflows

### Use Existing Workflows

**Create Proposal:**
```
/openspec-proposal
```

**Apply Proposal:**
```
/openspec-apply
```

**Archive Proposal:**
```
/openspec-archive
```

### Workflow Triggers
- `/openspec-proposal` - Start new feature proposal
- `/openspec-apply` - Implement approved proposal
- `/openspec-archive` - Archive completed change

## Best Practices

### Writing Requirements
- ✅ Use Turkish for business logic
- ✅ Use English for technical details
- ✅ Be specific and testable
- ✅ Include at least one scenario per requirement
- ❌ Avoid vague language
- ❌ Don't mix business and technical concerns

### Writing Scenarios
- ✅ Follow Given/When/Then format
- ✅ Make scenarios realistic
- ✅ Cover happy path and edge cases
- ✅ Use concrete examples
- ❌ Don't make scenarios too abstract
- ❌ Don't skip error cases

### Writing Tasks
- ✅ Break into small, verifiable units
- ✅ Include validation steps
- ✅ Note dependencies
- ✅ Order by logical sequence
- ❌ Don't create massive tasks
- ❌ Don't skip validation

### Managing Changes
- ✅ Keep changes focused and scoped
- ✅ Update specs as implementation evolves
- ✅ Validate frequently
- ✅ Archive when complete
- ❌ Don't let specs drift from code
- ❌ Don't leave stale proposals

## Checklist: Complete Proposal

### Before Submitting
- [ ] Change ID is verb-led and descriptive
- [ ] proposal.md clearly states problem and solution
- [ ] tasks.md has ordered, verifiable tasks
- [ ] design.md exists if architecturally complex
- [ ] All spec deltas have requirements and scenarios
- [ ] Turkish used for business logic
- [ ] English used for technical details
- [ ] Cross-references are valid
- [ ] `openspec validate --strict` passes
- [ ] Related code has been reviewed

### During Implementation
- [ ] Tasks are marked as completed
- [ ] Specs updated with implementation learnings
- [ ] Tests written for each task
- [ ] Success criteria being met
- [ ] Documentation updated

### Before Archiving
- [ ] All tasks complete
- [ ] All success criteria met
- [ ] Code deployed
- [ ] Specs moved to openspec/specs/
- [ ] SPEC_SUMMARY.md updated
- [ ] Proposal marked as archived

## Resources

### Key Files
- `openspec/project.md` - Project context
- `openspec/AGENTS.md` - Agent guidelines
- `openspec/SPEC_SUMMARY.md` - Spec summary
- `.agent/workflows/openspec-*.md` - Workflow definitions

### Common Commands
```bash
# List changes
openspec list

# List specs
openspec list --specs

# Validate change
openspec validate <change-id> --strict

# Show change details
openspec show <change-id> --json --deltas-only

# Show spec details
openspec show <spec> --type spec

# Search requirements
rg -n "Requirement:|Scenario:" openspec/specs
```

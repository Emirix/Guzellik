---
name: git-commit-workflow
description: Manages Git commits following Turkish conventional commit format for the Guzellik project. Use when committing code changes, creating branches, or managing version control.
---

# Git Commit Workflow

## When to use this skill
- Committing code changes
- Creating feature branches
- Managing version control
- User mentions "commit", "git", "branch", "kaydet", "değişiklik"
- Completing tasks or features

## Commit Message Format

### Structure
```
<tip>(<kapsam>): <açıklama>
```

### Components

#### Tip (Type)
Required. Indicates the type of change.

- **feat**: Yeni özellik (New feature)
- **fix**: Hata düzeltme (Bug fix)
- **docs**: Dokümantasyon değişikliği (Documentation)
- **style**: Görsel/biçimsel düzenleme (UI/styling changes)
- **refactor**: Kod iyileştirme (Code refactoring)
- **perf**: Performans iyileştirmesi (Performance improvement)
- **test**: Test ekleme/düzenleme (Testing)
- **build**: Yapılandırma/bağımlılık değişikliği (Build/dependencies)
- **chore**: Diğer yardımcı değişiklikler (Maintenance)

#### Kapsam (Scope)
Optional but recommended. Indicates what part of the codebase is affected.

Common scopes:
- **auth**: Authentication
- **venue**: Venue-related features
- **business**: Business account features
- **subscription**: Subscription system
- **ui**: User interface
- **map**: Map features
- **notification**: Notifications
- **profile**: User profile
- **review**: Reviews and ratings
- **follow**: Follow system

#### Açıklama (Description)
Required. Brief description of the change.

Rules:
- Küçük harfle başlamalıdır (Start with lowercase)
- Satır sonuna nokta konulmamalıdır (No period at the end)
- Geniş zaman veya Geçmiş zaman kullanılabilir (Present or past tense)
- Öneri: "eklendi", "düzeltildi", "güncellendi" (Recommended: past tense)

## Commit Message Examples

### Feature Additions (feat)
```bash
# Good examples
git commit -m "feat(business): işletme modu navigasyonu eklendi"
git commit -m "feat(venue): mekan filtreleme sistemi eklendi"
git commit -m "feat(subscription): abonelik yönetim ekranı eklendi"
git commit -m "feat(map): harita üzerinde mekan gösterimi eklendi"

# Bad examples
git commit -m "feat: yeni özellik"  # Too vague
git commit -m "feat(business): İşletme modu eklendi."  # Capital letter, period
git commit -m "Added business mode"  # English
```

### Bug Fixes (fix)
```bash
# Good examples
git commit -m "fix(auth): giriş yapma hatası düzeltildi"
git commit -m "fix(venue): mekan detay sayfası çökme sorunu giderildi"
git commit -m "fix(map): konum izni hatası düzeltildi"
git commit -m "fix(notification): bildirim gösterimi sorunu çözüldü"

# Bad examples
git commit -m "fix: bug fixed"  # English
git commit -m "fix(auth): Hata düzeltildi"  # Capital letter
git commit -m "fix: çeşitli hatalar düzeltildi"  # Too vague
```

### UI/Styling Changes (style)
```bash
# Good examples
git commit -m "style(venue): mekan kartı tasarımı güncellendi"
git commit -m "style(ui): renk paleti iyileştirildi"
git commit -m "style(business): abonelik ekranı düzenlendi"
git commit -m "style(profile): profil sayfası yeniden tasarlandı"

# Bad examples
git commit -m "style: UI changes"  # English
git commit -m "style: güzelleştirme"  # Too vague
```

### Refactoring (refactor)
```bash
# Good examples
git commit -m "refactor(venue): mekan servisi yeniden yapılandırıldı"
git commit -m "refactor(auth): kimlik doğrulama kodu iyileştirildi"
git commit -m "refactor(ui): widget yapısı optimize edildi"

# Bad examples
git commit -m "refactor: code cleanup"  # English
git commit -m "refactor: iyileştirme"  # Too vague
```

### Documentation (docs)
```bash
# Good examples
git commit -m "docs: README güncellendi"
git commit -m "docs(api): API dokümantasyonu eklendi"
git commit -m "docs(business): işletme hesabı kurulum rehberi eklendi"

# Bad examples
git commit -m "docs: updated docs"  # English
git commit -m "docs: Dokümantasyon eklendi."  # Capital letter, period
```

### Testing (test)
```bash
# Good examples
git commit -m "test(venue): mekan servisi testleri eklendi"
git commit -m "test(auth): kimlik doğrulama testleri güncellendi"
git commit -m "test: widget testleri eklendi"

# Bad examples
git commit -m "test: added tests"  # English
git commit -m "test: testler"  # Too vague
```

### Build/Dependencies (build)
```bash
# Good examples
git commit -m "build: pubspec.yaml bağımlılıkları güncellendi"
git commit -m "build: flutter sürümü yükseltildi"
git commit -m "build(deps): yeni paketler eklendi"

# Bad examples
git commit -m "build: updated packages"  # English
git commit -m "build: güncelleme"  # Too vague
```

## Branch Naming

### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Urgent production fixes

### Branch Naming Convention
```bash
# Feature branches
feature/business-mode-navigation
feature/venue-filtering-system
feature/subscription-management

# Bugfix branches
bugfix/auth-login-error
bugfix/map-location-permission
bugfix/notification-display

# Hotfix branches
hotfix/critical-crash-fix
hotfix/security-patch
```

## Workflow

### Step 1: Check Status
```bash
git status
```

### Step 2: Stage Changes
```bash
# Stage specific files
git add lib/presentation/screens/business/store_screen.dart

# Stage all changes (use carefully)
git add .
```

### Step 3: Commit with Message
```bash
# Use the format: <tip>(<kapsam>): <açıklama>
git commit -m "feat(business): premium özellikler mağazası eklendi"
```

### Step 4: Push Changes
```bash
# Push to current branch
git push

# Push new branch
git push -u origin feature/subscription-management
```

## Task Completion Workflow

### When Completing a Task

Use the `/task-complete` workflow:

1. **Review Changes**
   ```bash
   git status
   git diff
   ```

2. **Stage Changes**
   ```bash
   git add <files>
   ```

3. **Commit with Proper Message**
   ```bash
   git commit -m "feat(subscription): abonelik detay ekranı eklendi"
   ```

4. **Update tasks.md**
   - Mark task as complete: `[x]`
   - Commit task update:
   ```bash
   git commit -m "docs: tasks.md güncellendi"
   ```

5. **Push Changes**
   ```bash
   git push
   ```

## Multi-Change Commits

### When to Split Commits

Split into multiple commits when:
- Changes affect different features
- Mix of feature and fix
- Different scopes

```bash
# Example: Separate commits for different scopes
git add lib/presentation/screens/business/
git commit -m "feat(business): işletme profil ekranı eklendi"

git add lib/presentation/widgets/venue/
git commit -m "style(venue): mekan kartı tasarımı güncellendi"
```

### When to Combine Commits

Combine into single commit when:
- All changes are part of same feature
- Same scope and type
- Logically related

```bash
# Example: Single commit for related changes
git add lib/presentation/screens/subscription/
git add lib/data/services/subscription_service.dart
git add lib/data/models/subscription.dart
git commit -m "feat(subscription): abonelik yönetim sistemi eklendi"
```

## Checklist: Before Committing

### Code Quality
- [ ] Code follows project conventions
- [ ] No console.log or debug prints left
- [ ] No commented-out code
- [ ] Turkish comments for business logic
- [ ] English comments for technical details

### Testing
- [ ] Code tested locally
- [ ] No breaking changes
- [ ] Related tests updated

### Commit Message
- [ ] Follows format: `<tip>(<kapsam>): <açıklama>`
- [ ] Type is correct (feat, fix, etc.)
- [ ] Scope is appropriate
- [ ] Description starts with lowercase
- [ ] No period at end
- [ ] Turkish language used
- [ ] Clear and descriptive

## Common Mistakes to Avoid

### ❌ English Commit Messages
```bash
# Bad
git commit -m "feat(business): added business mode"

# Good
git commit -m "feat(business): işletme modu eklendi"
```

### ❌ Vague Descriptions
```bash
# Bad
git commit -m "feat: güncelleme"
git commit -m "fix: hata düzeltildi"

# Good
git commit -m "feat(venue): mekan filtreleme sistemi eklendi"
git commit -m "fix(auth): giriş yapma hatası düzeltildi"
```

### ❌ Wrong Capitalization
```bash
# Bad
git commit -m "feat(business): İşletme modu eklendi."

# Good
git commit -m "feat(business): işletme modu eklendi"
```

### ❌ Missing Scope
```bash
# Bad (when scope is relevant)
git commit -m "feat: yeni özellik eklendi"

# Good
git commit -m "feat(subscription): abonelik sistemi eklendi"
```

### ❌ Multiple Unrelated Changes
```bash
# Bad
git commit -m "feat: çeşitli özellikler eklendi"

# Good - Split into multiple commits
git commit -m "feat(venue): mekan filtreleme eklendi"
git commit -m "fix(auth): giriş hatası düzeltildi"
git commit -m "style(ui): renk paleti güncellendi"
```

## Resources

### Key Files
- `.agent/rules/git.md` - Git commit rules
- `.agent/workflows/task-complete.md` - Task completion workflow
- `GIT_COMMIT_RULES.md` - Detailed commit rules

### Quick Reference

**Commit Types:**
- feat, fix, docs, style, refactor, perf, test, build, chore

**Common Scopes:**
- auth, venue, business, subscription, ui, map, notification, profile, review, follow

**Format:**
- `<tip>(<kapsam>): <açıklama>`
- Lowercase description
- No period at end
- Turkish language

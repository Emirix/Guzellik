# Design: Venue Category System

## Architecture Overview
The system will normalize venue classification by moving from a hardcoded/undocumented list to a relational database structure.

## Database Design

### `venue_categories` Table
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `uuid` (PK) | Unique identifier (default: `gen_random_uuid()`) |
| `name` | `text` | The display name of the category (e.g., "Güzellik Salonu") |
| `slug` | `text` | URL-friendly version of the name (e.g., "guzellik-salonu") |
| `icon` | `text` (optional) | Identifier for a Flutter icon or a remote asset URL |
| `image_url` | `text` (optional) | URL for a representative image |
| `description` | `text` (optional) | Brief description of the category |
| `created_at` | `timestamptz` | Timestamp of creation |

### `venues` Table (Modification)
- Add `category_id` (`uuid`, FK referencing `venue_categories.id`, nullable: true for now, but should be required for new venues).

## Initial Data
The following categories will be seeded:
1. KİRPİK & KAŞ STÜDYO
2. EPİLASYON MERKEZLERİ
3. CİLT BAKIM MERKEZLERİ
4. Güzellik Salonu
5. Kadın Kuaförleri
6. Tırnak Stüdyoları
7. Estetik Yerleri
8. Ayak Bakım

## Flutter Implementation

### Models
- **`VenueCategory`**:
  - `String id`
  - `String name`
  - `String? icon`
  - `String? imageUrl`

### Repository Updates
- `VenueRepository` should include categories in its FETCH queries (using Supabase `.select('*, venue_categories(*)')`).

## Technical Considerations
- **RLS**: The `venue_categories` table should have public READ access.
- **Migration Path**: Existing venues in the database (if any) will need their `category_id` set. We might need a default category or manual mapping for existing data.
- **Performance**: Categories should be cached in-memory in a `CategoryProvider` since they change infrequently.

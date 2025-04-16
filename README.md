# 🧪 RetailData Demo Postgres Database

This repo contains a PostgreSQL container setup preloaded with a sample retail schema and data. It's designed to be a plug-and-play data layer for demo apps.  It dynamically maintains per-class meterialized views in response to changes in the `product`, `customFields`, and `customFieldData` tables.  It uses triggers and a centralized refresh function to rebuild the appropriate `{className}_products` materialized views on data mutation.
---
## 📦 Schema Overview

The database consists of the following key tables:

- **`class`**
    - `className` (varchar, PK)

- **`Product`**
    - `productId` (serial, PK)
    - `className` (varchar, FK → Class)
    - `description` (varchar)
    - `cost` (money)
    - `currentPrice` (money)
    - `inventory` (int)

- **`CustomFields`**
    - `customFieldId` (serial, PK)
    - `className` (FK → Class)
    - `fieldName` (varchar)
    - `fieldType` (varchar)
    - Unique constraint on (`className`, `fieldName`)


- **`CustomFieldData`**
    - `productId` (FK → Product)
    - `customFieldId` (FK → CustomFields)
    - `fieldValue` (varchar)
    - Composite PK on (`productId`, `customFieldId`)

*The system also generates **dynamic materialized views** named `{className}_products` which contain a denormalized view of the product and its custom field data for each unique `className`.*
---

## 🔄 Dynamic Materialized Views
The core of this project is the dynamic management of class-based materialized views:
1. **Triggers** are defined on `product`, `customFields`, and `customFieldData` for `INSERT`, `UPDATE`, and `DELETE` operations.
2. Each trigger executes a centralized function:
    `public.refresh_materialized_view()`
3. This function fully rebuilds all materialized views (`{className}_products`).

> ⚠️ **Tradeoff Notice:**
> For simplicity and clarity, this demo uses `FOR EACH STATEMENT` triggers and **fully rebuilds the materialized view for every class** every time any operation occurs.  This is not efficient at scale but is suitable for small datasets or as a proof-of-concept.  This is a very small database that will not receive an exceptional amount of use, so it is an appropriate tradeoff for this use case.
---

## 🚀 Quick Start
### Prerequisites
- Docker
- Docker compose

### Setup
```bash
docker-compose up -d
```

This will:
- Launch a PostgreSQL container (configured via .env)
- Execute the SQL files in /init:
    - `1_createTables.sql`
    - `2_functionsTriggers.sql`
    - `3_populateData.sql`

### Configuration
Override default settings using the `.env` file (not committed to version control):
```env
POSTGRES_VERSION=14.7
POSTGRES_PORT=5432
POSTGRES_USER=demo
POSTGRES_PASSWORD="my super secret password"
POSTGRES_DB=demo_db
```

---
## 📃 Example Queries
```sql
-- List all available materialized views
SELECT matviewname FROM pg_matviews WHERE schemaname = 'public';

-- Query a specific class view
SELECT * from book_products;
SELECT * from "board game_products";

-- Manually refresh a materialized view (if needed)
REFRESH MATERIALIZED VIEW grocery_products;
REFRESH MATERIALIZED VIEW "board game_products";
```
---

## 📂 Project Structure
```
.
├── db/
│  ├── 01_create_schema.sql
│  ├── 02_create_triggers.sql
│  └── 03_seed_data.sql
├── docker-compose.yml
├── .env
├── .gitignore
└── README.md
```
---

## ⚙️ Development Notes
- All SQL and Docker config is organized to be self-contained and reprroducible
- This project intentionally favors readability and clarity over performance
---

## 📌 Limitations and Caveats
- Full view refreshes on every relevant operation - avoid in large-scale systems
- Transition tables (`OLD TABLE`, `NEW TABLE`) were considered byt are restricted to single-event triggers
- A more robust system would track deltas and only update views as needed
---

## 📬 Feedback
Feel free to fork or open issues if you want to take this further.  This is a sandboxfor experimenting with database-level logic - not a production-ready architecture.

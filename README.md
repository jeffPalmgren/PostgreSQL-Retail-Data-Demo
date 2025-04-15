# RetailData Demo Postgres Database

This repo contains a PostgreSQL container setup preloaded with a sample retail schema and data. It's designed to be a plug-and-play data layer for demo apps.

## Schema Overview

### `Class`
Stores product classification.
- `className` (varchar, PK)

### `Product`
Represents a product for sale.
- `productId` (serial, PK)
- `className` (varchar, FK → Class)
- `description` (varchar)
- `cost` (money)
- `currentPrice` (money)
- `inventory` (int)

### `CustomFields`
Defines arbitrary fields per product class.
- `customFieldId` (serial, PK)
- `className` (FK → Class)
- `fieldName` (varchar)
- `fieldType` (varchar)
- Unique constraint on (`className`, `fieldName`)


### `CustomFieldData`
Holds per-product values for each defined custom field.
- `productId` (FK → Product)
- `customFieldId` (FK → CustomFields)
- `fieldValue` (varchar)
- Composite PK on (`productId`, `customFieldId`)


## Quick Start
```bash
docker-compose up -d

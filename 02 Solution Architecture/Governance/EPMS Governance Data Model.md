# EPMS Governance Data Model

This document defines the database schema for Governance and Archetype Management in the Enterprise Project Management System (EPMS).

---

## Table of Contents

1. [Role Master](#1-role-master)
2. [Action Master](#2-action-master)
3. [Archetype WBS Access Matrix](#3-archetype-wbs-access-matrix)
4. [Archetype Master](#4-archetype-master)
5. [Project Archetype Link](#5-project-archetype-link)
6. [WBS Type Master](#6-wbs-type-master)
7. [Archetype WBS Definition](#7-archetype-wbs-definition)
8. [QA Checklist Master](#8-qa-checklist-master)
9. [QA Checklist Item Master](#9-qa-checklist-item-master)
10. [Archetype WBS QA Mapping](#10-archetype-wbs-qa-mapping)

---

## 1. Role Master

**Purpose:** Stores user roles. This should preferably reuse your enterprise/shared role master.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `role_id` | `int` | PK | Primary Key |
| `role_code` | `varchar(50)` | UK | Unique Key - ADMIN, PM, COE_HEAD, etc. |
| `role_name` | `varchar(100)` | | Role display name |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |

---

## 2. Action Master

**Purpose:** Stores actions shown on access tab for access control.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `action_id` | `int` | PK | Primary Key |
| `action_code` | `varchar(30)` | UK | Unique Key - ADD / EDIT / VIEW / DELETE |
| `action_name` | `varchar(50)` | | Action display name |
| `display_sequence` | `int` | | Display order |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |

---

## 3. Archetype WBS Access Matrix

**Purpose:** Stores who can do what on each WBS object (role-based access control).

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `archetype_wbs_access_id` | `int` | PK | Primary Key |
| `archetype_wbs_id` | `int` | FK | Foreign Key to Archetype WBS Definition |
| `role_id` | `int` | FK | Foreign Key to Role Master |
| `action_id` | `int` | FK | Foreign Key to Action Master |
| `allowed_flag` | `boolean` | | true / false - permission flag |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |
| `created_by` | `varchar(50)` | | User who created the record |
| `created_at` | `timestamp` | | Creation timestamp |

---

## 4. Archetype Master

**Purpose:** Stores archetypes like Innovation, General, PoC.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `archetype_id` | `int` | PK | Primary Key |
| `archetype_code` | `varchar(30)` | | Business ID like AR12 |
| `archetype_name` | `varchar(100)` | | Innovation / General / PoC |
| `description` | `varchar(500)` | | Optional description |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |
| `version_no` | `int` | | For future controlled changes |
| `created_by` | `varchar(50)` | | Admin user who created |
| `created_at` | `timestamp` | | Creation timestamp |
| `updated_by` | `varchar(50)` | | User who last updated |
| `updated_at` | `timestamp` | | Last update timestamp |

---

## 5. Project Archetype Link

**Purpose:** For future project planning, each project stores its selected archetype.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `project_id` | `int` | PK | Primary Key - approved project ID with code |
| `project_code` | `varchar(50)` | | Project business code |
| `project_name` | `varchar(200)` | | Project name |
| `archetype_id` | `int` | FK | Foreign Key to Archetype Master |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |
| `created_at` | `timestamp` | | Creation timestamp |

---

## 6. WBS Type Master

**Purpose:** Stores allowed WBS object types.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `wbs_type_id` | `int` | PK | Primary Key |
| `wbs_type_code` | `varchar(30)` | | GENERAL / QA / VCF / RISKSPHERE |
| `wbs_type_name` | `varchar(100)` | | User display name |
| `description` | `varchar(300)` | | Type description |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |
| `display_sequence` | `int` | | Dropdown order |

---

## 7. Archetype WBS Definition

**Purpose:** Stores WBS objects for each archetype with hierarchical structure.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `archetype_wbs_id` | `int` | PK | Primary Key |
| `archetype_id` | `int` | FK | Foreign Key to Archetype Master |
| `wbs_code` | `varchar(30)` | | Business sequence like 1, 2, 2.1 |
| `wbs_name` | `varchar(150)` | | Discovery, Design, Development, QA, VCF, AI Risk Assessment |
| `wbs_type_id` | `int` | FK | Foreign Key to WBS Type Master - GENERAL / QA / VCF / RISKSPHERE |
| `parent_wbs_id` | `int` | FK (self) | Foreign Key to self - supports hierarchy like Design → AS-IS / TO-BE |
| `level_no` | `int` | | Hierarchy level: 1, 2, 3 |
| `display_sequence` | `int` | | Screen ordering |
| `is_mandatory` | `boolean` | | Default true if always applicable |
| `action_required_flag` | `boolean` | | True for types needing action like QA checklist |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |
| `created_by` | `varchar(50)` | | User who created |
| `created_at` | `timestamp` | | Creation timestamp |
| `updated_by` | `varchar(50)` | | User who last updated |
| `updated_at` | `timestamp` | | Last update timestamp |

---

## 8. QA Checklist Master

**Purpose:** Stores checklist header/master templates.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `qa_checklist_id` | `int` | PK | Primary Key |
| `checklist_code` | `varchar(30)` | | Checklist business code |
| `checklist_name` | `varchar(150)` | | e.g., Standard Project QA Checklist |
| `description` | `varchar(500)` | | Optional description |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |
| `created_by` | `varchar(50)` | | User who created |
| `created_at` | `timestamp` | | Creation timestamp |
| `updated_by` | `varchar(50)` | | User who last updated |
| `updated_at` | `timestamp` | | Last update timestamp |

---

## 9. QA Checklist Item Master

**Purpose:** Stores individual QA checklist items.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `qa_checklist_item_id` | `int` | PK | Primary Key |
| `qa_checklist_id` | `int` | FK | Foreign Key to QA Checklist Master |
| `item_code` | `varchar(30)` | | Item business code |
| `item_name` | `varchar(200)` | | e.g., Requirements Documentation Completion, AI Governance Check |
| `description` | `varchar(500)` | | Optional detailed description |
| `default_mandatory_flag` | `boolean` | | Default behavior |
| `display_sequence` | `int` | | Display order |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |
| `created_by` | `varchar(50)` | | User who created |
| `created_at` | `timestamp` | | Creation timestamp |
| `updated_by` | `varchar(50)` | | User who last updated |
| `updated_at` | `timestamp` | | Last update timestamp |

---

## 10. Archetype WBS QA Mapping

**Purpose:** Maps QA checklist items to a specific QA-type WBS object.

| Column | Type | Key | Notes |
|--------|------|-----|-------|
| `archetype_wbs_qa_map_id` | `int` | PK | Primary Key |
| `archetype_wbs_id` | `int` | FK | Foreign Key to Archetype WBS Definition |
| `qa_checklist_item_id` | `int` | FK | Foreign Key to QA Checklist Item Master |
| `mandatory_flag` | `boolean` | | Allows override per archetype |
| `display_sequence` | `int` | | Display order |
| `status` | `varchar(20)` | | ACTIVE / INACTIVE |
| `created_by` | `varchar(50)` | | User who created mapping |
| `created_at` | `timestamp` | | Creation timestamp |

---

## Relationships Overview

### Primary Relationships

1. **Role Master** → **Archetype WBS Access Matrix** (one-to-many)
2. **Action Master** → **Archetype WBS Access Matrix** (one-to-many)
3. **Archetype Master** → **Archetype WBS Definition** (one-to-many)
4. **Archetype Master** → **Project Archetype Link** (one-to-many)
5. **WBS Type Master** → **Archetype WBS Definition** (one-to-many)
6. **Archetype WBS Definition** → **Archetype WBS Definition** (self-referencing for hierarchy)
7. **Archetype WBS Definition** → **Archetype WBS Access Matrix** (one-to-many)
8. **Archetype WBS Definition** → **Archetype WBS QA Mapping** (one-to-many)
9. **QA Checklist Master** → **QA Checklist Item Master** (one-to-many)
10. **QA Checklist Item Master** → **Archetype WBS QA Mapping** (one-to-many)

---

## Key Constraints

### Unique Constraints
- `role_code` in **Role Master**
- `action_code` in **Action Master**
- `(archetype_wbs_id, role_id, action_id)` in **Archetype WBS Access Matrix**
- `(archetype_id, wbs_code)` in **Archetype WBS Definition**
- `(archetype_wbs_id, qa_checklist_item_id)` in **Archetype WBS QA Mapping**

### Foreign Key Constraints
- All FK relationships must be enforced with proper referential integrity
- Self-referencing FK in **Archetype WBS Definition** (`parent_wbs_id`)
- Cascade rules should be defined based on business requirements

### Check Constraints
- `status` fields: CHECK (status IN ('ACTIVE', 'INACTIVE'))
- Boolean fields should have proper default values
- `display_sequence` and `level_no` should be positive integers

---

## Implementation Notes

### Indexes Recommended
- Primary keys (auto-indexed)
- All foreign keys
- Unique constraints
- Frequently queried columns (`status`, `display_sequence`)
- Composite indexes for common query patterns

### Audit Requirements
- Consider audit tables for tracking changes to critical entities
- Log all access control modifications
- Track archetype version changes

### Data Integrity
- Enforce NOT NULL constraints on mandatory fields
- Set appropriate default values
- Implement soft delete using status field where applicable

---

*Document Version: 1.0*  
*Created: March 13, 2026*  
*Location: `/02 Solution Architecture/Governance/EPMS Governance Data Model.md`*
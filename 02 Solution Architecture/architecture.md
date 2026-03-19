# EPMS Project Initiation - Architecture Documentation

This document collates all sequence diagrams and architectural artifacts for the Project Initiation module of the Enterprise Project Management System (EPMS).

## Table of Contents
1. [System Overview](#system-overview)
2. [Entity Relationship Diagram](#entity-relationship-diagram)
3. [Program Management](#program-management)
4. [Value Creation Framework (VCF)](#value-creation-framework-vcf)
5. [Project Management](#project-management)
6. [Approval Workflows](#approval-workflows)
7. [Search and View Operations](#search-and-view-operations)

---

## System Overview

### High-Level Initiation Flow

```mermaid
graph TD

    User --> UI
    UI --> API_Gateway
    API_Gateway --> Initiation_BFF
    Initiation_BFF --> Orchestrator
    Orchestrator --> Domain_Microservices
    Domain_Microservices --> PostgreSQL
    Orchestrator --> Temporal_Workflow
    Orchestrator --> Notification_Adapter_Logger["Notification / Adapter / Logger"]
    Orchestrator --> Redis["Redis (for reads)"]
```

### User Role Flow Chart

```mermaid
flowchart TD

    A[Project Initiation]

    A --> BP[Business Partner]
    A --> BPM[Business Partner Manager]
    A --> GH[Governance Head]
    A --> COE[CoE Head]
    A --> BU[Business User]

    %% Business Partner
    BP --> BP1[View Projects<br/>View list of demands]
    BP --> BP2[Create Program<br/>Creates Program ID]
    BP --> BP3[Create Project<br/>Against existing Demand ID<br/>Creates Project ID]
    BP --> BP4[Create VCF<br/>Against Program ID]
    BP --> BP5[Associate Project with Program ID]
    BP --> BP6[Update VCF<br/>Against Program ID]

    BP2 --> BP4
    BP3 --> BP5
    BP4 --> BP5
    BP5 --> BP6

    %% Business Partner Manager
    BPM --> BPM1[View Projects<br/>View list of projects]
    BPM --> BPM2[Approve Project]

    %% Governance Head
    GH --> GH1[View Projects<br/>View list of programs]
    GH --> GH2[Approve Project]

    %% CoE Head
    COE --> COE1[View Projects<br/>View list of programs]
    COE --> COE2[Approve Project<br/>Against Project ID]
    COE --> COE3[Assign Project Manager<br/>For approved projects<br/>Against Project ID]

    COE2 --> COE3

    %% Business User
    BU --> BU1[View Projects<br/>View list of approved projects]
    BU --> BU2[Upload BRD<br/>Against Project ID]

    %% Approval flow
    BP3 --> BPM2
    BPM2 --> GH2
    GH2 --> COE2
    COE3 --> BU1
    BU1 --> BU2
```

---

## Entity Relationship Diagram

The following ERD represents the core data model for the Project Initiation module:

```mermaid
erDiagram

    DEMAND {
        VARCHAR(20) demand_id PK
        VARCHAR(255) demand_title
        TEXT demand_description
        VARCHAR(30) status
        VARCHAR(50) created_by
        TIMESTAMP created_at
    }

    PROJECT {
        VARCHAR(20) project_id PK
        VARCHAR(20) demand_id FK
        VARCHAR(20) program_id FK
        VARCHAR(255) project_name
        VARCHAR(50) project_type
        DATE expected_start_date
        DATE expected_end_date
        DECIMAL budget_amount
        VARCHAR(10) budget_currency
        VARCHAR(30) status
        VARCHAR(20) manpower_estimate_id FK
        VARCHAR(30) project_status
        VARCHAR(30) Approval_Status_code FK
        VARCHAR(50) Approval_stage_Code FK
        VARCHAR(50) created_by
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    MANPOWER_ESTIMATE {
        VARCHAR(20) manpower_estimate_id PK
        VARCHAR(20) project_id FK
        VARCHAR(100) skillset
        INT headcount
        DECIMAL utilization_percentage
        DATE start_date
        DATE end_date
        VARCHAR(255) remarks
        TIMESTAMP created_at
    }

    PROJECT_APPROVAL {
        VARCHAR(20) approval_id PK
        VARCHAR(20) project_id FK
        VARCHAR(50) approver_user_id FK
        VARCHAR(50) approver_role
        VARCHAR(50) approval_stage
        VARCHAR(30) approval_status
        VARCHAR(255) comments
        TIMESTAMP action_at
    }

    PROGRAM {
        VARCHAR(20) program_id PK
        VARCHAR(20) demand_id FK
        VARCHAR(255) program_name
        TEXT program_description
        INT program_start_year
        VARCHAR(50) program_type
        VARCHAR(50) ownership_type
        VARCHAR(50) business_spoc_id FK
        VARCHAR(100) business_vertical
        VARCHAR(50) investment_category
        VARCHAR(100) program_classification
        VARCHAR(20) program_de_pillar_id FK
        VARCHAR(30) program_status
        VARCHAR(30) Approval_Status_code FK
        VARCHAR(50) Approval_stage_Code FK
        BOOLEAN is_approved
        VARCHAR(50) created_by
        TIMESTAMP created_at
        VARCHAR(50) updated_by
        TIMESTAMP updated_at
    }

    PROGRAM_DE_PILLAR {
        VARCHAR(20) program_de_pillar_id PK
        VARCHAR(20) program_id FK
        VARCHAR(20) de_pillar
    }

    VCF {
        VARCHAR(20) program_id PK, FK
        VARCHAR(20) value_lever_id FK
        VARCHAR(20) cost_lever_id FK
        VARCHAR(30) status
        DECIMAL npv
        DECIMAL irr
        VARCHAR(50) created_by
        TIMESTAMP created_at
        VARCHAR(50) updated_by
        TIMESTAMP updated_at
        VARCHAR(500) remarks
    }

    VCF_VALUE_LEVER {
        VARCHAR(20) program_id FK
        VARCHAR(20) value_lever_id PK
        INT effective_year
        VARCHAR(255) lever_name
        DECIMAL amount
        INT display_order
        BOOLEAN is_active
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    VCF_COST_LEVER {
        VARCHAR(20) program_id FK
        VARCHAR(20) cost_lever_id PK
        INT effective_year
        VARCHAR(255) Cost_lever_name
        DECIMAL amount
        INT display_order
        BOOLEAN is_active
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    VCF_VERSION_HISTORY {
        VARCHAR(20) history_id PK
        VARCHAR(20) value_lever_id PK, FK
        VARCHAR(20) cost_lever_id PK, FK
        INT version_no
        VARCHAR(500) change_summary
        VARCHAR(50) changed_by FK
        TIMESTAMP changed_at
    }

    APPROVAL_WORKFLOW_STEP {
        VARCHAR(20) workflow_step_id PK
        VARCHAR(20) entity_type
        VARCHAR(20) entity_id
        VARCHAR(50) stage_code FK
        VARCHAR(50) approver_user_id FK
        VARCHAR(30) step_status
        VARCHAR(500) comments
        TIMESTAMP action_at
        INT sequence_no
    }

    APPROVAL_STATUS_MASTER {
        VARCHAR(50) approval_status_code PK
        VARCHAR(100) approval_status_name
        BOOLEAN is_active
    }

    APPROVAL_STAGE_MASTER {
        VARCHAR(50) stage_code PK
        VARCHAR(100) stage_name
        BOOLEAN is_active
    }

 DEMAND ||--o{ PROGRAM : creates
    DEMAND ||--o{ PROJECT : creates

    PROGRAM ||--o{ PROJECT : groups
    PROGRAM ||--|| VCF : has
    PROGRAM ||--o{ PROGRAM_DE_PILLAR : classified_by

    PROJECT ||--o{ MANPOWER_ESTIMATE : has
    PROJECT ||--o{ PROJECT_APPROVAL : approved_through
    PROJECT ||--o{ APPROVAL_WORKFLOW_STEP : progresses_through

    PROGRAM ||--o{ APPROVAL_WORKFLOW_STEP : progresses_through

    VCF ||--o{ VCF_VALUE_LEVER : contains
    VCF ||--o{ VCF_COST_LEVER : contains
    VCF ||--o{ VCF_VERSION_HISTORY : versioned_by

    APPROVAL_STATUS_MASTER ||--o{ PROJECT : status_of
    APPROVAL_STATUS_MASTER ||--o{ PROGRAM : status_of

    APPROVAL_STAGE_MASTER ||--o{ PROJECT : stage_of
    APPROVAL_STAGE_MASTER ||--o{ PROGRAM : stage_of
    APPROVAL_STAGE_MASTER ||--o{ APPROVAL_WORKFLOW_STEP : drives
```

---

## Program Management

### 3.1 Program Creation

**Description**: Business Partner creates a program against an existing Demand ID. The program is initially saved in DRAFT status and goes through validation including demand validation and optional HRMS lookup for Business SPOC details.

**Key Points**:
- Demand is validated first
- Program is created against an existing Demand ID
- Business SPOC / employee details may be fetched from HRMS via Service Adapter
- Program is initially saved in DRAFT
- Orchestrator coordinates: demand validation, HRMS lookup, program creation, status/approval status/stage initialization, workflow step creation

```mermaid
sequenceDiagram
autonumber
actor BP as Business Partner
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PROGJO as Program Journey <br/>Orchestrator
participant DS as Demand Service
participant CACHE as Redis Cache
participant ADAPTER as Service Adapter
participant PRS as Program Service
participant DB as PostgreSQL
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service <br/>(Indexing Only)

BP->>UI: Enter program <br/>details with Demand ID
UI->>APIG: POST /programs/initiate
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success
APIG->>BFF: Forward request<br/> for program initiation
BFF->>PROGJO: Initiate program<br/> creation journey

PROGJO->>DS: Validate Demand ID
DS->>CACHE: Check demand cache
alt Demand cache hit
    CACHE-->>DS: Demand details
else Demand cache miss
    DS->>DB: Fetch demand
    DB-->>DS: Demand details
    DS->>CACHE: Update demand cache
end
DS-->>PROGJO: Demand valid

opt Business SPOC / HRMS validation needed
    PROGJO->>ADAPTER: Fetch Business<br/> SPOC details from HRMS
    ADAPTER-->>PROGJO: Employee profile<br/> and business vertical
end

PROGJO->>PRS: Create program in DRAFT
PRS->>DB: Insert Program record
DB-->>PRS: Program ID generated
PRS-->>PROGJO: Program created

PROGJO->>PRS: Update program_status=<br/> DRAFT
PRS->>DB: Update Program status
DB-->>PRS: Updated
PRS-->>PROGJO: Program status updated

PROGJO->>PRS: Update approval_status_code=<br/> NOT_SUBMITTED
PRS->>DB: Update approval status reference
DB-->>PRS: Updated
PRS-->>PROGJO: Approval status updated

PROGJO->>PRS: Update approval_stage_code = <br/>BP_DRAFT
PRS->>DB: Update approval <br/>stage reference
DB-->>PRS: Updated
PRS-->>PROGJO: Approval stage updated

PROGJO->>PRS: Create workflow step entry
PRS->>DB: Insert Approval_Workflow_Step
DB-->>PRS: Inserted
PRS-->>PROGJO: Workflow step created

PROGJO->>BUS: Publish ProgramCreated event

BUS-->>NOTIF: ProgramCreated
BUS-->>LOG: ProgramCreated
BUS-->>SEARCH: ProgramCreated <br/>(Index for future search)

PROGJO-->>BFF: Program creation response
BFF-->>APIG: Response
APIG-->>UI: Program created
UI-->>BP: Display success message
```

### 3.2 Program View and Search (Business Partner)

**Description**: Business Partner searches and views programs with caching support.

```mermaid
sequenceDiagram
autonumber
actor BP as Business Partner
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant CACHE as Redis Cache
participant PRS as Program Service<br/>(Query)
participant RR as PostgreSQL <br/>Read Replica

BP->>UI: Search Programs
UI->>APIG: GET /programs?filters
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward request

BFF->>CACHE: Check program cache
alt Cache Hit
    CACHE-->>BFF: Program list
else Cache Miss
    BFF->>PRS: Fetch programs with filters
    PRS->>RR: Query read replica
    RR-->>PRS: Program list<br/>(Program Table)
    PRS-->>BFF: Response
    BFF->>CACHE: Store cache
end

BFF-->>APIG: Program list
APIG-->>UI: Display programs
UI-->>BP: View results
```

### 3.3 Program View and Search (Governance Head / CoE Head)

**Description**: Governance Head and CoE Head can view programs along with VCF data.

```mermaid
sequenceDiagram
autonumber
actor BP as Governance Head<br/>CoE Head
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant CACHE as Redis Cache
participant PRS as Program Service<br/>(Query)
participant RR as PostgreSQL <br/>Read Replica

BP->>UI: Search Programs
UI->>APIG: GET /programs?filters
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward request

BFF->>CACHE: Check program cache
alt Cache Hit
    CACHE-->>BFF: Program list
else Cache Miss
    BFF->>PRS: Fetch programs Join VCF <br/>with filters
    PRS->>RR: Query read replica
    RR-->>PRS: Program list<br/>(Program Data&<br/>VCF Data)
    PRS-->>BFF: Response
    BFF->>CACHE: Store cache
end

BFF-->>APIG: Program list
APIG-->>UI: Display programs
UI-->>BP: View results
```

---

## Value Creation Framework (VCF)

### 4.1 VCF Entry

**Description**: Business Partner enters VCF details for a program including value levers and cost levers.

```mermaid
sequenceDiagram
autonumber
actor BP as Business Partner
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PROGJO as Program Journey <br/>Orchestrator
participant CACHE as Redis Cache
participant PRS as Program Service
participant DB as PostgreSQL Primary
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service <br/>(Indexing Only)

BP->>UI: Enter VCF details for Program
UI->>APIG: POST /programs/{programId}/vcf
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward request
BFF->>PROGJO: Initiate VCF creation

PROGJO->>CACHE: Check program cache
alt Cache hit
    CACHE-->>PROGJO: Program details
else Cache miss
    PROGJO->>PRS: Fetch program
    PRS->>DB: Query program
    DB-->>PRS: Program details
    PRS-->>PROGJO: Response
    PROGJO->>CACHE: Update program cache
end

PROGJO->>PRS: Create VCF for program

PRS->>DB: Insert VCF record
PRS->>DB: Insert VCF Value Levers
PRS->>DB: Insert VCF Cost Levers

DB-->>PRS: VCF stored

PRS-->>PROGJO: VCF created

PROGJO->>BUS: Publish VCFCreated event

BUS-->>NOTIF: VCFCreated
BUS-->>LOG: VCFCreated
BUS-->>SEARCH: Update program index

PROGJO-->>BFF: Response
BFF-->>APIG: Response
APIG-->>UI: VCF created successfully
UI-->>BP: Display confirmation
```

### 4.2 VCF Update by Program ID

**Description**: Business Partner updates VCF for an existing program. The system maintains version history of VCF changes.

```mermaid
sequenceDiagram
autonumber
actor BP as Business Partner
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PROGJO as Program Journey <br/>Orchestrator
participant CACHE as Redis Cache
participant PRS as Program Service
participant DB as PostgreSQL Primary
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service <br/>(Indexing Only)

BP->>UI: Update VCF for<br/> existing Program
UI->>APIG: PUT /programs/{programId}/vcf
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward request
BFF->>PROGJO: Initiate VCF update

PROGJO->>CACHE: Check program <br/> VCF cache
alt Cache hit
    CACHE-->>PROGJO: Program + VCF details
else Cache miss
    PROGJO->>PRS: Fetch program <br/>and current VCF
    PRS->>DB: Query Program
    PRS->>DB: Query current VCF
    DB-->>PRS: Program + VCF details
    PRS-->>PROGJO: Response
    PROGJO->>CACHE: Update cache
end

PROGJO->>PRS: Update VCF <br/>for Program ID

PRS->>DB: Fetch current VCF version
DB-->>PRS: Current VCF version

PRS->>DB: Insert VCF version history
PRS->>DB: Update / Insert <br/>VCF Value Levers
PRS->>DB: Update / Insert <br/>VCF Cost Levers

DB-->>PRS: VCF updated <br/>successfully
PRS-->>PROGJO: VCF updated

PROGJO->>BUS: Publish <br/>VCFUpdated event

BUS-->>NOTIF: VCFUpdated
BUS-->>LOG: VCFUpdated
BUS-->>SEARCH: Update program index

PROGJO-->>BFF: Response
BFF-->>APIG: Response
APIG-->>UI: VCF updated <br/>successfully
UI-->>BP: Display confirmation
```

---

## Project Management

### 5.1 Project Creation against Demand (Simple Flow)

**Description**: Basic flow for creating a project against a demand.

```mermaid
sequenceDiagram
autonumber
actor BP as Business Partner
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant CACHE as Redis Cache
participant PJO as Project Journey Orchestrator
participant DS as Demand Service
participant PS as Project Service
participant DB as PostgreSQL
participant BUS as Event Bus
participant SEARCH as Search Service (Indexing)
participant NOTIF as Notification Service
participant LOG as Logger Service

BP->>UI: Enter project <br/> details with Demand ID
UI->>APIG: POST /projects
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward request <br/>for project initiation

BFF->>PJO: Initiate project creation

PJO->>DS: Validate Demand ID
DS->>CACHE: Check demand cache
alt Cache hit
    CACHE-->>DS: Demand details
else Cache miss
    DS->>DB: Fetch demand
    DB-->>DS: Demand record
    DS->>CACHE: Update cache
end

DS-->>PJO: Demand valid

PJO->>PS: Create project
PS->>DB: Insert project record
DB-->>PS: Project ID generated
PS-->>PJO: Project created

PJO->>BUS: Publish ProjectCreated event

BUS-->>NOTIF: ProjectCreated
BUS-->>LOG: ProjectCreated
BUS-->>SEARCH: ProjectCreated<br/>(Index for search)

NOTIF->>BP: Send notification

PJO-->>BFF: Project creation response
BFF-->>APIG: Response
APIG-->>UI: Project created
UI-->>BP: Display success message
```

### 5.2 Project Creation against Demand - Part 1 (Detailed Flow)

**Description**: Validates demand, checks if program exists, fetches VCF, and either continues with project creation or redirects to program creation.

**Key Points**:
1. Validate Demand ID
2. Check whether a Program already exists for that demand/selected context
3. If program exists: fetch program details, fetch existing VCF details, continue project creation flow
4. If program does not exist: open/redirect to program creation flow, save project as DRAFT

```mermaid
sequenceDiagram
autonumber
actor BP as Business Partner
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PJO as Project Journey Orchestrator
participant DS as Demand Service
participant PRS as Program Service
participant VCF as VCF Service<br/>(::Program)
participant PS as Project Service
participant CACHE as Redis Cache
participant DB as PostgreSQL
participant BUS as Event Bus

BP->>UI: Enter project details <br/>with Demand ID
UI->>APIG: POST /projects/initiate
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success
APIG->>BFF: Forward request
BFF->>PJO: Initiate project <br/>creation journey

PJO->>DS: Validate Demand ID
DS->>CACHE: Check demand cache
alt Demand cache hit
    CACHE-->>DS: Demand details
else Demand cache miss
    DS->>DB: Fetch demand
    DB-->>DS: Demand details
    DS->>CACHE: Update demand cache
end
DS-->>PJO: Demand valid

PJO->>PRS: Find program by <br/>Demand ID / context
PRS->>DB: Query program
alt Program exists
    DB-->>PRS: Program details
    PRS-->>PJO: Existing program found

    PJO->>VCF: Fetch VCF for Program ID
    VCF->>DB: Query VCF details
    DB-->>VCF: VCF details
    VCF-->>PJO: Existing VCF returned

    PJO->>PS: Create project linked <br/>to Demand ID <br/>and Program ID
    PS->>DB: Insert project in <br/>DRAFT/<br/>INITIATED state
    DB-->>PS: Project ID generated
    PS-->>PJO: Project created
else No program found
    DB-->>PRS: No program found
    PRS-->>PJO: Program not found

    PJO->>PS: Create project in <br/>DRAFT without Program ID
    PS->>DB: Insert draft project
    DB-->>PS: Project ID generated
    PS-->>PJO: Draft project created

    PJO-->>BFF: Response with <br/>projectId + action<br/>=CREATE_PROGRAM
    BFF-->>APIG: Response
    APIG-->>UI: Open Program <br/>Creation Flow
end

PJO->>BUS: Publish ProjectInitiated <br/>/ DraftCreated event
BUS-->>BFF: Async consumers continue
```

### 5.3 Project Creation against Demand - Part 2 (Status Updates)

**Description**: Updates status, approval stage, workflow step, and publishes side effects after project creation.

```mermaid
sequenceDiagram
autonumber
participant BFF as Initiation BFF
participant PJO as Project Journey Orchestrator
participant PS as Project Service
participant PRS as Program Service
participant DB as PostgreSQL
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service(Indexing)

BFF->>PJO: Continue orchestration <br/>after create result

alt Program exists and project linked successfully
    PJO->>PS: Update project_status= <br/>DRAFT / SUBMITTED
    PS->>DB: Update project table
    DB-->>PS: Updated
    PS-->>PJO: Status updated

    PJO->>PS: Update approval_status_code= <br/>NOT_SUBMITTED
    PS->>DB: Update project <br/>approval status reference
    DB-->>PS: Updated
    PS-->>PJO: Approval status updated

    PJO->>PS: Update approval_stage_code=<br/>BP_DRAFT
    PS->>DB: Update project <br/>approval stage reference
    DB-->>PS: Updated
    PS-->>PJO: Approval stage updated

    PJO->>PS: Create workflow step entry
    PS->>DB: Insert Approval_Workflow_Step
    DB-->>PS: Inserted
    PS-->>PJO: Workflow step created

    PJO->>BUS: Publish ProjectCreated event
else Program not found and draft project saved
    PJO->>PS: Update project_status = DRAFT
    PS->>DB: Update project table
    DB-->>PS: Updated
    PS-->>PJO: Status updated

    PJO->>PS: Update approval_status_code= <br/>NOT_SUBMITTED
    PS->>DB: Update approval <br/>status reference
    DB-->>PS: Updated
    PS-->>PJO: Approval status updated

    PJO->>PS: Update approval_stage_code= <br/>BP_DRAFT
    PS->>DB: Update approval stage reference
    DB-->>PS: Updated
    PS-->>PJO: Approval stage updated

    PJO->>PS: Create workflow<br/>step entry for draft
    PS->>DB: Insert Approval_Workflow_Step
    DB-->>PS: Inserted
    PS-->>PJO: Workflow step created

    PJO->>BUS: Publish <br/>ProjectDraftCreated event
end

BUS-->>NOTIF: ProjectCreated / ProjectDraftCreated
BUS-->>LOG: ProjectCreated / ProjectDraftCreated
BUS-->>SEARCH: Index project for future search
```

---

## Approval Workflows

### 6.1 Project Approval - Business Partner Manager (BPM)

**Description**: Business Partner Manager approves a project and forwards it to Governance Head for next level approval.

```mermaid
sequenceDiagram
autonumber
actor BPM as Business Partner Manager
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PJO as Project Journey <br/>Orchestrator
participant WF as Temporal Workflow
participant PS as Project Service
participant DB as PostgreSQL Primary
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service <br/>(Indexing Only)

BPM->>UI: Approve Project
UI->>APIG: POST /projects/{projectId}/approve
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward approval request
BFF->>PJO: Initiate approval action

PJO->>WF: Signal BPM approval for projectId
WF-->>PJO: BPM stage accepted

PJO->>PS: Update Project_Approval set <br/>approval_status='APPROVED', action_at, comments
PS->>DB: UPDATE Project_Approval
DB-->>PS: Updated

PJO->>PS: Update Approval_Workflow_Step set <br/>step_status='APPROVED', action_at
PS->>DB: UPDATE Approval_Workflow_Step
DB-->>PS: Updated

PJO->>PS: Update Project set <br/>Approval_Status_code='IN_APPROVAL', <br/>Approval_stage_Code='GOV_APPROVAL'
PS->>DB: UPDATE Project
DB-->>PS: Updated

PJO->>PS: Insert next approver step in <br/>Approval_Workflow_Step for Governance Head
PS->>DB: INSERT Approval_Workflow_Step
DB-->>PS: Inserted

PS-->>PJO: Approval persisted

PJO->>BUS: Publish ProjectApprovalStageCompleted event
BUS-->>NOTIF: Notify Governance Head
BUS-->>LOG: Log BPM approval
BUS-->>SEARCH: Update project index

PJO-->>BFF: Approval response
BFF-->>APIG: Response
APIG-->>UI: Project approved successfully
UI-->>BPM: Show success
```

### 6.2 Project Approval - Governance Head (GH)

**Description**: Governance Head approves a project and forwards it to CoE Head for final approval.

```mermaid
sequenceDiagram
autonumber
actor GOV as Governance Head
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PJO as Project Journey <br/>Orchestrator
participant WF as Temporal Workflow
participant PS as Project Service
participant DB as PostgreSQL Primary
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service (Indexing Only)

GOV->>UI: Approve Project
UI->>APIG: POST /projects/{projectId}/approve
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward approval request
BFF->>PJO: Initiate approval action

PJO->>WF: Signal Governance approval for projectId
WF-->>PJO: Governance stage accepted

PJO->>PS: Update Project_Approval set <br/>approval_status='APPROVED', action_at, comments
PS->>DB: UPDATE Project_Approval
DB-->>PS: Updated

PJO->>PS: Update Approval_Workflow_Step <br/>set step_status='APPROVED', action_at
PS->>DB: UPDATE Approval_Workflow_Step
DB-->>PS: Updated

PJO->>PS: Update Project set Approval_Status_code='IN_APPROVAL', Approval_stage_Code='COE_APPROVAL'
PS->>DB: UPDATE Project
DB-->>PS: Updated

PJO->>PS: Insert next approver step in <br/>Approval_Workflow_Step for CoE Head
PS->>DB: INSERT Approval_Workflow_Step
DB-->>PS: Inserted

PS-->>PJO: Approval persisted

PJO->>BUS: Publish ProjectApprovalStageCompleted event
BUS-->>NOTIF: Notify CoE Head
BUS-->>LOG: Log Governance approval
BUS-->>SEARCH: Update project index

PJO-->>BFF: Approval response
BFF-->>APIG: Response
APIG-->>UI: Project approved successfully
UI-->>GOV: Show success
```

### 6.3 Project Approval - CoE Head (Final Approval)

**Description**: CoE Head provides final approval. Project status is updated to APPROVED and can proceed to next phase.

```mermaid
sequenceDiagram
autonumber
actor COE as CoE Head
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PJO as Project Journey <br/>Orchestrator
participant WF as Temporal Workflow
participant PS as Project Service
participant DB as PostgreSQL Primary
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service <br/>(Indexing Only)

COE->>UI: Approve Project
UI->>APIG: POST /projects/{projectId}/approve
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward approval request
BFF->>PJO: Initiate approval action

PJO->>WF: Signal CoE approval for <br/>projectId
WF-->>PJO: CoE stage accepted

PJO->>PS: Update Project_Approval set <br/>approval_status='APPROVED', <br/>action_at, comments
PS->>DB: UPDATE Project_Approval
DB-->>PS: Updated

PJO->>PS: Update Approval_Workflow_Step <br/>set step_status='APPROVED', action_at
PS->>DB: UPDATE Approval_Workflow_Step
DB-->>PS: Updated

PJO->>PS: Update Project set <br/>project_status='APPROVED', Approval_Status_code='APPROVED', <br/>Approval_stage_Code='FINAL_APPROVED'
PS->>DB: UPDATE Project
DB-->>PS: Updated

PS-->>PJO: Final approval persisted

PJO->>BUS: Publish ProjectApproved event
BUS-->>NOTIF: Notify Business <br/>Partner and CoE team
BUS-->>LOG: Log final approval
BUS-->>SEARCH: Update project index

PJO-->>BFF: Approval response
BFF-->>APIG: Response
APIG-->>UI: Project approved <br/>successfully
UI-->>COE: Show success
```

### 6.4 Reject or Send Back Approval

**Description**: Any approver (BPM/Governance Head/CoE Head) can reject a project or send it back for revisions.

```mermaid
sequenceDiagram
autonumber
actor APR as Approver (BPM / <br/>Governance Head / <br/>CoE Head)
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PJO as Project Journey <br/>Orchestrator
participant WF as Temporal Workflow
participant PS as Project Service
participant DB as PostgreSQL Primary
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service <br/>(Indexing Only)

APR->>UI: Reject / <br/>Send Back Project
UI->>APIG: POST /projects/{projectId}/reject-or-sendback
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward reject / <br/>send back request
BFF->>PJO: Initiate reject / <br/>send back action

PJO->>WF: Signal reject / s<br/>end back with approver_role, <br/>stage_code, comments
WF-->>PJO: Stage action accepted

PJO->>PS: Update Project_Approval set <br/>approval_status='REJECTED' or 'SENT_BACK', <br/>approver_user_id, approver_role, <br/>approval_stage, comments, action_at
PS->>DB: UPDATE Project_Approval
DB-->>PS: Updated

PJO->>PS: Update Approval_Workflow_Step set <br/>step_status='REJECTED' or 'SENT_BACK', approver_user_id, <br/>comments, action_at
PS->>DB: UPDATE Approval_Workflow_Step
DB-->>PS: Updated

alt Action = REJECTED
    PJO->>PS: Update Project set <br/>project_status='REJECTED', Approval_Status_code='REJECTED', Approval_stage_Code=stage_code
    PS->>DB: UPDATE Project
    DB-->>PS: Updated
else Action = SENT_BACK
    PJO->>PS: Update Project set project_status='REVISION_REQUIRED', <br/>Approval_Status_code='SENT_BACK', <br/>Approval_stage_Code='BP_DRAFT'
    PS->>DB: UPDATE Project
    DB-->>PS: Updated
end

PS-->>PJO: Reject / send back persisted

PJO->>BUS: Publish ProjectRejected or <br/>ProjectSentBack event
BUS-->>NOTIF: Notify Business Partner
BUS-->>LOG: Log reject / send back action
BUS-->>SEARCH: Update project index

PJO-->>BFF: Action response
BFF-->>APIG: Response
APIG-->>UI: Project action completed
UI-->>APR: Show success
```

### 6.5 Assign Project Manager

**Description**: After final approval, CoE Head assigns a Project Manager to the approved project.

```mermaid
sequenceDiagram
autonumber
actor COE as CoE Head
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant PJO as Project Journey <br/>Orchestrator
participant ADAPTER as Service Adapter
participant PS as Project Service
participant DB as PostgreSQL Primary
participant BUS as Event Bus
participant NOTIF as Notification Service
participant LOG as Logger Service
participant SEARCH as Search Service <br/>(Indexing Only)

COE->>UI: Assign Project Manager <br/>for approved project
UI->>APIG: POST /projects/{projectId}/assign-project-manager
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success

APIG->>BFF: Forward assign PM request
BFF->>PJO: Initiate PM assignment action

PJO->>PS: Fetch Project from Project table
PS->>DB: SELECT Project
DB-->>PS: Project details
PS-->>PJO: Project returned

PJO->>ADAPTER: Fetch Project Manager profile from SAP HRMS
ADAPTER-->>PJO: PM profile validated

PJO->>PS: Update Project set project_manager_id,<br/>project_status='READY_FOR_BRD', <br/>updated_at in Project table
PS->>DB: UPDATE Project
DB-->>PS: Updated

PJO->>PS: Insert PM assignment step in <br/>Approval_Workflow_Step table
PS->>DB: INSERT Approval_Workflow_Step
DB-->>PS: Inserted

PS-->>PJO: Project Manager assignment persisted

PJO->>BUS: Publish ProjectManagerAssigned event
BUS-->>NOTIF: Notify assigned Project <br/>Manager and Business Partner
BUS-->>LOG: Log PM assignment action
BUS-->>SEARCH: Update project index

PJO-->>BFF: Assignment response
BFF-->>APIG: Response
APIG-->>UI: Project Manager assigned successfully
UI-->>COE: Show success
```

---

## Search and View Operations

### 7.1 Project View and Search (All Roles)

**Description**: All user roles (Business Partner, BPM, Governance Head, CoE Head, Business User) can search and view projects based on their permissions.

```mermaid
sequenceDiagram
autonumber
actor BP as Business Partner<br/>Business Partner Manager<br/>Governance Head<br/>CoE Head<br/>Business User
participant UI
participant APIG as API Gateway
participant IDAM as Azure AD / IDAM
participant BFF as Initiation BFF
participant CACHE as Redis Cache
participant PS as Project Service (Query)
participant RR as PostgreSQL <br/>Read Replica

BP->>UI: Search / filter projects
UI->>APIG: GET /projects?filters
APIG->>IDAM: Authenticate request
IDAM-->>APIG: Authentication success
APIG->>BFF: Forward request

BFF->>CACHE: Check cached query result
alt Cache Hit
    CACHE-->>BFF: Project list
else Cache Miss
    BFF->>PS: Fetch projects with filters
    PS->>RR: Query read replica
    RR-->>PS: Project list
    PS-->>BFF: Response
    BFF->>CACHE: Store cached result
end

BFF-->>APIG: Project list
APIG-->>UI: Display projects
UI-->>BP: View results
```

---

## Architecture Principles

### Key Design Patterns

1. **Orchestration Pattern**: Journey orchestrators coordinate multi-step workflows
2. **CQRS Pattern**: Separate read and write operations with read replicas
3. **Event-Driven Architecture**: Asynchronous communication via Event Bus
4. **Cache-Aside Pattern**: Redis caching for frequently accessed data
5. **Service Adapter Pattern**: Integration with external systems (HRMS, SAP)

### Technology Stack

- **API Gateway**: Entry point for all requests
- **Authentication**: Azure AD / IDAM
- **BFF (Backend for Frontend)**: Initiation BFF
- **Orchestration**: Temporal Workflow Engine
- **Databases**: PostgreSQL (Primary + Read Replicas)
- **Caching**: Redis
- **Messaging**: Event Bus
- **Services**: Microservices architecture with domain-driven design

### Data Flow

1. **Write Path**: UI → API Gateway → BFF → Orchestrator → Domain Services → PostgreSQL Primary → Event Bus
2. **Read Path**: UI → API Gateway → BFF → Cache (if hit) OR Query Services → PostgreSQL Read Replica

### Security & Compliance

- All requests authenticated via Azure AD/IDAM
- Role-based access control (RBAC) for different user types
- Audit logging via Logger Service
- Secure communication between services

---

## Conclusion

This architecture document provides a comprehensive overview of the Project Initiation module's sequence diagrams and workflows. The system follows modern microservices patterns with clear separation of concerns, event-driven communication, and robust approval workflows.

**Key Features**:
- Multi-stage approval workflow (BP → BPM → GH → CoE Head)
- Program and Project lifecycle management
- Value Creation Framework (VCF) with version control
- Comprehensive search and view capabilities
- Integration with external systems (HRMS, SAP)
- Scalable and maintainable architecture

---

*Document Generated: March 13, 2026*  
*Version: 1.0*  
*Source: Project Initiation Diagrams from `/02 Solution Architecture/diagrams/Project Initiation`*

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE idea_status_enum AS ENUM (
    'DRAFT',
    'SUBMITTED',
    'UNDER_EVALUATION',
    'APPROVED',
    'REJECTED'
);

CREATE TABLE idea (
    idea_id        UUID PRIMARY KEY,
    title          VARCHAR(255) NOT NULL,
    description    TEXT NOT NULL,
    status         idea_status_enum NOT NULL,
    created_by     UUID NOT NULL,
    created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_idea_status ON idea(status);
CREATE INDEX idx_idea_created_by ON idea(created_by);

CREATE TABLE idea_value_proposition (
    vp_id              UUID PRIMARY KEY,
    idea_id            UUID NOT NULL UNIQUE,
    business_value     TEXT NOT NULL,
    user_value         TEXT NOT NULL,
    stakeholder_value  TEXT NOT NULL,

    CONSTRAINT fk_vp_idea
        FOREIGN KEY (idea_id)
        REFERENCES idea (idea_id)
        ON DELETE CASCADE
);

CREATE TABLE idea_dvf_score (
    dvf_id         UUID PRIMARY KEY,
    idea_id        UUID NOT NULL UNIQUE,
    desirability   TEXT NOT NULL,
    viability      TEXT NOT NULL,
    feasibility    TEXT NOT NULL,

    CONSTRAINT fk_dvf_idea
        FOREIGN KEY (idea_id)
        REFERENCES idea (idea_id)
        ON DELETE CASCADE
);


CREATE TABLE idea_business_department (
    id            UUID PRIMARY KEY,
    idea_id       UUID NOT NULL,
    department    VARCHAR(100) NOT NULL,
    is_primary    BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT fk_department_idea
        FOREIGN KEY (idea_id)
        REFERENCES idea (idea_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_department_idea_id
ON idea_business_department (idea_id);


CREATE TABLE idea_team_member (
    idea_id     UUID NOT NULL,
    user_id     UUID NOT NULL,
    role        VARCHAR(50),
    added_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    PRIMARY KEY (idea_id, user_id),

    CONSTRAINT fk_team_idea
        FOREIGN KEY (idea_id)
        REFERENCES idea (idea_id)
        ON DELETE CASCADE
);

CREATE TABLE idea_document (
    document_id     UUID PRIMARY KEY,
    idea_id         UUID NOT NULL,
    document_type   VARCHAR(50) NOT NULL,
    file_name       VARCHAR(255) NOT NULL,
    file_url        TEXT NOT NULL,
    uploaded_by     UUID NOT NULL,
    uploaded_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    CONSTRAINT fk_document_idea
        FOREIGN KEY (idea_id)
        REFERENCES idea (idea_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_document_idea_id
ON idea_document (idea_id);

CREATE TABLE idea_read (
    idea_id      UUID PRIMARY KEY,
    title        VARCHAR(255),
    status       idea_status_enum,
    created_by   UUID,
    created_at   TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_idea_read_status
ON idea_read (status);

CREATE TABLE outbox (
    id              UUID PRIMARY KEY,
    aggregate_type  VARCHAR(100) NOT NULL,
    aggregate_id    UUID NOT NULL,
    event_type      VARCHAR(100) NOT NULL,
    payload         JSONB NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    published       BOOLEAN NOT NULL DEFAULT false,
    retry_count     INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_outbox_unpublished
ON outbox (published, created_at);

CREATE TABLE idempotency_key (
    idempotency_key   VARCHAR(100) PRIMARY KEY,
    processed_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

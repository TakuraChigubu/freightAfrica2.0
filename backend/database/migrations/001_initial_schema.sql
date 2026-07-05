CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    avatar_url VARCHAR(500),
    google_id VARCHAR(255) UNIQUE,
    google_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS organisations (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    logo_url VARCHAR(500),
    country VARCHAR(100),
    city VARCHAR(100),
    vat_number VARCHAR(50) UNIQUE,
    description TEXT,
    website VARCHAR(500),
    phone_number VARCHAR(20),
    email VARCHAR(255),
    owner_id BIGINT NOT NULL,
    subscription_tier VARCHAR(50) DEFAULT 'free',
    subscription_status VARCHAR(50) DEFAULT 'active',
    subscription_expires_at TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    organisation_id BIGINT,
    is_system_role BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS permissions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    organisation_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, organisation_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS loads (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    organisation_id BIGINT NOT NULL,
    source VARCHAR(50) NOT NULL,
    source_id VARCHAR(255),
    origin_city VARCHAR(255),
    origin_country VARCHAR(100),
    destination_city VARCHAR(255),
    destination_country VARCHAR(100),
    border_crossing VARCHAR(255),
    cargo_type VARCHAR(100),
    commodity_category VARCHAR(100),
    weight_kg DECIMAL(12, 2),
    number_of_trucks INT DEFAULT 1,
    truck_type VARCHAR(100),
    hazardous_goods BOOLEAN DEFAULT FALSE,
    hazmat_code VARCHAR(50),
    special_instructions TEXT,
    pickup_date DATE,
    pickup_time_window VARCHAR(20),
    delivery_date DATE,
    delivery_time_window VARCHAR(20),
    currency VARCHAR(10) DEFAULT 'ZWL',
    listed_price DECIMAL(12, 2),
    estimated_price DECIMAL(12, 2),
    negotiable BOOLEAN DEFAULT TRUE,
    broker_phone VARCHAR(20),
    broker_whatsapp VARCHAR(20),
    broker_name VARCHAR(255),
    broker_email VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',
    moderation_status VARCHAR(50) DEFAULT 'pending',
    moderation_notes TEXT,
    moderation_rejected_by BIGINT,
    moderation_rejected_at TIMESTAMP,
    ai_confidence_score DECIMAL(5, 2),
    ai_parsing_log_id BIGINT,
    duplicate_detected BOOLEAN DEFAULT FALSE,
    duplicate_load_id BIGINT,
    fraud_risk_score DECIMAL(5, 2),
    is_public BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    unlock_count INT DEFAULT 0,
    published_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE,
    FOREIGN KEY (moderation_rejected_by) REFERENCES users(id),
    FOREIGN KEY (duplicate_load_id) REFERENCES loads(id)
);

CREATE TABLE IF NOT EXISTS whatsapp_messages (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    message_id VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    message_content TEXT NOT NULL,
    message_type VARCHAR(50),
    media_url VARCHAR(500),
    processing_status VARCHAR(50) DEFAULT 'pending',
    processing_error TEXT,
    load_id BIGINT,
    organisation_id BIGINT,
    received_at TIMESTAMP NOT NULL,
    processed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (load_id) REFERENCES loads(id) ON DELETE SET NULL,
    FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS ai_parsing_logs (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    source_type VARCHAR(50),
    source_id BIGINT,
    raw_input TEXT NOT NULL,
    parsed_output JSONB,
    confidence_score DECIMAL(5, 2),
    gemini_request_id VARCHAR(255),
    gemini_model VARCHAR(100),
    gemini_tokens_input INT,
    gemini_tokens_output INT,
    validation_status VARCHAR(50),
    validation_errors JSONB,
    duplicate_detected BOOLEAN DEFAULT FALSE,
    duplicate_match_id BIGINT,
    duplicate_similarity_score DECIMAL(5, 2),
    fraud_risk_score DECIMAL(5, 2),
    fraud_flags JSONB,
    requires_manual_review BOOLEAN DEFAULT FALSE,
    manual_review_reason VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS moderation_queue (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    load_id BIGINT NOT NULL,
    ai_parsing_log_id BIGINT,
    reason VARCHAR(255),
    priority VARCHAR(50) DEFAULT 'normal',
    status VARCHAR(50) DEFAULT 'pending',
    assigned_to BIGINT,
    reviewed_by BIGINT,
    notes TEXT,
    assigned_at TIMESTAMP,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (load_id) REFERENCES loads(id) ON DELETE CASCADE,
    FOREIGN KEY (ai_parsing_log_id) REFERENCES ai_parsing_logs(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS wallets (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL UNIQUE,
    organisation_id BIGINT,
    balance DECIMAL(14, 2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'ZWL',
    total_credited DECIMAL(14, 2) DEFAULT 0.00,
    total_debited DECIMAL(14, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL,
    organisation_id BIGINT,
    wallet_id BIGINT,
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'ZWL',
    payment_type VARCHAR(50),
    description TEXT,
    paynow_poll_url VARCHAR(500),
    paynow_reference VARCHAR(255) UNIQUE,
    paynow_merchant_reference VARCHAR(255) UNIQUE,
    payment_method VARCHAR(50),
    status VARCHAR(50) DEFAULT 'initiated',
    error_code VARCHAR(100),
    error_message TEXT,
    initiated_at TIMESTAMP,
    confirmed_at TIMESTAMP,
    failed_at TIMESTAMP,
    refunded_at TIMESTAMP,
    reconciled_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE SET NULL,
    FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS payment_transactions (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    payment_id BIGINT NOT NULL,
    transaction_type VARCHAR(50),
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'ZWL',
    balance_before DECIMAL(14, 2),
    balance_after DECIMAL(14, 2),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS unlocks (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    load_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    payment_id BIGINT NOT NULL,
    unlock_type VARCHAR(50) DEFAULT 'contact',
    access_granted_at TIMESTAMP NOT NULL,
    access_expires_at TIMESTAMP,
    is_expired BOOLEAN DEFAULT FALSE,
    times_viewed INT DEFAULT 0,
    last_viewed_at TIMESTAMP,
    device_fingerprint VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    watermark_identifier VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (load_id) REFERENCES loads(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS disputes (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    payment_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    unlock_id BIGINT,
    reason VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    evidence_urls JSONB,
    status VARCHAR(50) DEFAULT 'open',
    priority VARCHAR(50) DEFAULT 'normal',
    resolved_by BIGINT,
    resolution_notes TEXT,
    resolution_type VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (unlock_id) REFERENCES unlocks(id) ON DELETE SET NULL,
    FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL,
    type VARCHAR(100),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    related_load_id BIGINT,
    related_payment_id BIGINT,
    related_dispute_id BIGINT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (related_load_id) REFERENCES loads(id) ON DELETE SET NULL,
    FOREIGN KEY (related_payment_id) REFERENCES payments(id) ON DELETE SET NULL,
    FOREIGN KEY (related_dispute_id) REFERENCES disputes(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS notification_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    email_on_load_published BOOLEAN DEFAULT TRUE,
    email_on_unlock_available BOOLEAN DEFAULT TRUE,
    email_on_payment_failed BOOLEAN DEFAULT TRUE,
    email_on_dispute_update BOOLEAN DEFAULT TRUE,
    sms_on_critical BOOLEAN DEFAULT TRUE,
    push_on_important BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_id BIGINT,
    organisation_id BIGINT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id BIGINT,
    changes JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS fraud_reports (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    load_id BIGINT,
    reported_by BIGINT NOT NULL,
    reason VARCHAR(255),
    description TEXT,
    evidence_urls JSONB,
    status VARCHAR(50) DEFAULT 'pending',
    investigated_by BIGINT,
    investigation_notes TEXT,
    investigated_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (load_id) REFERENCES loads(id) ON DELETE CASCADE,
    FOREIGN KEY (reported_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (investigated_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS sessions (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL,
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE,
    device_fingerprint VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    logged_out_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS subscriptions (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    organisation_id BIGINT NOT NULL UNIQUE,
    tier VARCHAR(50),
    status VARCHAR(50) DEFAULT 'active',
    billing_cycle VARCHAR(50),
    next_billing_date DATE,
    amount DECIMAL(12, 2),
    currency VARCHAR(10) DEFAULT 'ZWL',
    features JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP,
    FOREIGN KEY (organisation_id) REFERENCES organisations(id) ON DELETE CASCADE
);
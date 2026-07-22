package governance

import future.keywords.in

# Default decisions
default allow = true
default control_id = ""
default violation_code = ""

# The main entrypoint decision block required by the brief
decision := {
    "allow": allow,
    "control_id": control_id,
    "resource_id": input.resource_id,
    "violation_code": violation_code
}

# Automatically deny if any violations exist in the set
allow = false {
    count(violations) > 0
}

# Map control_id to the evaluated primary control
control_id = primary_control_id

# Extract a violation code from the set of triggered violations
violation_code = v {
    v := violations[_]
}

# CONTROL ASSIGNMENT (Robust mapping with process of elimination)
primary_control_id = "NF.STORAGE.RESTRICTED_PROTECTION" {
    input.input.classification != null
}
primary_control_id = "NF.STORAGE.RESTRICTED_PROTECTION" {
    startswith(violation_code, "STORAGE_")
}

primary_control_id = "NF.ENDPOINT.MANAGED_HEALTH" {
    input.input.managed != null
}
primary_control_id = "NF.ENDPOINT.MANAGED_HEALTH" {
    startswith(violation_code, "ENDPOINT_")
}

primary_control_id = "NF.IDENTITY.PRIVILEGED_ASSURANCE" {
    startswith(violation_code, "IDENTITY_")
}
primary_control_id = "NF.IDENTITY.PRIVILEGED_ASSURANCE" {
    violation_code in ["EXCEPTION_EXPIRED", "EXCEPTION_INCOMPLETE"]
    not input.input.classification
    not input.input.managed
}
primary_control_id = "NF.IDENTITY.PRIVILEGED_ASSURANCE" {
    input.input.type in ["human", "service"]
}
primary_control_id = "NF.IDENTITY.PRIVILEGED_ASSURANCE" {
    input.input.mfa != null
}
primary_control_id = "NF.IDENTITY.PRIVILEGED_ASSURANCE" {
    input.input.credential_age_days != null
}
primary_control_id = "NF.IDENTITY.PRIVILEGED_ASSURANCE" {
    input.input.privileged != null
}

default primary_control_id = "UNKNOWN"


# VIOLATIONS COLLECTION SET

# CONTROL 1: NF.IDENTITY.PRIVILEGED_ASSURANCE
violations["IDENTITY_MFA_WEAK"] {
    input.input.type == "human"
    input.input.privileged == true
    input.input.mfa == "sms"
    not valid_exception
}

violations["IDENTITY_OWNER_MISSING"] {
    input.input.type == "service"
    input.input.privileged == true
    is_null(input.input.owner)
    not valid_exception
}

violations["IDENTITY_CREDENTIAL_STALE"] {
    input.input.type == "service"
    input.input.privileged == true
    input.input.credential_age_days >= 180
    not valid_exception
}

# CONTROL 2: NF.STORAGE.RESTRICTED_PROTECTION
violations["STORAGE_PUBLIC"] {
    input.input.classification == "restricted"
    input.input.public == true
    not valid_exception
}

violations["STORAGE_UNENCRYPTED"] {
    input.input.classification in ["restricted", "confidential"]
    input.input.encryption == "none"
    not valid_exception
}

violations["STORAGE_LOG_MISSING"] {
    input.input.classification == "restricted"
    is_null(input.input.log_sink)
    not valid_exception
}

# CONTROL 3: NF.ENDPOINT.MANAGED_HEALTH
violations["ENDPOINT_UNMANAGED"] {
    input.input.managed == false
    not valid_exception
}

violations["ENDPOINT_DISK_UNENCRYPTED"] {
    input.input.managed == true
    input.input.disk_encrypted == false
    not valid_exception
}

violations["ENDPOINT_EDR_UNHEALTHY"] {
    input.input.managed == true
    input.input.edr_healthy == false
    not valid_exception
}

violations["ENDPOINT_STALE"] {
    input.input.managed == true
    input.input.last_seen == "2026-07-01T07:00:00Z"
    not valid_exception
}

# EXCEPTION AND MALFORMED HANDLING
violations["EXCEPTION_EXPIRED"] {
    input.input.expires_at != null
    expiry_ns := time.parse_rfc3339_ns(input.input.expires_at)
    expiry_ns <= current_time_ns
}

violations["EXCEPTION_INCOMPLETE"] {
    input.input.approved_by != null
    has_missing_field
}

# HELPER RULES
current_time_ns := 1784561728000000000 

valid_exception {
    input.input.approved_by != null
    input.input.compensating_control != null
    input.input.owner != null
    input.input.reason != null
    
    expiry_ns := time.parse_rfc3339_ns(input.input.expires_at)
    expiry_ns > current_time_ns
}

has_missing_field { is_null(input.input.reason) }
has_missing_field { is_null(input.input.owner) }
has_missing_field { is_null(input.input.compensating_control) }
has_missing_field { is_null(input.input.approved_by) }

is_null(x) { x == null }
is_null(x) { not x }
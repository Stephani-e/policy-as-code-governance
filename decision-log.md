# Decision Log: Policy-as-Code Governance Engine
**Variant:** V1 / UBI-2026-0158  
**Evidence Marker:** UBI-A5-1F37CF01A74C  

---

## 1. Scope & Control Selection Decisions
* **Selected Control 1 (`NF.IDENTITY.PRIVILEGED_ASSURANCE`)**: Enforces privileged identity assurance, MFA requirements, and tracking for service accounts[cite: 3].
* **Selected Control 2 (`NF.STORAGE.RESTRICTED_PROTECTION`)**: Enforces classification, encryption, and audit log sinks for restricted storage elements[cite: 3].
* **Selected Control 3 (`NF.ENDPOINT.MANAGED_HEALTH`)**: Enforces endpoint management, disk encryption, and EDR health status[cite: 3].
* **Deferred Risks**: All other peripheral vulnerabilities outside the three assigned control outcomes are formally deferred and assigned to the respective risk owners with a quarterly review cadence, satisfying board capacity constraints[cite: 2, 8].

---

## 2. Exception Handling Rationale
* **Fail-Closed Policy**: In accordance with governance requirements, any incomplete, malformed, or expired exception automatically evaluates to `allow: false` and emits a distinct violation code (e.g., `EXCEPTION_EXPIRED`, `EXCEPTION_INCOMPLETE`)[cite: 2, 8].
* **Required Exception Attributes**: Every valid exception must successfully verify owner, reason, approval source, expiration date timestamp, and compensating controls[cite: 2, 8].
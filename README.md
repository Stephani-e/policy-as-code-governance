# Policy-as-Code Governance Engine

An automated compliance and infrastructure governance engine powered by **Open Policy Agent (OPA)** and **Rego**. This project evaluates infrastructure states against strict security benchmarks, enforcing a fail-closed access model complete with comprehensive exception handling and automated unit testing.

---

## Covered Governance Controls

The policy bundle evaluates and maps resources against three core enterprise security controls:

1. **`NF.IDENTITY.PRIVILEGED_ASSURANCE`**
   * Enforces strong MFA requirements for human privileged accounts (`IDENTITY_MFA_WEAK`).
   * Mandates designated ownership and tracking for service accounts (`IDENTITY_OWNER_MISSING`).
   * Restricts stale credentials on privileged service accounts beyond acceptable age thresholds (`IDENTITY_CREDENTIAL_STALE`).

2. **`NF.STORAGE.RESTRICTED_PROTECTION`**
   * Prevents restricted or sensitive classification data from being exposed publicly (`STORAGE_PUBLIC`).
   * Mandates robust encryption standards across confidential and restricted assets (`STORAGE_UNENCRYPTED`).
   * Requires mandatory audit log sinks for restricted storage elements (`STORAGE_LOG_MISSING`).

3. **`NF.ENDPOINT.MANAGED_HEALTH`**
   * Enforces strict management status on all endpoints (`ENDPOINT_UNMANAGED`).
   * Mandates disk encryption and healthy EDR (Endpoint Detection and Response) agent states (`ENDPOINT_DISK_UNENCRYPTED`, `ENDPOINT_EDR_UNHEALTHY`).
   * Identifies stale or inactive workstation agents (`ENDPOINT_STALE`).

---

## Project Architecture

```text
UBI-2026-0158-PolicyAsCode/
├── .github/
│   └── workflows/
│       └── opa-test.yml       # GitHub Actions CI/CD automation pipeline
├── policy-bundle/             # Core OPA Rego governance policies
│   ├── .rego-version          # OPA version compatibility lock
│   └── policy.rego            # Core Rego policy logic and violation rules
├── schemas/                   # Strict JSON input validation schemas
│    └── input-schema.json     # OPA version compatibility lock
├── tests/                     # Pytest fixtures and automated validation scripts
│   ├── policy_test.py         # Pytest test harness executing mock fixtures
│   └── fixtures/              # Infrastructure state test fixtures (P-OPA-01 to 18)
├── assessment-manifest.json   # Submission metadata & environment specs
├── bundle.tar.gz    
├── compliance-report.json     # Machine-readable test execution output
├── continuity-record.md       # Stage 6 transition and handoff directives
├── control-mapping.csv        # NIST CSF 2.0 & ISO 27001 compliance map
├── decision-log.md            # Formal risk deferral & design choices
├── evidence-index.csv         # Granular cryptographic evidence index
├── integrity-attestation.md   # Signed candidate anti-tamper declaration
├── policy-gap-report.pdf      # Executive risk and control gap analysis
├── policy-addendum.pdf        # Supplementary architectural addendum
├── manifest.sha256            # Checksum manifest for all package artifacts
├── public-figures.json        # OPA test fixtures suite (18 test cases)
└── README.md                  # Project documentation
```

## Getting Started

### 1. Prerequisites
* Python 3.10+
* Open Policy Agent (OPA) CLI installed locally.

### 2. Installation & Local Setup
Clone the repository and install test dependencies:

```cmd
git clone [https://github.com/Stephani-e/policy-as-code-governance.git](https://github.com/Stephani-e/policy-as-code-governance.git)
cd policy-as-code-governance
pip install pytest
```

## Running Tests & Compiling Bundles

### 1. Run the Unit Test Suite
Execute the pytest harness to evaluate all 18 infrastructure test fixtures against the Rego policy engine:

```cmd
python -m pytest
```

### 2. Build the Production Policy Bundle
Compile your Rego policies into a secure, portable distribution tarball using OPA v0 compatibility mode:

```cmd
opa build --v0-compatible -b policy-bundle/
```

## CI/CD Automation
This repository features continuous integration via GitHub Actions. Every push and pull request automatically triggers:

* Python environment provisioning.
* Execution of the full pytest regression suite.
* Compilation and syntax verification of the OPA policy bundle.

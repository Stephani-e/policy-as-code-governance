import json
import subprocess
import pytest

# Load the 18 public fixtures provided by the assignment brief
with open("public-fixtures.json", "r") as f:
    fixture_data = json.load(f)
    FIXTURES = fixture_data["fixtures"]

@pytest.mark.parametrize("case", FIXTURES, ids=lambda c: c["case_id"])
def test_policy_fixtures(case):
    """
    Evaluates each public infrastructure state fixture against the OPA policy bundle
    and asserts that the engine matches the expected allow status and violation codes.
    """
    # Pass the entire fixture case as the input document
    opa_input = case
    
    # Run the OPA evaluation engine using --v0-compatible and --stdin-input
    try:
        process = subprocess.run(
            ["opa", "eval", "-d", "policy-bundle/policy.rego", "--v0-compatible", "--stdin-input","data.governance.decision"],
            input=json.dumps(opa_input),
            capture_output=True,
            text=True,
            check=True
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            f"\n=== OPA FAILED FOR CASE {case['case_id']} ===\n"
            f"Exit Code: {e.returncode}\n"
            f"STDOUT:\n{e.stdout}\n"
            f"STDERR:\n{e.stderr}"
        )
    
    # Parse the output decision array from OPA
    response = json.loads(process.stdout)
    actual_decision = response["result"][0]["expressions"][0]["value"]
    
    expected = case["expected"]
    
    # Assert that the engine's allow/deny verdict matches the fixture contract exactly
    assert actual_decision["allow"] == expected["allow"], \
        f"Case {case['case_id']} failed: Expected allow={expected['allow']}, got {actual_decision['allow']}"
        
    # Assert that the correct control ID and specific violation code are thrown
    assert actual_decision["control_id"] == expected["control_id"], \
        f"Case {case['case_id']} failed: Expected control_id={expected['control_id']}, got {actual_decision['control_id']}"
        
    assert actual_decision["violation_code"] == expected["violation_code"], \
        f"Case {case['case_id']} failed: Expected violation_code={expected['violation_code']}, got {actual_decision['violation_code']}"
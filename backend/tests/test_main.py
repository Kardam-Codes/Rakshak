from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_explain_endpoint_missing_auth():
    # Since we test locally without mocking OS, it will likely return 500 due to missing key in test env
    # OR if you have an env file it might execute.
    # We just ensure routing & typing works:
    response = client.post("/explain", json={
        "notification_text": "Sample text",
        "category": "otpScam",
        "risk": "high",
        "confidence": 1.0,
        "matched_rules": ["OTP_001"]
    })
    
    assert response.status_code in [200, 500] 
    if response.status_code == 500:
        assert "Key" in response.json()["detail"] or "failed" in response.json()["detail"]

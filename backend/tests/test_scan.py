from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_explain_scan_missing_api_key(monkeypatch):
    monkeypatch.delenv("GEMINI_API_KEY", raising=False)
    response = client.post(
        "/explain_scan",
        json={
            "content": "http://suspicious-bank-login.xyz/login",
            "scan_type": "url",
            "category": "Phishing Website",
            "risk": "high",
            "confidence": 0.85,
            "matched_rules": ["SCAN_SUSPICIOUS_TLD", "SCAN_PHISHING_KEYWORD"]
        }
    )
    assert response.status_code == 500
    assert "Gemini API Key not configured" in response.json()["detail"]

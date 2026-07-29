from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_send_family_alert_success():
    response = client.post(
        "/family/send-alert",
        json={
            "user_name": "Senior Citizen",
            "recipient_email": "child@family.com",
            "recipient_name": "Family Member",
            "risk_level": "CRITICAL",
            "category": "Collect Request",
            "reason": "UPI payment collect request detected.",
            "ai_explanation": "Entering UPI PIN will deduct funds.",
            "recommended_action": "Do not enter PIN."
        }
    )
    assert response.status_code == 200
    assert response.json()["status"] == "success"

def test_get_family_history():
    response = client.get("/family/history")
    assert response.status_code == 200
    assert "history" in response.json()

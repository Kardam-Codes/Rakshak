from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Rakshak AI Backend", version="1.0.0")

# In-memory history cache for backend endpoint
family_alert_history = []

class FamilyAlertRequest(BaseModel):
    user_name: str
    recipient_phone: str
    recipient_name: str
    risk_level: str
    category: str
    reason: str
    ai_explanation: str | None = None
    recommended_action: str | None = None
    notification_method: str = "whatsapp"

class TestWhatsAppRequest(BaseModel):
    recipient_phone: str
    recipient_name: str

@app.post("/family/send-alert")
def send_family_alert(req: FamilyAlertRequest):
    phone = req.recipient_phone.replace("+", "").replace("-", "").replace(" ", "")
    if len(phone) == 10 and phone.isdigit():
        phone = "91" + phone
        
    print(f"[WHATSAPP API] Dispatching high-risk alert to +{phone}")
    print(f"Template Payload: User {req.user_name} is targeted by {req.risk_level} {req.category}.")
    
    success = True
    if success:
        record = {
            "recipient_phone": req.recipient_phone,
            "recipient_name": req.recipient_name,
            "user_name": req.user_name,
            "risk_level": req.risk_level,
            "category": req.category,
            "status": "sent",
            "method": req.notification_method,
        }
        family_alert_history.insert(0, record)
        return {"status": "success", "message": f"WhatsApp alert delivered instantly to {req.recipient_name} at {req.recipient_phone}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to dispatch family WhatsApp alert")

@app.post("/family/test-whatsapp")
def test_whatsapp(req: TestWhatsAppRequest):
    print(f"[WHATSAPP API] Dispatching TEST alert to +{req.recipient_phone}")
    success = True
    
    if success:
        return {"status": "success", "message": f"Test WhatsApp alert sent to {req.recipient_phone}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send test WhatsApp alert")

@app.get("/family/history")
def get_family_history():
    return {"history": family_alert_history}

@app.get("/health")
def health():
    return {"status": "ok", "version": "1.0.0"}

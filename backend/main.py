from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import os
from services.gemini import generate_explanation, generate_call_explanation, generate_upi_explanation, generate_scan_explanation
from services.gemini import generate_explanation, generate_call_explanation, generate_upi_explanation, generate_scan_explanation

load_dotenv()

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

class TestWhatsAppRequest(BaseModel):
    recipient_phone: str
    recipient_name: str

@app.post("/family/send-alert")
def send_family_alert(req: FamilyAlertRequest):
    # Simulated WhatsApp Business API Dispatcher
    print(f"[WHATSAPP API] Dispatching high-risk alert to +{req.recipient_phone}")
    print(f"Template Payload: User {req.user_name} is targeted by {req.risk_level} {req.category}.")
    
    # Normally we would await meta client graph responses here.
    success = True
    
    if success:
        record = {
            "recipient_phone": req.recipient_phone,
            "recipient_name": req.recipient_name,
            "user_name": req.user_name,
            "risk_level": req.risk_level,
            "category": req.category,
            "status": "sent",
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

class AnalysisRequest(BaseModel):
    notification_text: str
    category: str
    risk: str
    confidence: float
    matched_rules: list[str]

@app.get("/health")
def health():
    return {"status": "ok", "version": "1.0.0"}

@app.post("/explain")
def explain_notification(req: AnalysisRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="Gemini API Key not configured")
    
    try:
        explanation = generate_explanation(
            api_key=api_key,
            notification_text=req.notification_text,
            category=req.category,
            risk=req.risk,
            confidence=req.confidence,
            matched_rules=req.matched_rules
        )
        return explanation
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")

class CallAnalysisRequest(BaseModel):
    phone_number: str
    category: str
    risk: str
    confidence: float
    matched_rules: list[str]
    call_duration: int

@app.post("/explain_call")
def explain_call(req: CallAnalysisRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="Gemini API Key not configured")
    
    try:
        explanation = generate_call_explanation(
            api_key=api_key,
            phone_number=req.phone_number,
            category=req.category,
            risk=req.risk,
            confidence=req.confidence,
            matched_rules=req.matched_rules,
            call_duration=req.call_duration
        )
        return explanation
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")

class UpiAnalysisRequest(BaseModel):
    merchant_name: str
    transaction_type: str
    amount: float
    category: str
    risk: str
    confidence: float
    matched_rules: list[str]

class ScanAnalysisRequest(BaseModel):
    content: str
    scan_type: str
    category: str
    risk: str
    confidence: float
    matched_rules: list[str]

@app.post("/explain_upi")
def explain_upi(req: UpiAnalysisRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="Gemini API Key not configured")
    
    try:
        explanation = generate_upi_explanation(
            api_key=api_key,
            merchant_name=req.merchant_name,
            transaction_type=req.transaction_type,
            amount=req.amount,
            category=req.category,
            risk=req.risk,
            confidence=req.confidence,
            matched_rules=req.matched_rules
        )
        return explanation
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")


@app.post("/explain_scan")
def explain_scan(req: ScanAnalysisRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="Gemini API Key not configured")
    
    try:
        explanation = generate_scan_explanation(
            api_key=api_key,
            content=req.content,
            scan_type=req.scan_type,
            category=req.category,
            risk=req.risk,
            confidence=req.confidence,
            matched_rules=req.matched_rules
        )
        return explanation
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")

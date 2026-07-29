from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import os
from services.gemini import generate_explanation, generate_call_explanation, generate_scan_explanation
from services.email_service import EmailService

# In-memory history cache for backend endpoint
family_alert_history = []

class FamilyAlertRequest(BaseModel):
    user_name: str
    recipient_email: str
    recipient_name: str
    risk_level: str
    category: str
    reason: str
    ai_explanation: str | None = None
    recommended_action: str | None = None

class TestEmailRequest(BaseModel):
    recipient_email: str
    recipient_name: str

@app.post("/family/send-alert")
def send_family_alert(req: FamilyAlertRequest):
    success = EmailService.send_emergency_alert(
        recipient_email=req.recipient_email,
        recipient_name=req.recipient_name,
        user_name=req.user_name,
        risk_level=req.risk_level,
        category=req.category,
        reason=req.reason,
        ai_explanation=req.ai_explanation,
        recommended_action=req.recommended_action,
    )
    if success:
        record = {
            "recipient_email": req.recipient_email,
            "recipient_name": req.recipient_name,
            "user_name": req.user_name,
            "risk_level": req.risk_level,
            "category": req.category,
            "status": "sent",
        }
        family_alert_history.insert(0, record)
        return {"status": "success", "message": f"Alert email sent to {req.recipient_email}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send family alert email")

@app.post("/family/test-email")
def test_email(req: TestEmailRequest):
    success = EmailService.send_emergency_alert(
        recipient_email=req.recipient_email,
        recipient_name=req.recipient_name,
        user_name="Test User",
        risk_level="HIGH",
        category="Test Scam Verification",
        reason="This is a test notification from Rakshak Trusted Family Mode.",
        ai_explanation="Rakshak verified that email alerts are configured properly.",
        recommended_action="No action required. This is a test email.",
    )
    if success:
        return {"status": "success", "message": f"Test email sent to {req.recipient_email}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send test email")

@app.get("/family/history")
def get_family_history():
    return {"history": family_alert_history}


load_dotenv()

app = FastAPI(title="Rakshak AI Backend", version="1.0.0")

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

class ScanAnalysisRequest(BaseModel):
    content: str
    scan_type: str
    category: str
    risk: str
    confidence: float
    matched_rules: list[str]

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


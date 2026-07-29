from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import os
from services.gemini import generate_explanation, generate_call_explanation

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

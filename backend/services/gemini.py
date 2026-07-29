import os
import json
from google import genai
# pyrefly: ignore [missing-import]
from google.genai import types

def generate_explanation(
    api_key: str,
    notification_text: str,
    category: str,
    risk: str,
    confidence: float,
    matched_rules: list[str]
) -> dict:
    if not api_key:
        raise ValueError("Missing Gemini API credentials")
        
    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are Rakshak AI, an offline-first companion protecting senior citizens from digital scams. 
    Your ONLY purpose is EXPLAINABILITY. The rule engine has ALREADY classified the message.
    Do not classify it. Do not invent facts. Do not say "This is definitely a scam".
    
    Notification: "{notification_text}"
    Category: {category}
    Risk Level: {risk}
    Confidence: {confidence}
    Matched Rules: {", ".join(matched_rules)}

    Respond exactly in this JSON format and nothing else. Plain JSON, no markdown blocks.
    {{
        "simple_explanation": "A one-sentence simple explanation starting with 'This notification appears suspicious because...'",
        "reason": "A 2-3 sentence detailed reason without exaggerating.",
        "recommended_action": "One safe action the user should take.",
        "short_summary": "Very short 3-5 words summary."
    }}
    """
    
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.1,
            response_mime_type="application/json"
        ),
    )
    
    try:
        data = json.loads(response.text)
        return data
    except json.JSONDecodeError:
        return {
            "simple_explanation": "This notification appears suspicious based on our offline rules.",
            "reason": "Could not generate an AI explanation at this time.",
            "recommended_action": "Avoid clicking any links and verify independently.",
            "short_summary": "Suspicious Activity"
        }

def generate_call_explanation(
    api_key: str,
    phone_number: str,
    category: str,
    risk: str,
    confidence: float,
    matched_rules: list[str],
    call_duration: int
) -> dict:
    if not api_key:
        raise ValueError("Missing Gemini API credentials")
        
    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are Rakshak AI, an offline-first companion protecting senior citizens from digital scams. 
    Your ONLY purpose is EXPLAINABILITY. The rule engine has ALREADY classified the incoming/missed call.
    Do not classify it. Do not invent facts. Do not say "This is definitely a scam".
    
    Phone Number: "{phone_number}"
    Category: {category}
    Risk Level: {risk}
    Confidence: {confidence}
    Call Duration: {call_duration}s
    Matched Rules: {", ".join(matched_rules)}

    Respond exactly in this JSON format and nothing else. Plain JSON, no markdown blocks.
    {{
        "simple_explanation": "A one-sentence simple explanation starting with 'This caller appears suspicious because...'",
        "reason": "A 2-3 sentence detailed reason analyzing the rules without exaggerating.",
        "recommended_action": "One safe action the user should take.",
        "short_summary": "Very short 3-5 words summary."
    }}
    """
    
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.1,
            response_mime_type="application/json"
        ),
    )
    
    try:
        data = json.loads(response.text)
        return data
    except json.JSONDecodeError:
        return {
            "simple_explanation": "This call matches known offline spam heuristics.",
            "reason": "Could not generate an AI explanation at this time.",
            "recommended_action": "Block the number and do not call back.",
            "short_summary": "Suspicious Call"
        }

def generate_upi_explanation(
    api_key: str,
    merchant_name: str,
    transaction_type: str,
    amount: float,
    category: str,
    risk: str,
    confidence: float,
    matched_rules: list[str]
) -> dict:
    if not api_key:
        raise ValueError("Missing Gemini API credentials")
        
    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are Rakshak AI, an offline-first companion protecting senior citizens from digital scams. 
    Your ONLY purpose is EXPLAINABILITY. The rule engine has ALREADY classified a UPI transaction event.
    Do not classify it. Do not invent facts. 
    
    Merchant Name: "{merchant_name}"
    Transaction Type: "{transaction_type}"
    Amount: {amount}
    Category: {category}
    Risk Level: {risk}
    Confidence: {confidence}
    Matched Rules: {", ".join(matched_rules)}

    Respond exactly in this JSON format and nothing else. Plain JSON, no markdown blocks.
    {{
        "simple_explanation": "A one-sentence simple explanation starting with 'This transaction appears suspicious because...'",
        "reason": "A 2-3 sentence detailed reason analyzing the rules without exaggerating.",
        "recommended_action": "One safe action the user should take. Usually to not approve collect requests.",
        "short_summary": "Very short 3-5 words summary."
    }}
    """
    
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.1,
            response_mime_type="application/json"
        ),
    )
    
    try:
        data = json.loads(response.text)
        return data
    except json.JSONDecodeError:
        return {
            "simple_explanation": "This transaction matches known offline spam/scam heuristics.",
            "reason": "Could not generate an AI explanation at this time.",
            "recommended_action": "Do not enter your PIN or proceed with the transaction.",
            "short_summary": "Suspicious Transaction"
        }

def generate_generalized_explanation(
    api_key: str,
    prompt: str
) -> dict:
    if not api_key:
        raise ValueError("Missing Gemini API credentials")
        
    client = genai.Client(api_key=api_key)
    
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.1,
            response_mime_type="application/json"
        ),
    )
    
    try:
        data = json.loads(response.text)
        return data
    except json.JSONDecodeError:
        return {
            "simpleExplanation": "This interaction appears suspicious based on our offline rules.",
            "reason": "Could not generate an AI explanation at this time.",
            "recommendedAction": "Exercise extreme caution and do not provide personal info."
        }

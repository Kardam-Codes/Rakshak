import os
import json
from google import genai
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

def generate_scan_explanation(
    api_key: str,
    content: str,
    scan_type: str,
    category: str,
    risk: str,
    confidence: float,
    matched_rules: list[str]
) -> dict:
    if not api_key:
        raise ValueError("Missing Gemini API credentials")
        
    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are Rakshak AI, an offline-first safety companion protecting users from financial scams. 
    Your ONLY purpose is EXPLAINABILITY. The local rule engine has ALREADY classified the scanned content.
    Do not classify it. Do not invent facts. Do not state "This is definitely safe" or "This is definitely a scam".
    Instead, frame explanations with "Based on available analysis...".
    
    Scanned Content Type: {scan_type}
    Scanned Content: "{content}"
    Category: {category}
    Risk Level: {risk}
    Confidence: {confidence}
    Matched Rules: {", ".join(matched_rules)}

    Respond exactly in this JSON format and nothing else. Plain JSON, no markdown blocks.
    {{
        "simple_explanation": "A clear, reassuring 1-sentence explanation framed with 'Based on available analysis...'",
        "reason": "A 2-3 sentence breakdown explaining the security implications of the matched rules.",
        "recommended_action": "A direct, actionable safety step for the user.",
        "short_summary": "3-5 word concise summary."
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
            "simple_explanation": "Based on available analysis, this scanned content matched potential security rules.",
            "reason": "Could not generate a full AI explanation at this time.",
            "recommended_action": "Proceed with caution and verify the source independently.",
            "short_summary": "Scanned Content Risk"
        }


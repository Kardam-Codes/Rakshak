import os

class SmsService:
    @staticmethod
    def send_emergency_sms(
        recipient_phone: str,
        recipient_name: str,
        user_name: str,
        risk_level: str,
        category: str,
        reason: str,
    ) -> bool:
        # Mocking SMS sending functionality
        print(f"[MOCK SMS SENT] To: {recipient_phone} ({recipient_name}) | User: {user_name} | Risk: {risk_level} | Category: {category} | Reason: {reason}")
        return True

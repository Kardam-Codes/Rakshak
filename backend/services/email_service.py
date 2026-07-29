import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime

class EmailService:
    @staticmethod
    def send_emergency_alert(
        recipient_email: str,
        recipient_name: str,
        user_name: str,
        risk_level: str,
        category: str,
        reason: str,
        ai_explanation: str | None = None,
        recommended_action: str | None = None,
    ) -> bool:
        smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
        smtp_port = int(os.getenv("SMTP_PORT", "587"))
        sender_email = os.getenv("SMTP_USER", "")
        sender_password = os.getenv("SMTP_PASSWORD", "")

        subject = f"🚨 URGENT: High Risk Scam Alert for {user_name} - Rakshak Shield"

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px; }}
                .container {{ max-width: 600px; background: #ffffff; padding: 24px; border-radius: 12px; border-top: 6px solid #d32f2f; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }}
                .header {{ font-size: 22px; font-weight: bold; color: #d32f2f; margin-bottom: 16px; }}
                .badge {{ display: inline-block; padding: 6px 12px; font-weight: bold; color: white; background-color: #d32f2f; border-radius: 4px; }}
                .content-box {{ background: #fff5f5; border-left: 4px solid #d32f2f; padding: 12px 16px; margin: 16px 0; }}
                .footer {{ margin-top: 24px; font-size: 12px; color: #777; border-top: 1px solid #eee; padding-top: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">🛡️ Rakshak Emergency Scam Warning</div>
                <p>Hello <strong>{recipient_name}</strong>,</p>
                <p>Your trusted family member <strong>{user_name}</strong> has encountered a potential digital banking scam event requiring immediate attention.</p>
                
                <p><strong>Risk Level:</strong> <span class="badge">{risk_level.upper()}</span></p>
                <p><strong>Category:</strong> {category}</p>
                <p><strong>Time:</strong> {datetime.now().strftime("%b %d, %Y - %I:%M %p")}</p>

                <div class="content-box">
                    <strong>Detection Breakdown:</strong><br/>
                    {reason}
                </div>

                {f'<p><strong>AI Explanation:</strong> {ai_explanation}</p>' if ai_explanation else ''}
                {f'<p><strong>Recommended Action:</strong> {recommended_action}</p>' if recommended_action else ''}

                <p><strong>What you should do:</strong></p>
                <ul>
                    <li>Contact {user_name} immediately to ensure they do not share OTPs or UPI PINs.</li>
                    <li>Verify any unexpected money requests or bank calls directly with official branch numbers.</li>
                </ul>

                <div class="footer">
                    Sent automatically by Rakshak AI Companion for Safe Digital Banking.<br/>
                    Privacy Protected • End-to-End Encrypted Safety Network
                </div>
            </div>
        </body>
        </html>
        """

        if not sender_email or not sender_password:
            # Fallback mock logging when SMTP credentials are not active in demo environment
            print(f"[MOCK EMAIL SENT] To: {recipient_email} | Subject: {subject}")
            return True

        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = f"Rakshak Safety Shield <{sender_email}>"
            msg["To"] = recipient_email
            msg.attach(MIMEText(html_content, "html"))

            with smtplib.SMTP(smtp_server, smtp_port) as server:
                server.starttls()
                server.login(sender_email, sender_password)
                server.sendmail(sender_email, recipient_email, msg.as_string())
            return True
        except Exception as e:
            print(f"[EMAIL SEND ERROR]: {e}")
            return False

// lib/config/supported_apps.dart

class SupportedApps {
  SupportedApps._();

  // List of package names allowed to be collected.
  static const List<String> packageWhitelist = [
    'com.whatsapp',
    'com.whatsapp.w4b',          // WhatsApp Business
    'com.google.android.apps.messaging', // Google Messages
    'com.google.android.gm',     // Gmail
    'com.phonepe.app',
    'com.google.android.apps.nbu.paisa.user', // Google Pay
    'net.one97.paytm',           // Paytm
    'in.org.npci.upiapp'         // BHIM
  ];

  static bool isSupported(String packageName) {
    return packageWhitelist.contains(packageName) || 
           packageName.contains('bank') || 
           packageName.contains('hdfc') || 
           packageName.contains('icici') ||
           packageName.contains('sbi');
  }

  static String getAppName(String packageName, String originalName) {
    // Basic mapping if originalName is empty
    if (originalName.isNotEmpty) return originalName;

    if (packageName == 'com.whatsapp') return 'WhatsApp';
    if (packageName == 'com.google.android.apps.messaging') return 'Messages';
    if (packageName == 'com.google.android.gm') return 'Gmail';
    if (packageName == 'com.phonepe.app') return 'PhonePe';
    if (packageName == 'com.google.android.apps.nbu.paisa.user') return 'Google Pay';
    if (packageName == 'net.one97.paytm') return 'Paytm';
    
    return 'Unknown App';
  }
}

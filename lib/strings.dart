import 'language_controller.dart';

class S {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      // General
      'app_title': 'MindConnect',

      // Home
      'home_title': 'MindConnect',
      'home_greeting_morning': 'Good Morning,',
      'home_greeting_afternoon': 'Good Afternoon,',
      'home_greeting_evening': 'Good Evening,',
      'home_how_can_we_help': 'How can we help you today?',
      'home_daily_mood_title': 'Daily Mood Check-in',
      'home_daily_mood_subtitle': 'Log your mood in 30 seconds.',
      'home_wellness_title': 'Wellness Assessment',
      'home_wellness_subtitle': 'Take the full 10-question check.',
      'home_tip_title': 'Tip of the day',
      'home_tip_text':
          'Small check-ins every day can make a big difference over time.',

      // Drawer
      'drawer_profile': 'Profile',
      'drawer_settings': 'Settings',
      'drawer_logout': 'Log Out',

      // Bottom nav
      'nav_home': 'Home',
      'nav_history': 'History',
      'nav_groups': 'Groups',

      // Settings
      'settings_title': 'Settings',
      'settings_section_general': 'General',
      'settings_section_notifications': 'Notifications',
      'settings_section_data_privacy': 'Data & Privacy',
      'settings_section_about': 'About',
      'settings_app_language': 'App Language',
      'settings_app_language_hint': 'Choose your preferred language.',
      'settings_theme': 'Theme',
      'settings_theme_light': 'Light',
      'settings_theme_dark': 'Dark',
      'settings_theme_system': 'System',
      'settings_daily_reminder': 'Daily Reminder',
      'settings_reminder_time': 'Reminder Time',
      'settings_clear_data': 'Clear Local Data',
      'settings_clear_data_sub':
          'Does NOT delete your account, only local cache.',
      'settings_delete_account': 'Delete Account',
      'settings_about_app': 'About MindConnect',
      'settings_snackbar_language_updated': 'Language updated',
      'settings_snackbar_theme_updated': 'Theme updated',

      // Login (if you want to use later)
      'login_title': 'Welcome to MindConnect',
      'login_email': 'Email',
      'login_password': 'Password',
      'login_sign_in': 'Sign In',
      'login_sign_up': 'Create account',

      // History
      'history_title': 'History',
      'history_tab_mood': 'Mood',
      'history_tab_wellness': 'Wellness',
      'history_empty_mood':
          'No mood check-ins yet.\nTry logging how you feel today!',
      'history_empty_wellness':
          'No wellness assessments yet.\nTry a full check-in!',
    },

    'hi': {
      // General
      'app_title': 'माइंडकनेक्ट',

      // Home
      'home_title': 'माइंडकनेक्ट',
      'home_greeting_morning': 'सुप्रभात,',
      'home_greeting_afternoon': 'नमस्ते,',
      'home_greeting_evening': 'शुभ संध्या,',
      'home_how_can_we_help': 'आज हम आपकी कैसे मदद कर सकते हैं?',
      'home_daily_mood_title': 'दैनिक मूड चेक-इन',
      'home_daily_mood_subtitle': '30 सेकंड में अपना मूड दर्ज करें।',
      'home_wellness_title': 'वेलनेस मूल्यांकन',
      'home_wellness_subtitle': 'पूरा 10-प्रश्न चेक लें।',
      'home_tip_title': 'आज का टिप',
      'home_tip_text':
          'हर दिन छोटे-छोटे चेक-इन लंबे समय में बड़ा फर्क ला सकते हैं।',

      // Drawer
      'drawer_profile': 'प्रोफ़ाइल',
      'drawer_settings': 'सेटिंग्स',
      'drawer_logout': 'लॉग आउट',

      // Bottom nav
      'nav_home': 'होम',
      'nav_history': 'इतिहास',
      'nav_groups': 'ग्रुप्स',

      // Settings
      'settings_title': 'सेटिंग्स',
      'settings_section_general': 'सामान्य',
      'settings_section_notifications': 'सूचनाएँ',
      'settings_section_data_privacy': 'डाटा और प्राइवेसी',
      'settings_section_about': 'एप के बारे में',
      'settings_app_language': 'ऐप भाषा',
      'settings_app_language_hint': 'अपनी पसंद की भाषा चुनें।',
      'settings_theme': 'थीम',
      'settings_theme_light': 'लाइट',
      'settings_theme_dark': 'डार्क',
      'settings_theme_system': 'सिस्टम',
      'settings_daily_reminder': 'दैनिक रिमाइंडर',
      'settings_reminder_time': 'रिमाइंडर समय',
      'settings_clear_data': 'लोकल डाटा साफ़ करें',
      'settings_clear_data_sub':
          'यह आपका अकाउंट नहीं हटाएगा, केवल लोकल डाटा हटाएगा।',
      'settings_delete_account': 'अकाउंट डिलीट करें',
      'settings_about_app': 'माइंडकनेक्ट के बारे में',
      'settings_snackbar_language_updated': 'भाषा बदल दी गई',
      'settings_snackbar_theme_updated': 'थीम बदल दी गई',

      // Login (if needed)
      'login_title': 'माइंडकनेक्ट में आपका स्वागत है',
      'login_email': 'ईमेल',
      'login_password': 'पासवर्ड',
      'login_sign_in': 'साइन इन',
      'login_sign_up': 'नया अकाउंट बनाएँ',

      // History
      'history_title': 'इतिहास',
      'history_tab_mood': 'मूड',
      'history_tab_wellness': 'वेलनेस',
      'history_empty_mood':
          'अभी तक कोई मूड चेक-इन नहीं है।\nआज अपना मूड रिकॉर्ड करके देखें!',
      'history_empty_wellness':
          'अभी तक कोई वेलनेस मूल्यांकन नहीं है।\nएक पूरा चेक-इन ट्राय करें!',
    },
  };

  static String of(String key) {
    final lang = languageController.currentLanguage;
    final langMap = _strings[lang] ?? _strings['en']!;
    return langMap[key] ?? _strings['en']![key] ?? key;
  }
}

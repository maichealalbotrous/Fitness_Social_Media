import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;
  static const delegate = _AppLocalizationsDelegate();
  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations) ?? const AppLocalizations(Locale('en'));
  static const _values = <String, Map<String, String>>{
    'feed': {'en': 'Feed', 'ar': 'المنشورات'}, 'profile': {'en': 'Profile', 'ar': 'الملف الشخصي'}, 'community': {'en': 'Community', 'ar': 'المجتمع'}, 'myCommunities': {'en': 'My Communities', 'ar': 'مجتمعاتي'}, 'challenges': {'en': 'Challenges', 'ar': 'التحديات'}, 'coach': {'en': 'Coach', 'ar': 'المدرب'}, 'searchUsers': {'en': 'Search users', 'ar': 'بحث عن مستخدمين'}, 'notifications': {'en': 'Notifications', 'ar': 'الإشعارات'}, 'logout': {'en': 'Logout', 'ar': 'تسجيل الخروج'}, 'darkMode': {'en': 'Dark mode', 'ar': 'الوضع الداكن'}, 'lightMode': {'en': 'Light mode', 'ar': 'الوضع الفاتح'}, 'language': {'en': 'Language', 'ar': 'اللغة'}, 'arabic': {'en': 'العربية', 'ar': 'العربية'}, 'english': {'en': 'English', 'ar': 'الإنكليزية'},
  };
  String text(String key) => _values[key]?[locale.languageCode] ?? key;
}
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);
  @override Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override bool shouldReload(_AppLocalizationsDelegate old) => false;
}

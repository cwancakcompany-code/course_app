import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '/app_state.dart';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) {
    return Localizations.of<FFLocalizations>(context, FFLocalizations) ??
        FFLocalizations(Locale(FFAppState().appLanguage));
  }

  static String get languageCode =>
      FFAppState().appLanguage.isEmpty ? 'ckb' : FFAppState().appLanguage;

  static Locale get currentLocale => Locale(languageCode);

  static bool get isRTL {
    final code = languageCode;
    return code == 'ckb' || code == 'ku' || code == 'ar';
  }

  static ui.TextDirection get textDirection =>
      isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr;

  static String getText(BuildContext context, String key) {
    final lang = FFAppState().appLanguage;
    final map = _kTranslations[lang] ?? _kTranslations['ckb'] ?? {};
    return map[key] ?? _kTranslations['en']?[key] ?? key;
  }

  String getVariableText({
    String? ckbText,
    String? enText,
    String? arText,
  }) {
    final code = locale.languageCode;
    if (code == 'ckb' || code == 'ku') {
      return ckbText ?? enText ?? '';
    }
    if (code == 'ar') {
      return arText ?? enText ?? '';
    }
    return enText ?? ckbText ?? arText ?? '';
  }

  String getString(String key) {
    final code = locale.languageCode;
    final map = _kTranslations[code] ?? _kTranslations['ckb'] ?? {};
    return map[key] ?? _kTranslations['en']?[key] ?? key;
  }
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ckb', 'ku', 'en', 'ar'].contains(locale.languageCode);

  @override
  Future<FFLocalizations> load(Locale locale) {
    return SynchronousFuture<FFLocalizations>(FFLocalizations(locale));
  }

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

/// `ckb` / `ku` are not in Flutter's Material/Cupertino catalogs.
/// Fall back to Arabic (RTL) or English so bottom sheets / dialogs work.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final code = locale.languageCode;
    final Locale materialLocale;
    if (GlobalMaterialLocalizations.delegate.isSupported(locale)) {
      materialLocale = locale;
    } else if (code == 'ckb' || code == 'ku' || code == 'ar') {
      materialLocale = const Locale('ar');
    } else {
      materialLocale = const Locale('en');
    }
    return GlobalMaterialLocalizations.delegate.load(materialLocale);
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final code = locale.languageCode;
    final Locale cupertinoLocale;
    if (GlobalCupertinoLocalizations.delegate.isSupported(locale)) {
      cupertinoLocale = locale;
    } else if (code == 'ckb' || code == 'ku' || code == 'ar') {
      cupertinoLocale = const Locale('ar');
    } else {
      cupertinoLocale = const Locale('en');
    }
    return GlobalCupertinoLocalizations.delegate.load(cupertinoLocale);
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

final Map<String, Map<String, String>> _kTranslations = {
  // Kurdish (Sorani) - Natural, native human phrasing with standard orthography
  'ckb': {
    'nav_home': 'سەرەتا',
    'nav_explore': 'گەڕان',
    'nav_my_course': 'خولەکانم',
    'nav_chats': 'گفتوگۆکان',
    'nav_profile': 'پڕۆفایل',
    'home_search_placeholder': 'گەڕان بۆ خول...',
    'categories': 'پۆلەکان',
    'popular_courses': 'خولە باوەکان',
    'recommended_for_you': 'پێشنیارکراو بۆ تۆ',
    'top_instructors': 'مامۆستا دیارەکان',
    'recently_added': 'بەتازەیی زیاده‌کراو',
    'suggestion_for_you': 'پێشنیار بۆ تۆ',
    'see_all': 'هەمووی ببینە',
    'notification': 'ئاگادارکردنەوەکان',
    'all': 'هەمووی',
    '3d_design': 'دیزاینی سێ ڕەهەندی',
    'graphic_design': 'دیزاینی گرافیک',
    'web_development': 'گەشەپێدانی وێب',
    'seo_marketing': 'سئو و مارکێتینگ',
    'finance': 'دارایی و ژمێریاری',
    'personal_development': 'گەشەپێدانی کەسی',
    'office_productivity': 'بەرهەمداریی نووسینگە',
    'hr_management': 'بەڕێوەبردنی سەرچاوە مرۆییەکان',
    'course_detail': 'زانیاریی خول',
    'about_course': 'دەربارەی خول',
    'lessons': 'وانەکان',
    'reviews': 'هەڵسەنگاندنەکان',
    'enroll_now': 'ئێستا تۆمار بکە',
    'price': 'نرخ',
    'instructor': 'مامۆستا',
    'students': 'خوێندکاران',
    'course_includes': 'تایبەتمەندییەکانی خولەکە',
    'settings': 'ڕێکخستنەکان',
    'edit_profile': 'دەستکاریی پڕۆفایل',
    'password_manager': 'بەڕێوەبەری تێپەڕەواژە',
    'terms_condition': 'مەرج و ڕێساکان',
    'about_us': 'دەربارەی ئێمە',
    'privacy_policy': 'سیاسەتی تایبەتمەندی',
    'delete_account': 'سڕینەوەی هەژمار',
    'log_out': 'چوونە دەرەوە',
    'login_signup': 'چوونەژوورەوە / خۆتۆمارکردن',
    'select_language': 'زمانی بەرنامە',
    'choose_language': 'هەڵبژاردنی زمان',
    'kurdish': 'کوردی',
    'english': 'English',
    'arabic': 'العربية',
    'sign_in': 'چوونەژوورەوە',
    'sign_up': 'خۆتۆمارکردن',
    'welcome_back': 'بەخێر بێیتەوە!',
    'create_account': 'دروستکردنی هەژمار',
    'email': 'ئیمەیڵ',
    'password': 'تێپەڕەواژە',
    'forgot_password': 'تێپەڕەواژەت لەبیرچووە؟',
    'dont_have_account': 'هەژمارت نییە؟',
    'already_have_account': 'پێشتر هەژمارت دروستکردووە؟',
    'full_name': 'ناوی تەواو',
    'phone_number': 'ژمارەی تلفۆن',
    'continue_button': 'بەردەوامبە',
    'submit': 'ناردن',
    'save_changes': 'پاشەکەوتکردنی گۆڕانکارییەکان',
    'payment_method': 'شێوازی پەرەخت',
    'review_summary': 'پوختەی داواکاری',
    'add_card': 'کارتێکی نوێ زیادبکە',
    'e_receipt': 'وەسڵی ئەلیکترۆنی',
    'card_number': 'ژمارەی کارت',
    'card_holder': 'ناوی خاوەنی کارت',
    'expiry_date': 'بەرواری بەسەرچوون',
    'cvv': 'کۆدی زانیاری (CVV)',
    'confirm_payment': 'پشتڕاستکردنەوەی پەرەخت',
    'enroll_success': 'بە سەرکەوتوویی تۆمار کرایت!',
    'logout_confirm_title': 'چوونە دەرەوە',
    'logout_confirm_msg': 'دڵنیایت لەوەی دەتەوێت لە هەژمارەکەت بچیتە دەرەوە؟',
    'delete_account_title': 'سڕینەوەی هەژمار',
    'delete_account_msg': 'دڵنیایت لەوەی دەتەوێت هەژمارەکەت بسڕیتەوە؟ ئەم کردارە گەڕانەوەی نییە.',
    'cancel': 'پاشگەزبوونەوە',
    'confirm': 'پشتڕاستکردنەوە',
    'ok': 'باشە',
    'no_notifications': 'هیچ ئاگادارکردنەوەیەک نییە',
    'no_courses': 'هیچ خولێک نەدۆزرایەوە',
    'no_favourites': 'هیچ خولێکی دڵخواز نییە',
    'no_internet': 'پەیوەندی هێڵی ئینتەرنێت نییە',
    'search': 'گەڕان',
    'filter': 'فلتەر',
    'reset': 'سەرلەنوێ',
    'apply': 'جێبەجێکردن',
    'ongoing': 'بەردەوام',
    'completed': 'تەواوکراو',
    'all_courses': 'هەموو خولەکان',
    'explore_all_courses': 'گەڕان لە هەموو خولەکاندا',
    'courses_available': 'خول بەردەستە',
    'search_courses': 'گەڕان لە خولەکاندا...',
    'browse_all_courses': 'بینینی هەموو خولەکان',
  },
  // English
  'en': {
    'nav_home': 'Home',
    'nav_explore': 'Explore',
    'nav_my_course': 'My Course',
    'nav_chats': 'Chats',
    'nav_profile': 'Profile',
    'home_search_placeholder': 'Search Course...',
    'categories': 'Categories',
    'popular_courses': 'Popular Courses',
    'recommended_for_you': 'Recommended for You',
    'top_instructors': 'Top Instructors',
    'recently_added': 'Recently Added',
    'suggestion_for_you': 'Suggestion for You',
    'see_all': 'See All',
    'notification': 'Notification',
    'all': 'All',
    '3d_design': '3D Design',
    'graphic_design': 'Graphic Design',
    'web_development': 'Web Development',
    'seo_marketing': 'SEO & Marketing',
    'finance': 'Finance & Accounting',
    'personal_development': 'Personal Development',
    'office_productivity': 'Office Productivity',
    'hr_management': 'HR Management',
    'course_detail': 'Course Detail',
    'about_course': 'About Course',
    'lessons': 'Lessons',
    'reviews': 'Reviews',
    'enroll_now': 'Enroll Now',
    'price': 'Price',
    'instructor': 'Instructor',
    'students': 'Students',
    'course_includes': 'Course Includes',
    'settings': 'Settings',
    'edit_profile': 'Edit Profile',
    'password_manager': 'Password Manager',
    'terms_condition': 'Terms & Condition',
    'about_us': 'About Us',
    'privacy_policy': 'Privacy Policy',
    'delete_account': 'Delete Account',
    'log_out': 'Log Out',
    'login_signup': 'Login / Signup',
    'select_language': 'App Language',
    'choose_language': 'Choose Language',
    'kurdish': 'کوردی',
    'english': 'English',
    'arabic': 'العربية',
    'sign_in': 'Sign In',
    'sign_up': 'Sign Up',
    'welcome_back': 'Welcome Back!',
    'create_account': 'Create Account',
    'email': 'Email',
    'password': 'Password',
    'forgot_password': 'Forgot Password?',
    'dont_have_account': 'Don\'t have an account?',
    'already_have_account': 'Already have an account?',
    'full_name': 'Full Name',
    'phone_number': 'Phone Number',
    'continue_button': 'Continue',
    'submit': 'Submit',
    'save_changes': 'Save Changes',
    'payment_method': 'Payment Method',
    'review_summary': 'Review Summary',
    'add_card': 'Add New Card',
    'e_receipt': 'E-Receipt',
    'card_number': 'Card Number',
    'card_holder': 'Card Holder Name',
    'expiry_date': 'Expiry Date',
    'cvv': 'CVV',
    'confirm_payment': 'Confirm Payment',
    'enroll_success': 'Successfully Enrolled!',
    'logout_confirm_title': 'Log Out',
    'logout_confirm_msg': 'Are you sure you want to log out of your account?',
    'delete_account_title': 'Delete Account',
    'delete_account_msg': 'Are you sure you want to delete your account? This action cannot be undone.',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'ok': 'OK',
    'no_notifications': 'No Notifications Yet',
    'no_courses': 'No Courses Found',
    'no_favourites': 'No Favorite Courses Yet',
    'no_internet': 'No Internet Connection',
    'search': 'Search',
    'filter': 'Filter',
    'reset': 'Reset',
    'apply': 'Apply',
    'ongoing': 'Ongoing',
    'completed': 'Completed',
    'all_courses': 'All Courses',
    'explore_all_courses': 'Explore All Courses',
    'courses_available': 'courses available',
    'search_courses': 'Search courses...',
    'browse_all_courses': 'Browse All Courses',
  },
  // Arabic - Modern Standard Arabic (Natural native phrasing)
  'ar': {
    'nav_home': 'الرئيسية',
    'nav_explore': 'استكشاف',
    'nav_my_course': 'دوراتي',
    'nav_chats': 'المحادثات',
    'nav_profile': 'الملف الشخصي',
    'home_search_placeholder': 'البحث عن دورة...',
    'categories': 'التصنيفات',
    'popular_courses': 'الدورات الشائعة',
    'recommended_for_you': 'موصى به لك',
    'top_instructors': 'أبرز المدربين',
    'recently_added': 'المضافة حديثاً',
    'suggestion_for_you': 'مقترحات لك',
    'see_all': 'عرض الكل',
    'notification': 'الإشعارات',
    'all': 'الكل',
    '3d_design': 'تصميم ثلاثي الأبعاد',
    'graphic_design': 'التصميم الجرافيكي',
    'web_development': 'تطوير الويب',
    'seo_marketing': 'التسويق والسيو',
    'finance': 'المالية والمحاسبة',
    'personal_development': 'التنمية الشخصية',
    'office_productivity': 'الإنتاجية المكتبية',
    'hr_management': 'إدارة الموارد البشرية',
    'course_detail': 'تفاصيل الدورة',
    'about_course': 'عن الدورة',
    'lessons': 'الدروس',
    'reviews': 'التقييمات',
    'enroll_now': 'التحق الآن',
    'price': 'السعر',
    'instructor': 'المدرب',
    'students': 'الطلاب',
    'course_includes': 'مميزات الدورة',
    'settings': 'الإعدادات',
    'edit_profile': 'تعديل الملف الشخصي',
    'password_manager': 'إدارة كلمة المرور',
    'terms_condition': 'الشروط والأحكام',
    'about_us': 'من نحن',
    'privacy_policy': 'سياسة الخصوصية',
    'delete_account': 'حذف الحساب',
    'log_out': 'تسجيل الخروج',
    'login_signup': 'تسجيل الدخول / إنشاء حساب',
    'select_language': 'لغة التطبيق',
    'choose_language': 'اختر اللغة',
    'kurdish': 'کوردی',
    'english': 'English',
    'arabic': 'العربية',
    'sign_in': 'تسجيل الدخول',
    'sign_up': 'إنشاء حساب',
    'welcome_back': 'مرحباً بعودتك!',
    'create_account': 'إنشاء حساب جديد',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'forgot_password': 'نسيت كلمة المرور؟',
    'dont_have_account': 'ليس لديك حساب؟',
    'already_have_account': 'لديك حساب بالفعل؟',
    'full_name': 'الاسم الكامل',
    'phone_number': 'رقم الهاتف',
    'continue_button': 'متابعة',
    'submit': 'إرسال',
    'save_changes': 'حفظ التغييرات',
    'payment_method': 'طريقة الدفع',
    'review_summary': 'ملخص الطلب',
    'add_card': 'إضافة بطاقة جديدة',
    'e_receipt': 'الإيصال الإلكتروني',
    'card_number': 'رقم البطاقة',
    'card_holder': 'اسم حامل البطاقة',
    'expiry_date': 'تاريخ الانتهاء',
    'cvv': 'رمز الأمان (CVV)',
    'confirm_payment': 'تأكيد الدفع',
    'enroll_success': 'تم التسجيل بنجاح!',
    'logout_confirm_title': 'تسجيل الخروج',
    'logout_confirm_msg': 'هل أنت تأكد من تسجيل الخروج من حسابك؟',
    'delete_account_title': 'حذف الحساب',
    'delete_account_msg': 'هل أنت تأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'ok': 'موافق',
    'no_notifications': 'لا توجد إشعارات حتى الآن',
    'no_courses': 'لم يتم العثور على دورات',
    'no_favourites': 'لا توجد دورات مفضلة حتى الآن',
    'no_internet': 'لا يوجد اتصال بالإنترنت',
    'search': 'بحث',
    'filter': 'تصفية',
    'reset': 'إعادة ضبط',
    'apply': 'تطبيق',
    'ongoing': 'مستمرة',
    'completed': 'مكتملة',
    'all_courses': 'جميع الدورات',
    'explore_all_courses': 'استكشف جميع الدورات',
    'courses_available': 'دورة متاحة',
    'search_courses': 'البحث في الدورات...',
    'browse_all_courses': 'تصفح جميع الدورات',
  },
};

extension BuildContextLocalizationsExtension on BuildContext {
  String tr(String key) => FFLocalizations.getText(this, key);
}

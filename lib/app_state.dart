import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _appLanguage =
          await secureStorage.getString('ff_appLanguage') ?? _appLanguage;
    });
    await _safeInitAsync(() async {
      _isIntro = await secureStorage.getBool('ff_isIntro') ?? _isIntro;
    });
    await _safeInitAsync(() async {
      _isLogin = await secureStorage.getBool('ff_isLogin') ?? _isLogin;
    });
    await _safeInitAsync(() async {
      _deviceId = await secureStorage.getString('ff_deviceId') ?? _deviceId;
    });
    await _safeInitAsync(() async {
      final stored =
          await secureStorage.getString('ff_currencyType') ?? _currencyType;
      _currencyType =
          stored.replaceAll('\$', '').replaceAll('USD', '').trim();
      if (_currencyType != stored) {
        await secureStorage.setString('ff_currencyType', _currencyType);
      }
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_userDetail') != null) {
        try {
          final serializedData =
              await secureStorage.getString('ff_userDetail') ?? '{}';
          _userDetail =
              LoginModelStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    await _safeInitAsync(() async {
      _phone = await secureStorage.getString('ff_phone') ?? _phone;
    });
    await _safeInitAsync(() async {
      _countryCodeEdit = await secureStorage.getString('ff_countryCodeEdit') ??
          _countryCodeEdit;
    });
    await _safeInitAsync(() async {
      _countryName =
          await secureStorage.getString('ff_countryName') ?? _countryName;
    });
    await _safeInitAsync(() async {
      _searchList =
          await secureStorage.getStringList('ff_searchList') ?? _searchList;
    });
    await _safeInitAsync(() async {
      _defTimeZoneName = await secureStorage.getString('ff_defTimeZoneName') ??
          _defTimeZoneName;
    });
    await _safeInitAsync(() async {
      _currentPassword = await secureStorage.getString('ff_currentPassword') ??
          _currentPassword;
    });
    await _safeInitAsync(() async {
      _favouriteList = (await secureStorage.getStringList('ff_favouriteList'))
              ?.map((x) {
                try {
                  return RecommendedForYouModelStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _favouriteList;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  String _appLanguage = 'ckb';
  String get appLanguage => _appLanguage;
  set appLanguage(String value) {
    _appLanguage = value;
    secureStorage.setString('ff_appLanguage', value);
    notifyListeners();
  }

  void setAppLanguage(String value) {
    appLanguage = value;
  }

  bool _isIntro = false;
  bool get isIntro => _isIntro;
  set isIntro(bool value) {
    _isIntro = value;
    secureStorage.setBool('ff_isIntro', value);
  }

  void deleteIsIntro() {
    secureStorage.delete(key: 'ff_isIntro');
  }

  bool _isLogin = false;
  bool get isLogin => _isLogin;
  set isLogin(bool value) {
    _isLogin = value;
    secureStorage.setBool('ff_isLogin', value);
  }

  void deleteIsLogin() {
    secureStorage.delete(key: 'ff_isLogin');
  }

  bool _connected = true;
  bool get connected => _connected;
  set connected(bool value) {
    _connected = value;
  }

  String _deviceId = '';
  String get deviceId => _deviceId;
  set deviceId(String value) {
    _deviceId = value;
    secureStorage.setString('ff_deviceId', value);
  }

  void deleteDeviceId() {
    secureStorage.delete(key: 'ff_deviceId');
  }

  /// Kept empty — prices are formatted via PriceFormatter with DB currency (e.g. `25,000 IQD`).
  String _currencyType = '';
  String get currencyType => _currencyType;
  set currencyType(String value) {
    // Strip dollar signs from any persisted/legacy value.
    _currencyType = value.replaceAll('\$', '').replaceAll('USD', '').trim();
    secureStorage.setString('ff_currencyType', _currencyType);
  }

  void deleteCurrencyType() {
    secureStorage.delete(key: 'ff_currencyType');
  }

  LoginModelStruct _userDetail = LoginModelStruct.fromSerializableMap(jsonDecode(
      '{\"userName\":\"Dev cooper\",\"firstName\":\"Dev\",\"lastName\":\"Cooper\",\"email\":\"devcooper@gmail.com\",\"countryCode\":\"+91\",\"phoneNumber\":\"9909999099\",\"password\":\"123456\"}'));
  LoginModelStruct get userDetail => _userDetail;
  set userDetail(LoginModelStruct value) {
    _userDetail = value;
    secureStorage.setString('ff_userDetail', value.serialize());
  }

  void deleteUserDetail() {
    secureStorage.delete(key: 'ff_userDetail');
  }

  void updateUserDetailStruct(Function(LoginModelStruct) updateFn) {
    updateFn(_userDetail);
    secureStorage.setString('ff_userDetail', _userDetail.serialize());
  }

  List<IntroModelStruct> _introList = [
    IntroModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/4ry07y5j2ex3/Frame.png\",\"title\":\"First See Learning\",\"subTitle\":\"Forget about a for of paper all knowledge in \\none learning!\"}')),
    IntroModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/5bw3d273ecj2/Frame_(1).png\",\"title\":\"Connect With Everyone\",\"subTitle\":\"Always keep in touch with your tutor & friend. \\nLet’s get connected!\"}')),
    IntroModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/y72hn4zf48e3/Frame_(2).png\",\"title\":\"Always fascinated learning\",\"subTitle\":\"Anywhere, anytime. The time is at your discretion \\nso study whenever you want.\"}'))
  ];
  List<IntroModelStruct> get introList => _introList;
  set introList(List<IntroModelStruct> value) {
    _introList = value;
  }

  void addToIntroList(IntroModelStruct value) {
    introList.add(value);
  }

  void removeFromIntroList(IntroModelStruct value) {
    introList.remove(value);
  }

  void removeAtIndexFromIntroList(int index) {
    introList.removeAt(index);
  }

  void updateIntroListAtIndex(
    int index,
    IntroModelStruct Function(IntroModelStruct) updateFn,
  ) {
    introList[index] = updateFn(_introList[index]);
  }

  void insertAtIndexInIntroList(int index, IntroModelStruct value) {
    introList.insert(index, value);
  }

  String _phone = '';
  String get phone => _phone;
  set phone(String value) {
    _phone = value;
    secureStorage.setString('ff_phone', value);
  }

  void deletePhone() {
    secureStorage.delete(key: 'ff_phone');
  }

  /// Public avatar URL for the signed-in user (from Storage / profiles).
  String _profileAvatarUrl = '';
  String get profileAvatarUrl => _profileAvatarUrl;
  set profileAvatarUrl(String value) {
    _profileAvatarUrl = value;
  }

  String _countryCodeEdit = '964';
  String get countryCodeEdit => _countryCodeEdit;
  set countryCodeEdit(String value) {
    _countryCodeEdit = value;
    secureStorage.setString('ff_countryCodeEdit', value);
  }

  void deleteCountryCodeEdit() {
    secureStorage.delete(key: 'ff_countryCodeEdit');
  }

  String _countryCode = '964';
  String get countryCode => _countryCode;
  set countryCode(String value) {
    _countryCode = value;
  }

  String _countryName = 'IQ';
  String get countryName => _countryName;
  set countryName(String value) {
    _countryName = value;
    secureStorage.setString('ff_countryName', value);
  }

  void deleteCountryName() {
    secureStorage.delete(key: 'ff_countryName');
  }

  int _homePageIndex = 0;
  int get homePageIndex => _homePageIndex;
  set homePageIndex(int value) {
    _homePageIndex = value;
  }

  List<String> _searchList = [];
  String _lastSearchQuery = '';
  String get lastSearchQuery => _lastSearchQuery;
  set lastSearchQuery(String value) {
    _lastSearchQuery = value;
  }
  List<String> get searchList => _searchList;
  set searchList(List<String> value) {
    _searchList = value;
    secureStorage.setStringList('ff_searchList', value);
  }

  void deleteSearchList() {
    secureStorage.delete(key: 'ff_searchList');
  }

  void addToSearchList(String value) {
    searchList.add(value);
    secureStorage.setStringList('ff_searchList', _searchList);
  }

  void removeFromSearchList(String value) {
    searchList.remove(value);
    secureStorage.setStringList('ff_searchList', _searchList);
  }

  void removeAtIndexFromSearchList(int index) {
    searchList.removeAt(index);
    secureStorage.setStringList('ff_searchList', _searchList);
  }

  void updateSearchListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    searchList[index] = updateFn(_searchList[index]);
    secureStorage.setStringList('ff_searchList', _searchList);
  }

  void insertAtIndexInSearchList(int index, String value) {
    searchList.insert(index, value);
    secureStorage.setStringList('ff_searchList', _searchList);
  }

  /// Loaded from Supabase `categories` (mock seed removed).
  List<CategoryModelStruct> _categoriesList = [];
  List<CategoryModelStruct> get categoriesList => _categoriesList;
  set categoriesList(List<CategoryModelStruct> value) {
    _categoriesList = value;
  }

  bool catalogLoaded = false;
  bool catalogLoading = false;
  String catalogError = '';
  List<String> categoryIds = [];
  List<String> instructorIds = [];
  List<String> recommendedCourseIds = [];
  List<String> popularCourseIds = [];
  Map<String, String> catalogCourseIds = {};

  void addToCategoriesList(CategoryModelStruct value) {
    categoriesList.add(value);
  }

  void removeFromCategoriesList(CategoryModelStruct value) {
    categoriesList.remove(value);
  }

  void removeAtIndexFromCategoriesList(int index) {
    categoriesList.removeAt(index);
  }

  void updateCategoriesListAtIndex(
    int index,
    CategoryModelStruct Function(CategoryModelStruct) updateFn,
  ) {
    categoriesList[index] = updateFn(_categoriesList[index]);
  }

  void insertAtIndexInCategoriesList(int index, CategoryModelStruct value) {
    categoriesList.insert(index, value);
  }

  List<NotificationsModelStruct> _notificationsList = [
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Payment successful\",\"subTitle\":\"You have made a course payment\",\"createAt\":\"3h ago\"}')),
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Today’s adapical offers\",\"subTitle\":\"You get a special  pormo table\",\"createAt\":\"8h ago\"}')),
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"New category courses!\",\"subTitle\":\"Now the 3D design course is avalible\",\"createAt\":\"12h ago\"}')),
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Credit card connected!\",\"subTitle\":\"Credit card has been linked\",\"createAt\":\"12 Jan\"}')),
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Account setup successful!\",\"subTitle\":\"Your account has been created\",\"createAt\":\"10 Feb\"}')),
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Changes in customer service\",\"subTitle\":\"Your account has been created\",\"createAt\":\"13 Mar\"}')),
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Changes in customer service\",\"subTitle\":\"Your account has been created\",\"createAt\":\"25 Apr\"}'))
  ];
  List<NotificationsModelStruct> get notificationsList => _notificationsList;
  set notificationsList(List<NotificationsModelStruct> value) {
    _notificationsList = value;
  }

  void addToNotificationsList(NotificationsModelStruct value) {
    notificationsList.add(value);
  }

  void removeFromNotificationsList(NotificationsModelStruct value) {
    notificationsList.remove(value);
  }

  void removeAtIndexFromNotificationsList(int index) {
    notificationsList.removeAt(index);
  }

  void updateNotificationsListAtIndex(
    int index,
    NotificationsModelStruct Function(NotificationsModelStruct) updateFn,
  ) {
    notificationsList[index] = updateFn(_notificationsList[index]);
  }

  void insertAtIndexInNotificationsList(
      int index, NotificationsModelStruct value) {
    notificationsList.insert(index, value);
  }

  List<ChatsModelStruct> _chatList = [
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/kfwnr7dm50z9/Mentors1.png\",\"name\":\"Robert Jones\",\"chat\":\"You sent a gift.\",\"lastCreateAt\":\"Now\"}')),
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/j16ml8ikczk7/Mentors2.png\",\"name\":\"Andrew Anderson\",\"chat\":\"You sent a gift.\",\"lastCreateAt\":\"12:50 PM\"}')),
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/oi3tdop4013h/Ellipse_900.png\",\"name\":\"Benjamin Baker\",\"chat\":\"I am start my assignment today.\",\"lastCreateAt\":\"09:00 PM\"}')),
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/oi3tdop4013h/Ellipse_900.png\",\"name\":\"Samuel Scott\",\"chat\":\"Okay, got it.\",\"lastCreateAt\":\"01:50 AM\"}')),
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/oi3tdop4013h/Ellipse_900.png\",\"name\":\"Jonathan Jackson\",\"chat\":\"Wanna go outside someday?\",\"lastCreateAt\":\"02:20 PM\"}')),
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/oi3tdop4013h/Ellipse_900.png\",\"name\":\"Joseph Johnson\",\"chat\":\"Thanks for sharing 😊\",\"lastCreateAt\":\"05:20 PM\"}')),
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/oi3tdop4013h/Ellipse_900.png\",\"name\":\"Peter Parker\",\"chat\":\"Can we have call now?\",\"lastCreateAt\":\"09:00 PM\"}'))
  ];
  List<ChatsModelStruct> get chatList => _chatList;
  set chatList(List<ChatsModelStruct> value) {
    _chatList = value;
  }

  void addToChatList(ChatsModelStruct value) {
    chatList.add(value);
  }

  void removeFromChatList(ChatsModelStruct value) {
    chatList.remove(value);
  }

  void removeAtIndexFromChatList(int index) {
    chatList.removeAt(index);
  }

  void updateChatListAtIndex(
    int index,
    ChatsModelStruct Function(ChatsModelStruct) updateFn,
  ) {
    chatList[index] = updateFn(_chatList[index]);
  }

  void insertAtIndexInChatList(int index, ChatsModelStruct value) {
    chatList.insert(index, value);
  }

  List<String> _couponList = ['HOLIDAYDEAL', 'ERFTGW', 'WELCOME20'];
  List<String> get couponList => _couponList;
  set couponList(List<String> value) {
    _couponList = value;
  }

  void addToCouponList(String value) {
    couponList.add(value);
  }

  void removeFromCouponList(String value) {
    couponList.remove(value);
  }

  void removeAtIndexFromCouponList(int index) {
    couponList.removeAt(index);
  }

  void updateCouponListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    couponList[index] = updateFn(_couponList[index]);
  }

  void insertAtIndexInCouponList(int index, String value) {
    couponList.insert(index, value);
  }

  String _favText = 'Course is favourite';
  String get favText => _favText;
  set favText(String value) {
    _favText = value;
  }

  String _unfavText = 'Course is unfavourite';
  String get unfavText => _unfavText;
  set unfavText(String value) {
    _unfavText = value;
  }

  String _defTimeZoneName = 'America/Detroit';
  String get defTimeZoneName => _defTimeZoneName;
  set defTimeZoneName(String value) {
    _defTimeZoneName = value;
    secureStorage.setString('ff_defTimeZoneName', value);
  }

  void deleteDefTimeZoneName() {
    secureStorage.delete(key: 'ff_defTimeZoneName');
  }

  String _currentPassword = '';
  String get currentPassword => _currentPassword;
  set currentPassword(String value) {
    _currentPassword = value;
    secureStorage.setString('ff_currentPassword', value);
  }

  void deleteCurrentPassword() {
    secureStorage.delete(key: 'ff_currentPassword');
  }

  /// Populated from Supabase `enrollments` (status = ongoing).
  List<OngoingModelStruct> _OngoingList = [];
  List<OngoingModelStruct> get OngoingList => _OngoingList;
  set OngoingList(List<OngoingModelStruct> value) {
    _OngoingList = value;
  }

  void addToOngoingList(OngoingModelStruct value) {
    OngoingList.add(value);
  }

  void removeFromOngoingList(OngoingModelStruct value) {
    OngoingList.remove(value);
  }

  void removeAtIndexFromOngoingList(int index) {
    OngoingList.removeAt(index);
  }

  void updateOngoingListAtIndex(
    int index,
    OngoingModelStruct Function(OngoingModelStruct) updateFn,
  ) {
    OngoingList[index] = updateFn(_OngoingList[index]);
  }

  void insertAtIndexInOngoingList(int index, OngoingModelStruct value) {
    OngoingList.insert(index, value);
  }

  /// Populated from Supabase `enrollments` (status = completed).
  List<CompletedModelStruct> _CompletedList = [];
  List<CompletedModelStruct> get CompletedList => _CompletedList;
  set CompletedList(List<CompletedModelStruct> value) {
    _CompletedList = value;
  }

  void addToCompletedList(CompletedModelStruct value) {
    CompletedList.add(value);
  }

  void removeFromCompletedList(CompletedModelStruct value) {
    CompletedList.remove(value);
  }

  void removeAtIndexFromCompletedList(int index) {
    CompletedList.removeAt(index);
  }

  void updateCompletedListAtIndex(
    int index,
    CompletedModelStruct Function(CompletedModelStruct) updateFn,
  ) {
    CompletedList[index] = updateFn(_CompletedList[index]);
  }

  void insertAtIndexInCompletedList(int index, CompletedModelStruct value) {
    CompletedList.insert(index, value);
  }

  /// Loaded from Supabase `courses` where `is_recommended = true`.
  List<RecommendedForYouModelStruct> _recommendedForYouList = [];
  List<RecommendedForYouModelStruct> get recommendedForYouList =>
      _recommendedForYouList;
  set recommendedForYouList(List<RecommendedForYouModelStruct> value) {
    _recommendedForYouList = value;
  }

  void addToRecommendedForYouList(RecommendedForYouModelStruct value) {
    recommendedForYouList.add(value);
  }

  void removeFromRecommendedForYouList(RecommendedForYouModelStruct value) {
    recommendedForYouList.remove(value);
  }

  void removeAtIndexFromRecommendedForYouList(int index) {
    recommendedForYouList.removeAt(index);
  }

  void updateRecommendedForYouListAtIndex(
    int index,
    RecommendedForYouModelStruct Function(RecommendedForYouModelStruct)
        updateFn,
  ) {
    recommendedForYouList[index] = updateFn(_recommendedForYouList[index]);
  }

  void insertAtIndexInRecommendedForYouList(
      int index, RecommendedForYouModelStruct value) {
    recommendedForYouList.insert(index, value);
  }

  /// Loaded from Supabase `courses` where `is_popular = true`.
  List<RecommendedForYouModelStruct> _popularCoursesList = [];
  List<RecommendedForYouModelStruct> get popularCoursesList =>
      _popularCoursesList;
  set popularCoursesList(List<RecommendedForYouModelStruct> value) {
    _popularCoursesList = value;
  }

  void addToPopularCoursesList(RecommendedForYouModelStruct value) {
    popularCoursesList.add(value);
  }

  void removeFromPopularCoursesList(RecommendedForYouModelStruct value) {
    popularCoursesList.remove(value);
  }

  void removeAtIndexFromPopularCoursesList(int index) {
    popularCoursesList.removeAt(index);
  }

  void updatePopularCoursesListAtIndex(
    int index,
    RecommendedForYouModelStruct Function(RecommendedForYouModelStruct)
        updateFn,
  ) {
    popularCoursesList[index] = updateFn(_popularCoursesList[index]);
  }

  void insertAtIndexInPopularCoursesList(
      int index, RecommendedForYouModelStruct value) {
    popularCoursesList.insert(index, value);
  }

  /// Loaded from Supabase `courses` (all published courses).
  List<RecommendedForYouModelStruct> _allCoursesList = [];
  List<RecommendedForYouModelStruct> get allCoursesList {
    if (_allCoursesList.isNotEmpty) {
      return _allCoursesList;
    }
    // Fallback: merge recommended and popular without duplicates
    final seen = <String>{};
    final merged = <RecommendedForYouModelStruct>[];
    for (final c in [...recommendedForYouList, ...popularCoursesList]) {
      final key = c.id.isNotEmpty ? c.id : c.title;
      if (key.isNotEmpty && seen.add(key)) {
        merged.add(c);
      }
    }
    return merged;
  }

  set allCoursesList(List<RecommendedForYouModelStruct> value) {
    _allCoursesList = value;
  }

  void addToAllCoursesList(RecommendedForYouModelStruct value) {
    allCoursesList.add(value);
  }

  void removeFromAllCoursesList(RecommendedForYouModelStruct value) {
    allCoursesList.remove(value);
  }

  void removeAtIndexFromAllCoursesList(int index) {
    allCoursesList.removeAt(index);
  }

  void updateAllCoursesListAtIndex(
    int index,
    RecommendedForYouModelStruct Function(RecommendedForYouModelStruct)
        updateFn,
  ) {
    allCoursesList[index] = updateFn(_allCoursesList[index]);
  }

  void insertAtIndexInAllCoursesList(
      int index, RecommendedForYouModelStruct value) {
    allCoursesList.insert(index, value);
  }

  /// Loaded from Supabase `instructors`.
  List<InstructorModelStruct> _instructorList = [];
  List<InstructorModelStruct> get instructorList => _instructorList;
  set instructorList(List<InstructorModelStruct> value) {
    _instructorList = value;
  }

  void addToInstructorList(InstructorModelStruct value) {
    instructorList.add(value);
  }

  void removeFromInstructorList(InstructorModelStruct value) {
    instructorList.remove(value);
  }

  void removeAtIndexFromInstructorList(int index) {
    instructorList.removeAt(index);
  }

  void updateInstructorListAtIndex(
    int index,
    InstructorModelStruct Function(InstructorModelStruct) updateFn,
  ) {
    instructorList[index] = updateFn(_instructorList[index]);
  }

  void insertAtIndexInInstructorList(int index, InstructorModelStruct value) {
    instructorList.insert(index, value);
  }

  List<StudentModelStruct> _studentsList = [
    StudentModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/r4ont95rfcbj/Ellipse_898_(12)1.png\",\"title\":\"Benny Sepanbauer\"}')),
    StudentModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/d68cpaadqucm/Ellipse_898_(13)1.png\",\"title\":\"James Smith\"}')),
    StudentModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/j9cytdwph73x/Ellipse_898_(10)1.png\",\"title\":\"Michael Brown\"}')),
    StudentModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/0i010p4aebrj/Ellipse_898_(9)1.png\",\"title\":\"Daniel Taylor\"}')),
    StudentModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/potbfu46z25q/Ellipse_898_(8)1.png\",\"title\":\"Christopher Clark\"}')),
    StudentModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/fku6swvpx91c/Ellipse_898_(7)1.png\",\"title\":\"Matthew White\"}')),
    StudentModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/t4lhedhkv5lj/Ellipse_898_(6)1.png\",\"title\":\"William Williams\"}')),
    StudentModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/md8o58fnl4uy/Ellipse_464_(6).png\",\"title\":\"Joshua Hall\"}'))
  ];
  List<StudentModelStruct> get studentsList => _studentsList;
  set studentsList(List<StudentModelStruct> value) {
    _studentsList = value;
  }

  void addToStudentsList(StudentModelStruct value) {
    studentsList.add(value);
  }

  void removeFromStudentsList(StudentModelStruct value) {
    studentsList.remove(value);
  }

  void removeAtIndexFromStudentsList(int index) {
    studentsList.removeAt(index);
  }

  void updateStudentsListAtIndex(
    int index,
    StudentModelStruct Function(StudentModelStruct) updateFn,
  ) {
    studentsList[index] = updateFn(_studentsList[index]);
  }

  void insertAtIndexInStudentsList(int index, StudentModelStruct value) {
    studentsList.insert(index, value);
  }

  List<ReviewModelStruct> _reviewList = [
    ReviewModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/potbfu46z25q/Ellipse_898_(8)1.png\",\"name\":\"James\",\"createAt\":\"11 month ago\",\"subTitle\":\"Start by learning the basics of UI/UX design principles, including user  psychology, interaction design, visual design, and usability principles.\",\"review\":\"5.0\"}')),
    ReviewModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/hukzcdnkhsac/Ellipse_13_(1).png\",\"name\":\"William\",\"createAt\":\"11 month ago\",\"subTitle\":\"Start by learning the basics of UI/UX design principles, including user  psychology, interaction design, visual design, and usability principles.\",\"review\":\"5.0\"}')),
    ReviewModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/3wncfwd4mpzt/Ellipse_13_(2).png\",\"name\":\"Benjamin\",\"createAt\":\"11 month ago\",\"subTitle\":\"Start by learning the basics of UI/UX design principles, including user  psychology, interaction design, visual design, and usability principles.\",\"review\":\"5.0\"}')),
    ReviewModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/skuv6rffdzu8/Ellipse_13_(3).png\",\"name\":\"Alexander\",\"createAt\":\"11 month ago\",\"subTitle\":\"Start by learning the basics of UI/UX design principles, including user  psychology, interaction design, visual design, and usability principles.\",\"review\":\"5.0\"}'))
  ];
  List<ReviewModelStruct> get reviewList => _reviewList;
  set reviewList(List<ReviewModelStruct> value) {
    _reviewList = value;
  }

  void addToReviewList(ReviewModelStruct value) {
    reviewList.add(value);
  }

  void removeFromReviewList(ReviewModelStruct value) {
    reviewList.remove(value);
  }

  void removeAtIndexFromReviewList(int index) {
    reviewList.removeAt(index);
  }

  void updateReviewListAtIndex(
    int index,
    ReviewModelStruct Function(ReviewModelStruct) updateFn,
  ) {
    reviewList[index] = updateFn(_reviewList[index]);
  }

  void insertAtIndexInReviewList(int index, ReviewModelStruct value) {
    reviewList.insert(index, value);
  }

  List<RecommendedForYouModelStruct> _favouriteList = [];
  List<RecommendedForYouModelStruct> get favouriteList => _favouriteList;
  set favouriteList(List<RecommendedForYouModelStruct> value) {
    _favouriteList = value;
    secureStorage.setStringList(
        'ff_favouriteList', value.map((x) => x.serialize()).toList());
  }

  void deleteFavouriteList() {
    secureStorage.delete(key: 'ff_favouriteList');
  }

  void addToFavouriteList(RecommendedForYouModelStruct value) {
    favouriteList.add(value);
    secureStorage.setStringList(
        'ff_favouriteList', _favouriteList.map((x) => x.serialize()).toList());
  }

  void removeFromFavouriteList(RecommendedForYouModelStruct value) {
    favouriteList.remove(value);
    secureStorage.setStringList(
        'ff_favouriteList', _favouriteList.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromFavouriteList(int index) {
    favouriteList.removeAt(index);
    secureStorage.setStringList(
        'ff_favouriteList', _favouriteList.map((x) => x.serialize()).toList());
  }

  void updateFavouriteListAtIndex(
    int index,
    RecommendedForYouModelStruct Function(RecommendedForYouModelStruct)
        updateFn,
  ) {
    favouriteList[index] = updateFn(_favouriteList[index]);
    secureStorage.setStringList(
        'ff_favouriteList', _favouriteList.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInFavouriteList(
      int index, RecommendedForYouModelStruct value) {
    favouriteList.insert(index, value);
    secureStorage.setStringList(
        'ff_favouriteList', _favouriteList.map((x) => x.serialize()).toList());
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}

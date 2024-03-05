import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fixawy_provider/locale/applocalizations.dart';
import 'package:fixawy_provider/locale/base_language.dart';
import 'package:fixawy_provider/locale/language_ar.dart';
import 'package:fixawy_provider/models/booking_detail_response.dart';
import 'package:fixawy_provider/models/notification_list_response.dart';
import 'package:fixawy_provider/models/remote_config_data_model.dart';
import 'package:fixawy_provider/models/revenue_chart_data.dart';
import 'package:fixawy_provider/models/service_detail_response.dart';
import 'package:fixawy_provider/models/total_earning_response.dart';
import 'package:fixawy_provider/models/user_data.dart';
import 'package:fixawy_provider/models/wallet_history_list_response.dart';
import 'package:fixawy_provider/networks/firebase_services/auth_services.dart';
import 'package:fixawy_provider/networks/firebase_services/chat_messages_service.dart';
import 'package:fixawy_provider/networks/firebase_services/notification_service.dart';
import 'package:fixawy_provider/networks/firebase_services/user_services.dart';
import 'package:fixawy_provider/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:fixawy_provider/screens/splash_screen.dart';
import 'package:fixawy_provider/store/AppStore.dart';
import 'package:fixawy_provider/utils/common.dart';
import 'package:fixawy_provider/utils/configs.dart';
import 'package:fixawy_provider/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import 'app_theme.dart';
import 'models/booking_list_response.dart';
import 'models/booking_status_response.dart';
import 'models/dashboard_response.dart';
import 'models/extra_charges_model.dart';
import 'models/handyman_dashboard_response.dart';
import 'models/payment_list_reasponse.dart';
import 'provider/timeSlots/timeSlotStore/time_slot_store.dart';
import 'utils/one_signal_utils.dart';

//region Mobx Stores
AppStore appStore = AppStore();
TimeSlotStore timeSlotStore = TimeSlotStore();
//endregion

//region Firebase Services
UserService userService = UserService();
AuthService authService = AuthService();

ChatServices chatServices = ChatServices();
NotificationService notificationService = NotificationService();
//endregion

//region Global Variables
Languages languages = LanguageAr();
List<RevenueChartData> chartData = [];
RemoteConfigDataModel remoteConfigDataModel = RemoteConfigDataModel();
List<ExtraChargesModel> chargesList = [];
//endregion

//region Cached Response Variables for Dashboard Tabs
DashboardResponse? cachedProviderDashboardResponse;
HandymanDashBoardResponse? cachedHandymanDashboardResponse;
List<BookingData>? cachedBookingList;
List<PaymentData>? cachedPaymentList;
List<NotificationData>? cachedNotifications;
List<BookingStatusResponse>? cachedBookingStatusDropdown;
List<(int serviceId, ServiceDetailResponse)?> listOfCachedData = [];
List<BookingDetailResponse> cachedBookingDetailList = [];
List<(int postJobId, PostJobDetailResponse)?> cachedPostJobList = [];
List<UserData>? cachedHandymanList;
List<TotalData>? cachedTotalDataList;
List<WalletHistory>? cachedWalletList;

//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!isDesktop) {
    Firebase.initializeApp().then((value) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      setupFirebaseRemoteConfig();
    }).catchError((e) {
      log(e.toString());
    });
  }

  defaultSettings();

  await initialize();

  localeLanguageList = languageList();

  // appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));
  appStore.setLanguage(DEFAULT_LANGUAGE);

  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  await setLoginValues();

  initializeOneSignal();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    afterBuildCreated(() {
      int val = getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);

      if (val == THEME_MODE_LIGHT) {
        appStore.setDarkMode(false);
      } else if (val == THEME_MODE_DARK) {
        appStore.setDarkMode(true);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Observer(
        builder: (_) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          home: SplashScreen(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          supportedLocales: LanguageDataModel.languageLocales(),
          localizationsDelegates: [
            AppLocalizations(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(appStore.selectedLanguageCode),
        ),
      ),
    );
  }
}

import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/routes/app_pages.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'controllers/preferences_controller.dart';
import 'services/network_service.dart';
import 'services/global_wallet_service.dart';
import 'firebase_options.dart';
import 'i18n/app_languages.dart';
import 'theme/app_theme.dart';
import 'api/user_api.dart';
import 'widgets/wallet_service_initializer.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('✅ Firebase initialized');

    // Initialize Services
    await initializeServices();
    print('✅ All services initialized');

    runApp(const MyApp());
  } catch (e) {
    print('❌ Error in main(): $e');
    // Rethrow to ensure the app doesn't start in an inconsistent state
    rethrow;
  }
}

Future<void> initializeServices() async {
  try {
    // Network Service debe ser el primero en inicializarse
    final networkService = Get.put(NetworkService(), permanent: true);
    await networkService.init();
    print('✅ Network Service initialized');

    // Global Wallet Service
    await Get.putAsync<GlobalWalletService>(
      () => GlobalWalletService().init(),
      permanent: true,
      tag: 'global_wallet_service',
    );
    print('✅ Global Wallet Service initialized');

    // Preferences Controller
    final prefsController = Get.put(PreferencesController(), permanent: true);
    await prefsController.init();
    print('✅ Preferences Controller initialized');

    // Configure Firebase services
    UserApi.configureRealtimeDatabase();
    print('✅ Firebase services configured');

    // Initialize Mobile Ads
    await MobileAds.instance.initialize();
    print('✅ Mobile Ads initialized');

  } catch (e) {
    print('❌ Error initializing services: $e');
    rethrow;
  }
}

class MyApp extends GetView<PreferencesController> {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WalletServiceInitializer(
      child: GetMaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.of(context).lightTheme,
        darkTheme: AppTheme.of(context).darkTheme,
        themeMode: controller.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        translations: AppLanguages(),
        locale: controller.locale.value,
        fallbackLocale: const Locale('en'),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}

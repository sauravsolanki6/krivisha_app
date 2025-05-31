import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krivisha_app/utility/app_colors.dart';
import 'package:krivisha_app/utility/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'notification_services.dart';
import 'view/splash/splashscreen.dart';
import 'dart:developer' as lg;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    // Initialize Firebase in the background isolate
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    lg.log('Background message received: ${message.toMap()}');
    lg.log(
        'Background message title: ${message.notification?.title ?? message.data['title'] ?? 'No title'}');
    lg.log(
        'Background message body: ${message.notification?.body ?? message.data['body'] ?? 'No body'}');
    lg.log('Background message data: ${message.data}');

    final notificationServices = NotificationServices();
    // Initialize local notifications for background
    await notificationServices
        .initLocalNotifications(navigatorKey.currentContext ?? Get.context!);
    await notificationServices.showNotification(message);
  } catch (e, stackTrace) {
    await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    lg.log('Error in background handler: $e');
  }
}

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.setAnalyticsCollectionEnabled(!kDebugMode);

  // Initialize NotificationServices
  final notificationServices = NotificationServices();

  // Print FCM token
  String token = await notificationServices.getDeviceToken();
  lg.log('FCM Token: $token');

  // Configure Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // Run the app in a guarded zone
  await runZonedGuarded<Future<void>>(() async {
    // Request notification permissions
    await notificationServices.requestNotificationPermission();

    // Set up Firebase Messaging background handler
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // Initialize local notifications and Firebase messaging
    // Delayed until GetMaterialApp provides context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationServices.initLocalNotifications(navigatorKey.currentContext!);
      notificationServices.firebaseInit(navigatorKey.currentContext!);
    });

    // Run the app
    runApp(const MyApp());
  }, (error, stackTrace) {
    // Log uncaught errors to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  });
}

class MyApp extends StatefulWidget {
  static const String apiUrl = 'https://staginglink.org/twice/';
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Krivisha App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
          background: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: AppColors.defaultblack,
          ),
          headlineSmall: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.defaultblack,
          ),
          bodyLarge: const TextStyle(color: AppColors.defaultblack),
          bodySmall: const TextStyle(color: AppColors.defaultblack),
          headlineLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.defaultblack,
          ),
          headlineMedium: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.defaultblack,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.defaultblack,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.defaultblack,
          ),
          titleSmall: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.defaultblack,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          prefixIconColor: AppColors.primary,
          labelStyle: TextStyle(color: AppColors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.borderColor),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          margin: EdgeInsets.all(8),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

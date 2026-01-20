import 'package:buscatelo/bloc/auth_bloc.dart';
import 'package:buscatelo/bloc/booking_bloc.dart';
import 'package:buscatelo/bloc/favorites_bloc.dart';
import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'package:buscatelo/commons/theme.dart';
import 'package:buscatelo/app/app_config.dart';
import 'package:buscatelo/app/utils/exit_app.dart';
import 'package:buscatelo/ui/pages/home/home_shell.dart';
import 'package:buscatelo/ui/utils/error_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  if (AppConfig.useFirebase) {
    if (kIsWeb) {
      final hasWebConfig = AppConfig.firebaseWebApiKey.isNotEmpty &&
          AppConfig.firebaseWebAppId.isNotEmpty &&
          AppConfig.firebaseWebProjectId.isNotEmpty;
      if (hasWebConfig) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: AppConfig.firebaseWebApiKey,
            authDomain: AppConfig.firebaseWebAuthDomain,
            projectId: AppConfig.firebaseWebProjectId,
            storageBucket: AppConfig.firebaseWebStorageBucket,
            messagingSenderId: AppConfig.firebaseWebMessagingSenderId,
            appId: AppConfig.firebaseWebAppId,
          ),
        );
        firebaseReady = true;
      }
    } else {
      await Firebase.initializeApp();
      firebaseReady = true;
    }
  }

  if (!kIsWeb &&
      AppConfig.enablePayments &&
      AppConfig.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exitApp(1);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) => CustomErrorWidget();
  runApp(MyApp(firebaseReady: firebaseReady));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  const MyApp({Key? key, required this.firebaseReady}) : super(key: key);

  final bool firebaseReady;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking App',
      theme: ThemeData(
        primarySwatch: primarySwatch,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: primarySwatch)
            .copyWith(secondary: accentColor),
        fontFamily: 'avenir',
        cardColor: Colors.white,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => HotelBloc(firebaseReady: firebaseReady)
              ..retrieveHotels(),
          ),
          ChangeNotifierProvider(create: (_) => FavoritesBloc()),
          ChangeNotifierProvider(create: (_) => BookingBloc()),
          ChangeNotifierProvider(create: (_) => AuthBloc(firebaseReady: firebaseReady)),
        ],
        child: const HomeShell(),
      ),
    );
  }
}

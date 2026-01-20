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
  
  // Initialize Firebase
  if (AppConfig.useFirebase) {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  }
  
  // Initialize Stripe
  if (AppConfig.enablePayments && AppConfig.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
  }
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exitApp(1);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) => CustomErrorWidget();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  const MyApp({Key? key}) : super(key: key);
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
          ChangeNotifierProvider(create: (_) => HotelBloc()..retrieveHotels()),
          ChangeNotifierProvider(create: (_) => FavoritesBloc()),
          ChangeNotifierProvider(create: (_) => BookingBloc()),
          ChangeNotifierProvider(create: (_) => AuthBloc()),
        ],
        child: const HomeShell(),
      ),
    );
  }
}

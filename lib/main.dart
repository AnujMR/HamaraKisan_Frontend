import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/providers/homeProvider.dart';
import 'package:hamarakisan_front/providers/pinnedMandiProvider.dart';
import 'package:hamarakisan_front/providers/plantDisseasePredProvider.dart';
import 'package:hamarakisan_front/screens/splashScreen.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

final LocalStorage storage = localStorage;
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  return runApp(const MyApp());
}

awaitStorageReady() async {
  await initLocalStorage();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PinnedMandiProvider()),
        ChangeNotifierProvider(create: (_) => PlantDiseasePredProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

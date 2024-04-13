import 'package:whatsapp_web/default%20colors/default_colors.dart';
import 'package:whatsapp_web/provider/provider_chat.dart';
import 'package:whatsapp_web/provider/provider_email.dart';
import 'package:whatsapp_web/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

String firstRoute = "/";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC4U6De-3ILH8f3ZSliK_Eu8t7xamSaCW8",
          authDomain: "thesocial-786ed.firebaseapp.com",
          projectId: "thesocial-786ed",
          storageBucket: "thesocial-786ed.appspot.com",
          messagingSenderId: "812515365752",
          appId: "1:812515365752:web:0cb0202f4491715f162e8d"
          ));

  User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
  if (currentFirebaseUser != null) {
    firstRoute = '/home';
  }
  runApp(const MyApp());
}

final ThemeData defaultThemeOfWebApp = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: DefaultColors.primaryColor),
  useMaterial3: true,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProviderChat()),
        ChangeNotifierProvider(create: (_) => ProviderEmail()),
      ],
      child: MaterialApp(
        title: 'Whatsapp clone Web',
        theme: defaultThemeOfWebApp,
        debugShowCheckedModeBanner: false,
        initialRoute: firstRoute,
        onGenerateRoute: RoutesWebPages.createRoutes,
      ),
    );
  }
}

import 'package:whatsapp_web/model/user_model.dart';
import 'package:whatsapp_web/pages/home_page.dart';
import 'package:whatsapp_web/pages/login_signup_page.dart';
import 'package:whatsapp_web/pages/messages_page.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_web/pages/profile_page.dart';

class RoutesWebPages {
  static Route<dynamic> createRoutes(RouteSettings settingsRoute) {
    final arguments = settingsRoute.arguments;

    switch (settingsRoute.name) {
      case "/":
        return MaterialPageRoute(builder: (c) => const LoginSignUp());
      case "/login":
        return MaterialPageRoute(builder: (c) => const LoginSignUp());
      case "/home":
        return MaterialPageRoute(builder: (c) => const HomePage());
      case "/messages":
        return MaterialPageRoute(builder: (c) =>  MessagesPage(arguments as UserModel));
       case "/profile page":
        return MaterialPageRoute(builder: (c) => ProfilePage());  
      }
    return errorPageRoute();
  }

  static Route<dynamic> errorPageRoute() {
    return MaterialPageRoute(builder: (c) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Page not found'),
        ),
        body: const Center(child: Text('Page not found')),
      );
    });
  }
}

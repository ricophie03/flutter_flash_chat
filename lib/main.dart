import 'package:flutter/material.dart';
import 'package:flutter_flash_chat/screens/chat_screen.dart';
import 'package:flutter_flash_chat/screens/login_screen.dart';
import 'package:flutter_flash_chat/screens/registration_screen.dart';
import 'package:flutter_flash_chat/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // memastikan widget2 bisa dibuat
  await Firebase
      .initializeApp(); // core firebase, spy bisa pakai fitur firebase
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}

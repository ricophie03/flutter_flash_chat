import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_flash_chat/constants.dart';
import 'package:flutter_flash_chat/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation? animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller!);

    //Curved Animation
    //animation = CurvedAnimation(parent: controller!, curve: Curves.bounceIn);

    controller!.forward(); //kecil ke besar
    //controller!.reverse(from: 1.0); // besar ke kecil

    controller!.addStatusListener((status) {
      // // cek status animasi
      // if (status == AnimationStatus.completed) {
      //   // saat forward
      //   controller!.reverse(from: 1.0);
      // } else if (status == AnimationStatus.dismissed) {
      //   // saat reversed
      //   controller!.forward();
      // }
    });

    controller!.addListener(() {
      // melihat perubahan animasi
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation!.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  transitionOnUserGestures: true,
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: //animation!.value * 100,
                        60.0,
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Flash Chat',
                      textStyle: TextStyle(
                        fontSize: 50.0,
                        fontFamily: 'Horizon',
                      ),
                      colors: colorizeColors,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              color: Colors.lightBlueAccent,
              text: 'Log in',
              onPressed: () {
                // solusi jika navigator bermasalah
                SchedulerBinding.instance!.addPostFrameCallback((_) {
                  //Go to login screen.
                  Navigator.pushNamed(context, LoginScreen.id);
                });
              },
            ),
            RoundedButton(
              color: Colors.blueAccent,
              text: 'Register',
              onPressed: () {
                SchedulerBinding.instance!.addPostFrameCallback((_) {
                  //Go to registration screen.
                  Navigator.pushNamed(context, RegistrationScreen.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

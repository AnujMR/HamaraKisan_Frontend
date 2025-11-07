import 'package:flutter/material.dart';
import 'package:hamarakisan_front/colors.dart';
import 'package:hamarakisan_front/navigators.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/screens/homeScreen.dart';
import 'package:hamarakisan_front/screens/loginPage.dart';
import 'package:hamarakisan_front/screens/registrationScreen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  goToHomeScreen() async {
    final res = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).checkIfLoggedIn();

    Future.delayed(const Duration(milliseconds: 5500)).then((value) {
      pushAndRemoveUntil(context,  res
              ? Provider.of<AuthProvider>(context, listen: false).user.isRegistered ? HomeScreen() : RegistrationScreen()
              : LoginSignupScreen());
      // pushAndRemoveUntil(context, HomeScreen());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    goToHomeScreen();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logoYellow,
      body: Container(
        child: Center(
          child: Image.asset("assets/images/hamara_kisan_logo.gif", width: 300, height: 300,),
        ),
      ),
    );
  }
}
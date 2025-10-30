import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/commonFunctions.dart';
import 'package:hamarakisan_front/models/userModel.dart';
import 'package:hamarakisan_front/navigators.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/screens/homeScreen.dart';
import 'package:hamarakisan_front/screens/registrationScreen.dart';
import 'package:provider/provider.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  double dH = 0.0, dW = 0.0;

  googleSignIn() async {
    UserModel? userData = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).loginWithGoogle();
    if (userData != null) {
      showSnackbar("Logged in Successfully!", Colors.green);
      // pushAndRemoveUntil(context, HomeScreen());
      pushAndRemoveUntil(context, Provider.of<AuthProvider>(context, listen: false).user.isRegistered ? HomeScreen() : RegistrationScreen());
    } else {
      showSnackbar("Something went wrong! Try again later.", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    dH = MediaQuery.of(context).size.height;
    dW = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              color: Color(0xFFcaaa01),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: dW * 0.3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: googleSignIn,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(children: [
                            Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: SvgPicture.asset("assets/svg/google_icon.svg"),
                                ),
                            Text(
                                  "Sign in with Google",
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                          ],)
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
          Container(
            width: dW * 0.4,
            height: dH,
            child: Image.asset("assets/images/farmer_img.png", fit: BoxFit.cover,),
          )
        ],
      ),
    );
  }
}
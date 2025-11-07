import 'package:flutter/material.dart';
import 'package:hamarakisan_front/commonFunctions.dart';
import 'package:hamarakisan_front/navigators.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/screens/loginPage.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  signOut() async {
    final res = await Provider.of<AuthProvider>(context, listen: false).signOut();
    if(res){
      showSnackbar("Signed Out Successfully!", Colors.red);
      pushAndRemoveUntil(context, LoginSignupScreen());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(onPressed: signOut, child: Text("Sign out")),
    );
  }
}
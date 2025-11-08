import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/commonFunctions.dart';
import 'package:hamarakisan_front/models/userModel.dart';
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
  double dW = 0.0;
  double dH = 0.0;
  signOut() async {
    final res = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).signOut();
    if (res) {
      showSnackbar("Signed Out Successfully!", Colors.red);
      pushAndRemoveUntil(context, LoginSignupScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    dW = MediaQuery.of(context).size.width;
    dH = MediaQuery.of(context).size.height;
    UserModel user = Provider.of<AuthProvider>(context).user;
    return Container(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: dH * 0.15,
                height: dH * 0.15,
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: user.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: user.photoUrl ?? "",
                          placeholder: (context, url) => Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: dH * 0.1,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: dH * 0.1,
                          ),
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.grey, size: 30),
              ),
              SizedBox(height: 20),
              Text(
                "${user.firstName} ${user.lastName}",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "${user.district}, ${user.state}",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: signOut, child: Text("Sign out")),
            ],
          ),
          Column(),
        ],
      ),
    );
  }
}

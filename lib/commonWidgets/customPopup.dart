import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/navigators.dart';


Future<void> customPopUpBox(BuildContext context, {required String title,required Widget child, required Function onYes, String yesBtnText = "Yes", String noBtnText = "No"}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        backgroundColor: Colors.white,
        content: child,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(noBtnText, style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigator.of(context).pop(true);
              onYes();
              pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(yesBtnText, style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  // if (result == true) {
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text('User pressed YES')));
  // } else if (result == false) {
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text('User pressed NO')));
  // }
}

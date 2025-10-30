import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


Future<void> showYesNoDialog(BuildContext context, {required String mandiName, required Function onYes}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Action'),
        content: Row(
          children: [
            Text('Are you sure you want to pin ', style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color:Colors.black,
                ),
              ),
            ),
            Text(mandiName, style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Text(' mandi?', style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('No', style: GoogleFonts.poppins(
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Yes', style: GoogleFonts.poppins(
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

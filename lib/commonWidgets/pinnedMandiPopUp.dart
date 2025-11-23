import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/models/pinnedMandiModel.dart';
import 'package:hamarakisan_front/providers/homeProvider.dart';
import 'package:provider/provider.dart';

void showPinnedMandiDetailsPopup({required BuildContext context, required PinnedMandi mandi, required Widget child}) {
  double dW = MediaQuery.of(context).size.width;
  double dH = MediaQuery.of(context).size.height;
showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Container(
                  width: dW * 0.6,
                  height: dH * 0.7,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          mandi.marketName,
                          overflow: TextOverflow.ellipsis,
                          style:  GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                      Row(children: [
                        Column(
                          children: [
                            Text(
                              mandi.state,
                              style: GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 18, color: Colors.black)),
                            ),
                          ],
                        )
                      ],),
                      SizedBox(height: 20),
                      child
                    ],
                  ),
                ),

                // Close button
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/commonFunctions.dart';
import 'package:hamarakisan_front/commonWidgets/customButton.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/providers/plantDisseasePredProvider.dart';
import 'package:provider/provider.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  bool isPredicting = false;
  bool isGettingRemedy = false;
  String PredictedDisease = "--";
  bool isDiseased = false;
  String remedy = "";
  double dw = 0.0;
  double dh = 0.0;
  bool isHovered = false;
  Uint8List? selectedImageBytes;

  Future<void> PickAndUploadImage() async {
    // Step 1: Pick file
    final result = await pickImage();
    if (result == null) return;

    setState(() {
      isPredicting = true;
      PredictedDisease = "--";
      remedy = "";
    });
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    final fileBytes = result.files.first.bytes;
    final name = result.files.first.name;

    setState(() {
      selectedImageBytes = fileBytes;
    });

    var response =
        await Provider.of<PlantDiseasePredProvider>(
          context,
          listen: false,
        ).uploadPlantImage(
          fileBytes: fileBytes,
          fileName: name,
          idToken: user.idToken,
        );

    setState(() {
      isPredicting = false;
    });
    if (response["success"]) {
      // print(response);
      setState(() {
        PredictedDisease = response["data"]["disease"];
        isDiseased = response["data"]["isDiseased"];
      });
      if (response["data"]["isDiseased"]) {
        setState(() {
          isGettingRemedy = true;
        });
        final remedyRes = await Provider.of<PlantDiseasePredProvider>(
          context,
          listen: false,
        ).getRemedy(disease: PredictedDisease, idToken: user.idToken);
        if (remedyRes["success"]) {
          setState(() {
            remedy = remedyRes["data"];
          });
        }
        setState(() {
          isGettingRemedy = false;
        });
      }else{
        setState(() {
          remedy = "Your plant looks healthy! No treatment needed.";
          if(PredictedDisease == "Background_without_leaves"){
            remedy = "The uploaded image seems to be of a background without leaves. Please upload a clear image of the plant leaf for accurate disease prediction.";
          }
        });
      }
    } else {
      print("Error: ${response["error"]}");
      // setState(() {
      //   prediction = "Error: ${response.statusCode}";
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    dw = MediaQuery.sizeOf(context).width;
    dh = MediaQuery.sizeOf(context).height;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    border: Border.all(color: Colors.blue, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 5),
                      Text(
                        "Click a photo of a leaf with a plain background.\nEnsure good lighting for accurate results.",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                selectedImageBytes != null
                    ? Container(
                        width: dw * 0.3,
                        height: dh * 0.5,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            SizedBox(
                              width: dw * 0.3,
                              height: dh * 0.5,
                              child: Image.memory(
                                selectedImageBytes!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImageBytes = null;
                                    remedy = "";
                                    PredictedDisease = "--";
                                  });
                                },
                                child: Text(
                                  "Reset",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          PickAndUploadImage();
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) {
                            setState(() {
                              isHovered = true;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              isHovered = false;
                            });
                          },
                          child: Container(
                            width: dw * 0.3,
                            height: dh * 0.5,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isHovered
                                  ? Colors.grey.shade100
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_circle_up_rounded,
                                  size: dw * 0.08,
                                  color: isHovered ? Colors.blue.shade200 : Colors.grey.shade300,
                                ),
                                Text(
                                  "Upload a photo\n(JPG, JPEG, PNG)",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: isHovered
                                          ? Colors.blue.shade200
                                          : Colors.grey.shade400,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                // CustomButton(onClick: (){}, text: "Upload"),
                SizedBox(height: 30),
                isPredicting
                    ? Text(
                        "Analyzing the image...",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 1),
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Predicted Disease",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              PredictedDisease.replaceAll(RegExp('_+'), ' '),
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: dh * 0.8,
            color: Colors.grey.shade300,
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "💊 Treatment",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                width: dw * 0.4,
                height: dh * 0.7,
                child: isGettingRemedy
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/loader.gif", width: 90),
                            Text(
                              "Finding Remedy...",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : remedy.isNotEmpty
                    ? Container(
                        width: dw * 0.4,
                        height: dh * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(15),
                          child:
                        MarkdownBody(
                            data: remedy,
                            styleSheet:
                                MarkdownStyleSheet.fromTheme(
                                  Theme.of(context),
                                ).copyWith(
                                  p: const TextStyle(fontSize: 16),
                                  listBullet: const TextStyle(fontSize: 18),
                                ),
                          ),),
                      )
                    : Center(
                        child: Text(
                          "Learn about how to treat your plant",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

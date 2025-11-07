import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

getTimePeriod(double time) {
  if (time > 12) {
    return 'pm';
  } else {
    return 'am';
  }
}

bool isSameDay(DateTime date1, DateTime date2) =>
    date1.day == date2.day &&
    date1.month == date2.month &&
    date1.year == date2.year;

Map sortMap(Map map) {
  Map sortedMap = {};
  var gg = map.keys.toList()
    ..sort((a, b) =>
        num.parse(a.split('-')[0]).compareTo(num.parse(b.split('-')[0])));

  LinkedHashMap lSMap =
      new LinkedHashMap.fromIterable(gg, key: (k) => k, value: (k) => map[k]);
  sortedMap = lSMap;
  return sortedMap;
}

String amountText(double amount) {
  String amountString = amount.toStringAsFixed(2);

  if (amountString.split('.')[1][1] == '0') {
    amountString =
        amountString.split('.')[0] + '.' + amountString.split('.')[1][0];
    if (amountString.split('.')[1][0] == '0') {
      amountString = amountString.split('.')[0];
    }
  }
  return amountString;
}

String regExpText(String text) {
  return text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
}

String convertAmountString(double amount) {
  var strToReturn;
  String aS = amount.round().toStringAsFixed(0);
  if (amount < 100000) {
    return regExpText(aS);
  }
  final list = aS.split('.');
  aS = list[0];
  final length = aS.length;
  if (length < 6) {
    strToReturn = amountText(amount);
  } else if (length == 6) {
    String trail = aS.substring(length - 5, length);
    String lead = aS.substring(0, length - 5);
    if (trail[0] != '0') lead = lead + '.${trail[0]}';
    strToReturn = lead + 'L';
  } else if (length == 7) {
    String trail = aS.substring(length - 6, length);
    String lead = aS.substring(0, length - 6) + '0';
    if (trail[0] != '0') lead = lead + '.${trail[0]}';
    strToReturn = lead + 'L';
  } else if (length > 7) {
    String trail = aS.substring(length - 7, length);
    String lead = aS.substring(0, length - 7);
    if (trail[0] != '0') lead = lead + '.${trail[0]}';
    strToReturn = lead + 'Cr';
  }
  return strToReturn;
}

getTimeDifferenceText(DateTime date1, DateTime date2) {
  final Duration differnce = date2.difference(date1);

  if (differnce.inDays != 0)
    return '${differnce.inDays} ${differnce.inDays > 1 ? 'days' : 'day'}';

  if (differnce.inHours != 0) {
    return '${differnce.inHours} ${differnce.inHours > 1 ? 'hours' : 'hour'}';
  }

  if (differnce.inMinutes != 0) {
    return '${differnce.inMinutes} ${differnce.inMinutes > 1 ? 'minutes' : 'minute'}';
  }

  if (differnce.inSeconds != 0) {
    return '${differnce.inSeconds} ${differnce.inSeconds > 1 ? 'seconds' : 'second'}';
  }
}

showSnackbar(String msg, Color color, [int duration = 2]) {
  ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
    content: Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Text(msg, softWrap: true),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: Duration(seconds: duration),
    margin: EdgeInsets.only(
      // bottom: MediaQuery.of(context).size.height * 0.77,
      bottom: 40,
      right: 20,
      left: 20,
    ),
  ));
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  if (image != null) {
    return image;
  }
  return null;
}


String getInitials(String inputString) {
  String toReturn = '';
  final List<String> sep = inputString.split(' ');
  for (String s in sep) {
    if (toReturn.length < 2) {
      toReturn += s != '' ? s[0] : '';
    }
  }
  return toReturn;
}

// navigateTo(LatLng coords) async {
//   var uri;
//   if (Platform.isIOS) {
//     uri = Uri.parse(
//         'comgooglemaps://?saddr=&daddr=${coords.latitude},${coords.longitude}&directionsmode=driving');
//   } else {
//     uri = Uri.parse(
//         "google.navigation:q=${coords.latitude},${coords.longitude}&mode=d");
//   }
//   // if (await canLaunch(uri.toString())) {
//   await launch(uri.toString());
//   // } else {
//   //   throw 'Could not launch ${uri.toString()}';
//   // }
// }

// void callLaunch(mobileNumber) async {
//   // if (await canLaunch(command)) {
//   await launch('tel:$mobileNumber');
//   // } else {
//   //   print('could not launch $command');
//   // }
// }

Future<File?> downloadFile(String url, String? fileName) async {
  final appStorage = await getApplicationDocumentsDirectory();
  final file = File('${appStorage.path}/$fileName');
  //
  try {
    final response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: Duration.zero,
      ),
    );
    //
    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
    //
    return file;
  } catch (e) {
    return null;
  }
}

// openDocument(String url) async {
//   if (await canLaunch(url))
//     await launch(url);
//   else
//     showSnackbar('Could not open file', Colors.red);
// }

// openLocalDocument(String path) {
//   try {
//     OpenFile.open(path);
//   } catch (e) {
//     print(e);
//     showSnackbar('Unable to view', Colors.red);
//   }
// }



String formatTime(Duration duration) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes % 60;
  int seconds = duration.inSeconds % 60;

  List<String> parts = [];
  if (hours > 0) parts.add('${hours}h');
  if (minutes > 0 || hours > 0)
    parts.add('${minutes}m'); // Show minutes if hours exist
  parts.add('${seconds}s'); // Always show seconds

  return parts.join(' ');
}

hideKeyBoard(BuildContext context) =>
    FocusScope.of(context).requestFocus(FocusNode());

// void galleryOrCamBottomSheet(Function pickMedia,
//     {required double width, required BuildContext context}) {
//   hideKeyBoard(context);
//   showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(left: width * 0.08, bottom: width * 0.08),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               const Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(bottom: 20, top: 20),
//                     child: Text(
//                       "Pick Media",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Color.fromRGBO(41, 49, 49, 1),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 25),
//                 child: Row(
//                   children: [
// //                       InkWell(
// //                         onTap: () {},
// //                         child: BottomSheetContent(
// //                           svgColor: Color.fromRGBO(218, 11, 11, 1),
// // // svgImage: "assets/svg_images/delete.svg",
// //                           icon: Icon(Icons.delete),
// //                           title: "Remove",
// //                           title2: " Photo",
// //                           func: () {
// //                             setState(() {
// //                               remove = true;
// //                               pickedImage = '';
// //                               userDetail.avatar = '';
// //                             });
// //                             Navigator.of(context).pop();
// //                           },
// //                         ),
// //                       ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 0),
//                       child: BottomSheetContent(
//                         svgColor: const Color.fromRGBO(175, 17, 150, 1),
//                         icon: Icon(Icons.image,
//                             color: Color.fromARGB(255, 156, 42, 255)),
//                         title: "Gallery",
//                         title2: "",
//                         func: () {
//                           pickMedia(ImageSource.gallery);
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: width * 0.06),
//                       child: BottomSheetContent(
//                         svgColor: const Color.fromRGBO(1, 82, 186, 1),
// // svgImage: "assets/svg_images/delete.svg",
//                         icon: Icon(Icons.camera_alt,
//                             color: Color.fromARGB(255, 156, 42, 255)),
//                         title: "Camera",
//                         title2: "",
//                         func: () {
//                           pickMedia(ImageSource.camera);
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       });
// }

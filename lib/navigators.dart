import 'package:flutter/material.dart';

Future<dynamic> push(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));

Future<dynamic> pushReplacement(BuildContext context, Widget screen) =>
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => screen));

Future<dynamic> pushAndRemoveUntil(BuildContext context, Widget screen) =>
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => screen),
        (Route<dynamic> route) => false);

pop(context) => Navigator.pop(context);

dataPop(context, data) => Navigator.of(context).pop(data);

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/colors.dart';
import 'package:hamarakisan_front/commonFunctions.dart';
import 'package:hamarakisan_front/models/dashboardData.dart';
import 'package:hamarakisan_front/models/userModel.dart';
import 'package:hamarakisan_front/navigators.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/screens/loginPage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double dW = 0.0;
  double dH = 0.0;
  int currentIndex = 0;
  int rowsPerPage = 10;
  List<DashboardData> tableDataToDisplay = [];

  nextPage() {
    if ((currentIndex + rowsPerPage) <
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).dashboardData!.length) {
      currentIndex += rowsPerPage;
      setState(() {
        tableDataToDisplay = Provider.of<AuthProvider>(context, listen: false)
            .dashboardData
            .sublist(
              currentIndex,
              min(
                currentIndex + rowsPerPage,
                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).dashboardData.length,
              ),
            );
      });
    }
  }

  backPage() {
    if (currentIndex - rowsPerPage >= 0) {
      currentIndex -= rowsPerPage;
      setState(() {
        tableDataToDisplay = Provider.of<AuthProvider>(context, listen: false)
            .dashboardData
            .sublist(
              currentIndex,
              min(
                currentIndex + rowsPerPage,
                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).dashboardData.length,
              ),
            );
      });
    }
  }

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
  void initState() {
    // TODO: implement initState
    super.initState();

    tableDataToDisplay = Provider.of<AuthProvider>(context, listen: false)
        .dashboardData
        .sublist(
          currentIndex,
          min(
            currentIndex + rowsPerPage,
            Provider.of<AuthProvider>(context, listen: false).dashboardData.length,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    dW = MediaQuery.of(context).size.width;
    dH = MediaQuery.of(context).size.height;
    UserModel user = Provider.of<AuthProvider>(context).user;
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
          Container(
            width: 1,
            height: dH * 0.6,
            color: Colors.grey.shade300,
            margin: EdgeInsets.only(left: 20, right: 20),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sales Log",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: dW * 0.5,
                height: dH * 0.6,
                child: Column(
                  children: [
                    DashboardTableRow(
                      data: DashboardData(
                        id: "dummy",
                        commodity: "Commodity",
                        quantity: 0,
                        price: 0.0,
                        total: 0.0,
                        date: DateTime.now(),
                      ),
                      bgColor: primaryOrange,
                      isHeader: true,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    Column(
                      children: [
                        tableDataToDisplay.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "No data available",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  ...tableDataToDisplay.map((data) {
                                    int index = tableDataToDisplay.indexOf(
                                      data,
                                    );
                                    return DashboardTableRow(
                                      data: data,
                                      bgColor: index % 2 == 0
                                          ? Colors.white
                                          : Colors.grey.shade100,
                                    );
                                  }).toList(),
                                ],
                              ),

                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                backPage();
                              },
                              child: Icon(Icons.arrow_back_ios_new, size: 15),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(10),
                                backgroundColor: currentIndex == 0
                                    ? const Color.fromARGB(255, 221, 221, 221)
                                    : const Color.fromARGB(
                                        255,
                                        0,
                                        167,
                                        33,
                                      ), // <-- Button color
                                foregroundColor:
                                    Colors.white, // <-- Splash color
                              ),
                            ),
                            Text(
                              "Page ${(currentIndex / rowsPerPage).ceil() + 1}/${(Provider.of<AuthProvider>(context).dashboardData.length / rowsPerPage).ceil()}",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                nextPage();
                              },
                              child: Icon(Icons.arrow_forward_ios, size: 15),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(10),
                                backgroundColor:
                                    (currentIndex + rowsPerPage) >=
                                        Provider.of<AuthProvider>(
                                          context,
                                          listen: false,
                                        ).dashboardData.length
                                    ? const Color.fromARGB(255, 221, 221, 221)
                                    : const Color.fromARGB(255, 0, 167, 33),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardTableRow extends StatefulWidget {
  const DashboardTableRow({
    super.key,
    required this.data,
    required this.bgColor,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w400,
    this.isHeader = false,
  });

  final DashboardData data;
  final Color bgColor;
  final bool isHeader;
  final int fontSize;
  final FontWeight fontWeight;

  @override
  State<DashboardTableRow> createState() => _DashboardTableRowState();
}

class _DashboardTableRowState extends State<DashboardTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: !widget.isHeader && _isHovered
              ? Colors.grey.shade100  
              : widget.bgColor,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          borderRadius: widget.isHeader
              ? BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )
              : null,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.isHeader ? "Commodity" : widget.data.commodity,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isHeader ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.isHeader
                      ? "Quantity"
                      : widget.data.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isHeader ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.isHeader
                      ? "Price"
                      : widget.data.price.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isHeader ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.isHeader
                      ? "Total"
                      : widget.data.total.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isHeader ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.isHeader
                      ? "Date"
                      : DateFormat('dd-MM-yyyy').format(widget.data.date),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isHeader ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

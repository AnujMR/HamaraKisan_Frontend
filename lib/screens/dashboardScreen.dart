import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/colors.dart';
import 'package:hamarakisan_front/commonFunctions.dart';
import 'package:hamarakisan_front/commonWidgets/customPopup.dart';
import 'package:hamarakisan_front/models/dashboardData.dart';
import 'package:hamarakisan_front/models/userModel.dart';
import 'package:hamarakisan_front/navigators.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/screens/loginPage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  bool isAddNewRecordHovered = false;
  bool isSubmitting = false;
  List<DashboardData> dashboardData = [];
  List<DashboardData> tableDataToDisplay = [];
  bool isLoadingGraphs = false;
  List<PieData> pieChartData = [];

  TextEditingController commodityController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  FocusNode commodityNode = FocusNode();
  FocusNode quantityNode = FocusNode();
  FocusNode priceNode = FocusNode();
  DateTime? selectedDate;
  final _formKey = GlobalKey<FormState>();

  showMaterialDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(
        DateTime.now().year - 72,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedDate = date;
          dateController.text = DateFormat('dd-MMM-yyyy').format(selectedDate!);
        });
      }
    });
  }

  textField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType textInputType,
    TextCapitalization? textCapitalization,
    required FocusNode focusNode,
    required String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      // inputFormatters: [
      //   FilteringTextInputFormatter.digitsOnly
      // ],
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      decoration: InputDecoration(
        hintStyle: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.grey,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        hintText: hintText,
        counterText: "",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: Colors.black,
      focusNode: focusNode,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      controller: controller,
      keyboardType: textInputType,
      maxLines: null,
      onChanged: onChanged,
      validator: validator,
    );
  }

  selectDateField() {
    return Container(
      width: dW * 0.12,
      child: InkWell(
        splashColor: Colors.white,
        onTap: () {
          showMaterialDatePicker();
        },
        child: IgnorePointer(
          child: TextFormField(
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            decoration: InputDecoration(
              hintStyle: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              hintText: "Date",
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade200),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryGreen),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade200),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade200),
              ),

              suffixIcon: Icon(
                Icons.calendar_today,
                size: 18,
                color: selectedDate != null ? Colors.black : Colors.black45,
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: Colors.black,
            textCapitalization: TextCapitalization.words,
            controller: dateController,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              // widget.setExitValue();
            },
            // validator: (value) {
            //   if (value!.isEmpty) {
            //     return 'Please select date';
            //   }
            // },
          ),
        ),
      ),
    );
  }

  handleSubmit() async{
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });
      final reqBody = {
        "commodity": commodityController.text.trim(),
        "price": double.parse(priceController.text.trim()),
        "quantity": int.parse(quantityController.text.trim()),
        "date": selectedDate!.toIso8601String(),
      };
      final res = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).addRecordInDashboard(reqBody: reqBody, idToken: Provider.of<AuthProvider>(context, listen: false).user.idToken, uid: Provider.of<AuthProvider>(context, listen: false).user.id);


      if(res["success"]){
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).getDashboardData();
        showSnackbar("Record added successfully", Colors.green);
        getDashboardGraphs();
      }else{
        showSnackbar("Error while adding the record. Please try again later.", Colors.red);
      }
    }
  }

  nextPage() {
    if ((currentIndex + rowsPerPage) <
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).dashboardData!.length) {
      currentIndex += rowsPerPage;
      setState(() {
        tableDataToDisplay = dashboardData
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
        tableDataToDisplay = dashboardData
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

  addRecordForm() {
    commodityController.clear();
    priceController.clear();
    quantityController.clear();
    dateController.clear();
    selectedDate = null;

    return Container(
      width: dW * 0.3,
      height: dH * 0.3,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: dW * 0.14,
                    child: textField(
                    controller: commodityController,
                    hintText: "Commodity",
                    textInputType: TextInputType.text,
                    focusNode: commodityNode,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter commodity name";
                      }
                    },
                  ),
                  ),
                  Container(
                    width: dW * 0.14,
                    child: textField(
                    controller: priceController,
                    hintText: "Price",
                    textInputType: TextInputType.number,
                    focusNode: priceNode,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter the price";
                      }
                    },
                  ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: dW * 0.14,
                    child: textField(
                    controller: quantityController,
                    hintText: "Quantity (In quintals)",
                    textInputType: TextInputType.number,
                    focusNode: quantityNode,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter the quantity";
                      }
                    },
                  ),
                  ),
                  Container(
                    width: dW * 0.14,
                    child: selectDateField(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  deleteFromTable(String id){
    tableDataToDisplay.removeWhere((element) => element.id == id);
    setState(() {});
  }


  getDashboardGraphs() async {
    setState(() {
      isLoadingGraphs = true;
    });
    Map<String, dynamic> reqBody = {};
    final res = await Provider.of<AuthProvider>(context, listen: false)
        .getDashboardGraphs(
          reqBody,
          Provider.of<AuthProvider>(context, listen: false).user.id,
          Provider.of<AuthProvider>(context, listen: false).user.idToken,
        );
    setState(() {
      // priceTrend = Provider.of<HomeProvider>(context, listen: false).priceTrend;
      // topDistricts = Provider.of<HomeProvider>(
      //   context,
      //   listen: false,
      // ).topDistricts;
      isLoadingGraphs = false;
    });
  }

  pieChart(){
    return SizedBox(
      width: dW * 0.25,
      height: dH * 0.4,
      child: SfCircularChart(
        title: ChartTitle(text: 'Crop Distribution'),
        legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      
        // Enables interaction
        enableMultiSelection: true,
        selectionGesture: ActivationMode.singleTap,
      
        tooltipBehavior: TooltipBehavior(enable: true),
      
        series: <CircularSeries>[
          PieSeries<PieData, String>(
            dataSource: pieChartData,
            xValueMapper: (PieData item, _) => item.category,
            yValueMapper: (PieData item, _) => item.value,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
            ),
            explode: true,
            explodeIndex: 0,
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDashboardGraphs();
    dashboardData = Provider.of<AuthProvider>(context, listen: false).dashboardData;
    tableDataToDisplay = dashboardData
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
  }

  @override
  Widget build(BuildContext context) {
    dW = MediaQuery.of(context).size.width;
    dH = MediaQuery.of(context).size.height;
    UserModel user = Provider.of<AuthProvider>(context).user;
    dashboardData =
        Provider.of<AuthProvider>(context).dashboardData;
    pieChartData = Provider.of<AuthProvider>(context).pieChartData;
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${user.firstName} ${user.lastName}",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${user.district}, ${user.state}",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: signOut, child: Text("Sign out")),
            ],
          ),
          Container(
            width: 1,
            height: dH * 0.9,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: dW * 0.45,
                    // height: dH * 0.6,
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
                          deleteRecord: deleteFromTable,
                          getDashboardGraphs: getDashboardGraphs,
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
                                          deleteRecord: deleteFromTable,
                                          bgColor: index % 2 == 0
                                              ? Colors.white
                                              : Colors.grey.shade100,
                                              getDashboardGraphs:
                                              getDashboardGraphs,
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
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 15,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(10),
                                    backgroundColor: currentIndex == 0
                                        ? const Color.fromARGB(
                                            255,
                                            221,
                                            221,
                                            221,
                                          )
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
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(10),
                                    backgroundColor:
                                        (currentIndex + rowsPerPage) >=
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).dashboardData.length
                                        ? const Color.fromARGB(
                                            255,
                                            221,
                                            221,
                                            221,
                                          )
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
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          customPopUpBox(
                            context,
                            title: "Fill the details",
                            child: addRecordForm(),
                            onYes: ()async{
                              await handleSubmit();
                            setState(() {
                                isSubmitting = false;
                              });
                            },
                            yesBtnText: "Add",
                            noBtnText: "Cancel",
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) {
                            setState(() {
                              isAddNewRecordHovered = true;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              isAddNewRecordHovered = false;
                            });
                          },
                          child: Container(
                            width: dW * 0.1,
                            height: dW * 0.03,
                            decoration: BoxDecoration(
                              color: isAddNewRecordHovered
                                  ? const Color.fromARGB(255, 59, 137, 185)
                                  : const Color.fromARGB(255, 92, 181, 222),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                child: isSubmitting ? Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: CircularProgressIndicator(color: Colors.white),
                                ) : Text(
                                  "Add a New Record",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      pieChart()
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 50,
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
    required this.deleteRecord,
    required this.getDashboardGraphs,
  });

  final DashboardData data;
  final Color bgColor;
  final bool isHeader;
  final int fontSize;
  final FontWeight fontWeight;
  final Function(String id) deleteRecord;
  final Function getDashboardGraphs;

  @override
  State<DashboardTableRow> createState() => _DashboardTableRowState();
}

class _DashboardTableRowState extends State<DashboardTableRow> {
  bool _isHovered = false;

    deleteRecord() async {
      widget.deleteRecord(widget.data.id);
      final reqBody = {
        "index": widget.data.id,
      };
      final res = await Provider.of<AuthProvider>(context, listen: false)
          .deleteRecordInDashboard(
            reqBody: reqBody,
            idToken: Provider.of<AuthProvider>(
              context,
              listen: false,
            ).user.idToken,
            uid: Provider.of<AuthProvider>(context, listen: false).user.id,
          );

      if (res["success"]) {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).getDashboardData();
        widget.getDashboardGraphs();
        showSnackbar("Record deleted successfully", Colors.black);
      } else {
        showSnackbar(
          "Error while deleting the record. Please try again later.",
          Colors.red,
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: !widget.isHeader && _isHovered
              ? const Color.fromARGB(255, 255, 250, 196)
              : widget.bgColor,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
            right: BorderSide(color: Colors.grey.shade300, width: 1),
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
                      ? "Quantity (Q)"
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
                      : "₹ ${widget.data.price.toStringAsFixed(2)}",
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
                      : "₹ ${widget.data.total.toStringAsFixed(2)}",
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
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child:  widget.isHeader
                      ? Text("Action",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isHeader ? Colors.white : Colors.black,
                    ),
                  ),
                ) : IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: deleteRecord, icon: Icon(Icons.delete, color: Colors.red, size: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieData {
  final String category;
  final num value;

  PieData(this.category, this.value);
}

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/colors.dart';
import 'package:hamarakisan_front/commonFunctions.dart';
import 'package:hamarakisan_front/commonWidgets/barChart.dart';
import 'package:hamarakisan_front/commonWidgets/customPopup.dart';
import 'package:hamarakisan_front/commonWidgets/lineChart.dart';
import 'package:hamarakisan_front/commonWidgets/pinnedMandisComparison.dart';
import 'package:hamarakisan_front/models/pinnedMandiModel.dart';
import 'package:hamarakisan_front/models/userModel.dart';
import 'package:hamarakisan_front/navigators.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/providers/homeProvider.dart';
import 'package:hamarakisan_front/providers/pinnedMandiProvider.dart';
import 'package:hamarakisan_front/screens/dashboardScreen.dart';
import 'package:hamarakisan_front/screens/predictionScreen.dart';
import 'package:hamarakisan_front/store.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double dH = 0.0, dW = 0.0;
  bool isLoading = false;
  bool isLoadingGraphs = false;
  final ScrollController _scrollController = ScrollController();

  // Home page data
  List<Map<String, dynamic>> tableDataToDisplay = [];
  List<PinnedMandi> pinnedMandis = [];

  // Graph data
  Map<String, Map<String, dynamic>> priceTrend = {};
  Map<String, dynamic> topDistricts = {};

  int currentIndex = 0;
  int rowsPerPage = 10;

  String? selectedState;
  String? selectedDistrict;
  String? selectedCommodity;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  late TooltipBehavior _tooltipBehavior;

  showMaterialDatePicker(bool isStartDate) {
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
          if (isStartDate) {
            selectedStartDate = date;
            startDateController.text = DateFormat(
              'dd-MMM-yyyy',
            ).format(selectedStartDate!);
          } else {
            selectedEndDate = date;
            endDateController.text = DateFormat(
              'dd-MMM-yyyy',
            ).format(selectedEndDate!);
          }
        });
      }
    });
  }

  selectDateField(bool isStartDate) {
    return Container(
      width: dW * 0.12,
      child: InkWell(
        splashColor: Colors.white,
        onTap: () {
          showMaterialDatePicker(isStartDate);
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
              hintText: isStartDate ? "Start Date" : "End Date",
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryGreen),
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
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryGreen),
              ),

              suffixIcon: Icon(
                Icons.calendar_today,
                size: 18,
                color: isStartDate
                    ? selectedStartDate != null
                          ? Colors.black
                          : Colors.black45
                    : selectedEndDate != null
                    ? Colors.black
                    : Colors.black45,
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: Colors.black,
            textCapitalization: TextCapitalization.words,
            controller: isStartDate ? startDateController : endDateController,
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

  customDropDownTextField({
    required Function(String?)? onChanged,
    String? Function(String?)? validator,
    required List items,
    String hintText = "",
    String? selectedItem,
  }) {
    return SizedBox(
      width: dW * 0.1,
      // height: dW * 0.12,
      child: DropdownSearch<String>(
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryGreen),
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
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryGreen),
            ),
          ),
        ),

        popupProps: PopupProps.menu(
          fit: FlexFit.loose,
          showSearchBox: true,
          showSelectedItems: true,
          searchFieldProps: TextFieldProps(
            cursorColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
        items: (filter, infiniteScrollProps) => [...items],
        dropdownBuilder: (context, selectedItem) {
          return selectedItem != null
              ? Text(
                  selectedItem,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                )
              : Text(
                  hintText,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                );
        },
        onChanged: onChanged,
        selectedItem: selectedItem,
        validator: validator,
      ),
    );
  }

  getTableData(
    String state,
    String? dist,
    String comm,
    DateTime startDate,
    DateTime endDate,
  ) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> reqBody = {
      "state": state,
      "district": dist == null || dist == "All Districts" ? "--Select--" : dist,
      "commodity_name": comm,
      "startDate": DateFormat('dd-MMM-yyyy').format(startDate),
      "endDate": DateFormat('dd-MMM-yyyy').format(endDate),
    };
    print(DateFormat('dd-MMM-yyyy').format(startDate));
    await Provider.of<HomeProvider>(
      context,
      listen: false,
    ).getTableData(reqBody, Provider.of<AuthProvider>(context, listen: false).user.idToken);
    setState(() {
      isLoading = false;
      tableDataToDisplay = Provider.of<HomeProvider>(context, listen: false)
          .tableData
          .sublist(
            currentIndex,
            min(
              currentIndex + rowsPerPage,
              Provider.of<HomeProvider>(
                context,
                listen: false,
              ).tableData.length,
            ),
          );
    });
  }

  getHomePageGraphs(
    String state,
    String? dist,
    String comm,
    DateTime startDate,
    DateTime endDate,
  ) async {
    setState(() {
      isLoadingGraphs = true;
    });
    Map<String, dynamic> reqBody = {
      "state": state,
      // "district": dist == null || dist == "All Districts" ? "--Select--" : dist,
      "commodity_name": comm,
      "startDate": DateFormat('dd-MMM-yyyy').format(startDate),
      "endDate": DateFormat('dd-MMM-yyyy').format(endDate),
    };
    final res = await Provider.of<HomeProvider>(context, listen: false)
        .getHomePageGraphs(
          reqBody,
          Provider.of<AuthProvider>(context, listen: false).user.id,
          Provider.of<AuthProvider>(context, listen: false).user.idToken,
        );
    setState(() {
      priceTrend = Provider.of<HomeProvider>(context, listen: false).priceTrend;
      topDistricts = Provider.of<HomeProvider>(
        context,
        listen: false,
      ).topDistricts;
      isLoadingGraphs = false;
    });
  }

  nextPage() {
    if ((currentIndex + rowsPerPage) <
        Provider.of<HomeProvider>(context, listen: false).tableData.length) {
      currentIndex += rowsPerPage;
      setState(() {
        tableDataToDisplay = Provider.of<HomeProvider>(context, listen: false)
            .tableData
            .sublist(
              currentIndex,
              min(
                currentIndex + rowsPerPage,
                Provider.of<HomeProvider>(
                  context,
                  listen: false,
                ).tableData.length,
              ),
            );
      });
    }
  }

  backPage() {
    if (currentIndex - rowsPerPage >= 0) {
      currentIndex -= rowsPerPage;
      setState(() {
        tableDataToDisplay = Provider.of<HomeProvider>(context, listen: false)
            .tableData
            .sublist(
              currentIndex,
              min(
                currentIndex + rowsPerPage,
                Provider.of<HomeProvider>(
                  context,
                  listen: false,
                ).tableData.length,
              ),
            );
      });
    }
  }

  bool areAllFiltersSelected() {
    return selectedState != null &&
        selectedCommodity != null &&
        selectedStartDate != null &&
        selectedEndDate != null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getTableData();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<AuthProvider>(context, listen: false).user;
    dH = MediaQuery.of(context).size.height;
    dW = MediaQuery.of(context).size.width;
    pinnedMandis = Provider.of<AuthProvider>(context).user.pinnedMandis;
    final List<CartesianSeries> seriesList = priceTrend.entries.map((entry) {
      final districtName = entry.key;
      final Map<String, dynamic> prices = entry.value;

      final List<PriceTrendData> dataPoints =
          prices.entries
              .map((e) => PriceTrendData(e.key, (e.value as num).toDouble()))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date)); // sort by date

      return LineSeries<PriceTrendData, DateTime>(
        name: districtName,
        dataSource: dataPoints,
        xValueMapper: (PriceTrendData data, _) => data.date,
        yValueMapper: (PriceTrendData data, _) => data.price,
        markerSettings: const MarkerSettings(isVisible: true),
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      );
    }).toList();

    final List<TopDistrictData> chartData = topDistricts.entries
        .map((e) => TopDistrictData(e.key, e.value))
        .toList();

    priceTrend = Provider.of<HomeProvider>(context).priceTrend;
    topDistricts = Provider.of<HomeProvider>(context).topDistricts;
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            HomeTopBar(user: user),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: dW * 0.02),
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    if (Provider.of<HomeProvider>(context).selectedPage == 1)
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Pinned Mandis",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: dW,
                            child: pinnedMandis.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      bottom: 15,
                                    ),
                                    child: Text(
                                      "You don't have any pinned mandis",
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  )
                                : Scrollbar(
                                    controller: _scrollController,
                                    thumbVisibility: true, // Always show thumb
                                    interactive: true,
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10),
                                          ...pinnedMandis.map(
                                            (mandi) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 10.0,
                                              ),
                                              child: PinnedMandiCard(
                                                pinnedMandi: mandi,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 20),
                          if(Provider.of<HomeProvider>(context).pinnedMandiComparison.isNotEmpty)
                          PinnedMandisComparison(),
                          SizedBox(height: 20),
                          Divider(thickness: 0.5, color: Colors.grey),
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: dW * 0.7,
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              customDropDownTextField(
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectedState = val;
                                                    selectedDistrict = null;
                                                  });
                                                },
                                                items: [...stateDistrictMap.keys],
                                                hintText: "State",
                                                selectedItem: selectedState,
                                              ),
                                              SizedBox(width: 10),
                                              customDropDownTextField(
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectedDistrict = val;
                                                  });
                                                },
                                                items: selectedState == null
                                                    ? []
                                                    : [
                                                        "All Districts",
                                                        ...stateDistrictMap[selectedState],
                                                      ],
                                                hintText: "District",
                                                selectedItem: selectedDistrict,
                                              ),
                                              SizedBox(width: 10),
                                              customDropDownTextField(
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectedCommodity = val;
                                                  });
                                                },
                                                items: selectedState == null
                                                    ? []
                                                    : [...commodity_list],
                                                hintText: "Commodity",
                                                selectedItem: selectedCommodity,
                                              ),
                                              SizedBox(width: 10),
                                              selectDateField(true),
                                              SizedBox(width: 10),
                                              selectDateField(false),
                                              SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (!areAllFiltersSelected()) {
                                                    showSnackbar(
                                                      "Please select State, Commodity, Start Date and End Date",
                                                      Colors.red,
                                                    );
                                                    return;
                                                  }
                                                  getTableData(
                                                    selectedState!,
                                                    selectedDistrict,
                                                    selectedCommodity!,
                                                    selectedStartDate!,
                                                    selectedEndDate!,
                                                  );
                                                  getHomePageGraphs(
                                                    selectedState!,
                                                    selectedDistrict,
                                                    selectedCommodity!,
                                                    selectedStartDate!,
                                                    selectedEndDate!,
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromARGB(
                                                    255,
                                                    0,
                                                    167,
                                                    33,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 15,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.search_rounded,
                                                  size: 30,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: dW * 0.7,
                                    // padding: EdgeInsets.symmetric(
                                    //   horizontal: 10,
                                    //   vertical: 5,
                                    // ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    margin: EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        TableRow(
                                          marketId: "Market ID",
                                          state: "State",
                                          district: "District",
                                          mandiName: "Mandi Name",
                                          commodity: "Commodity",
                                          variety: "Variety",
                                          grade: "Grade",
                                          minPrice: "Min Price",
                                          maxPrice: "Max Price",
                                          modalPrice: "Modal Price",
                                          date: "Date",
                                          bgColor: primaryOrange,
                                          isHeader: true,
                                        ),
                                        isLoading
                                            ? Padding(
                                                padding: const EdgeInsets.all(40.0),
                                                child: CircularProgressIndicator(),
                                              )
                                            : Provider.of<HomeProvider>(
                                                context,
                                              ).tableData.isEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: Text(
                                                  areAllFiltersSelected()
                                                      ? "No data available"
                                                      : "Select filters to search",
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade400,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                children: tableDataToDisplay
                                                    .map(
                                                      (data) => TableRow(
                                                        marketId:
                                                            data["market_id"] ?? "",
                                                        state: data["state"] ?? "",
                                                        district:
                                                            data["district"] ?? "",
                                                        mandiName:
                                                            data["market_name"] ?? "",
                                                        commodity:
                                                            data["commodity"] ?? "",
                                                        variety:
                                                            data["variety"] ?? "",
                                                        grade: data["grade"] ?? "",
                                                        minPrice:
                                                            data["min_price"]
                                                                ?.toString() ??
                                                            "",
                                                        maxPrice:
                                                            data["max_price"]
                                                                ?.toString() ??
                                                            "",
                                                        modalPrice:
                                                            data["modal_price"]
                                                                ?.toString() ??
                                                            "",
                                                        date: data["date"] != null
                                                            ? data["date"].toString()
                                                            : "-",
                                                        bgColor: Colors.white,
                                                        refreshGraphs: (){
                                                          getHomePageGraphs(
                                                            selectedState!,
                                                            selectedDistrict,
                                                            selectedCommodity!,
                                                            selectedStartDate!,
                                                            selectedEndDate!,
                                                          );
                                                        }
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
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
                                        "Page ${(currentIndex / rowsPerPage).ceil() + 1}/${(Provider.of<HomeProvider>(context).tableData.length / rowsPerPage).ceil()}",
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
                                                  Provider.of<HomeProvider>(
                                                    context,
                                                    listen: false,
                                                  ).tableData.length
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
                              isLoadingGraphs
                                  ? Expanded(
                                      child: Center(
                                        child: Text(
                                          "Generating analytics...",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: const Color.fromARGB(
                                                255,
                                                100,
                                                100,
                                                100,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : seriesList.isEmpty
                                  ? Expanded(
                                      child: Center(
                                        child: Text(
                                          "No analytics to display",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        CustomBarChart(
                                          title: "Top 5 Districts",
                                          chartData: chartData,
                                          xAxis: CategoryAxis(
                                            title: AxisTitle(text: 'Districts'),
                                            labelRotation: 45,
                                          ),
                                          yAxis: NumericAxis(
                                            title: AxisTitle(text: 'Avg Price'),
                                            majorTickLines: const MajorTickLines(
                                              size: 0,
                                            ),
                                          ),
                                        ),
                                        CustomLineChart(
                                          title: "Price Trend Across Top 5 Districts",
                                          dataList: seriesList,
                                          xAxis: DateTimeAxis(
                                            title: AxisTitle(text: "Date"),
                                            dateFormat: DateFormat('dd MMM'),
                                            intervalType: DateTimeIntervalType.days,
                                          ),
                                          yAxis: NumericAxis(
                                            title: AxisTitle(text: 'Price'),
                                            rangePadding: ChartRangePadding.round,
                                            desiredIntervals: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    if (Provider.of<HomeProvider>(context).selectedPage == 2)
                      Container(
                        child: PredictionScreen(),
                      ),
                    if (Provider.of<HomeProvider>(context).selectedPage == 3)
                    DashboardScreen()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceTrendData {
  final DateTime date;
  final double price;

  PriceTrendData(String dateString, this.price)
    : date = DateFormat('dd MMM yyyy').parse(dateString);
}

class TopDistrictData {
  TopDistrictData(this.district, this.value);
  final String district;
  final int value;
}

class TableRow extends StatefulWidget {
  const TableRow({
    super.key,
    required this.marketId,
    required this.state,
    required this.district,
    required this.mandiName,
    required this.commodity,
    required this.variety,
    required this.grade,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.date,
    required this.bgColor,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w400,
    this.isHeader = false,
    this.refreshGraphs,
  });

  final String marketId;
  final String state;
  final String district;
  final String mandiName;
  final String commodity;
  final String variety;
  final String grade;
  final String minPrice;
  final String maxPrice;
  final String modalPrice;
  final String date;
  final Color bgColor;
  final bool isHeader;
  final int fontSize;
  final FontWeight fontWeight;
  final Function? refreshGraphs;

  @override
  State<TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<TableRow> {
  bool _isHovered = false;

  pinMandi() async {
    UserModel user = Provider.of<AuthProvider>(context, listen: false).user;
    if(user.pinnedMandis.length >= 10){
      showSnackbar(
        "You can pin a maximum of 10 mandis",
        Colors.red,
      );
      pop(context);
      return;
    }
    int index = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).user.pinnedMandis.indexWhere((mandi) => mandi.marketId == widget.marketId);
    if (index != -1) {
      showSnackbar(
        "Mandi already pinned",
        const Color.fromARGB(255, 255, 185, 8),
      );
      pop(context);
      return;
    }

    final reqBody = {
      "market_id": widget.marketId,
      "marketName": widget.mandiName,
      "state": widget.state,
      "district": widget.district,
      "token": user.idToken,
    };

    final res = await Provider.of<PinnedMandiProvider>(context, listen: false)
        .pinMandi(
          reqBody: reqBody,
          userId:user.id,
        );
    if (res["success"]) {
      showSnackbar("Mandi pinned successfully", Colors.green);
      widget.refreshGraphs!();
      Provider.of<AuthProvider>(context, listen: false).updatePinnedMandis(res["pinnedMandis"]);

    } else {
      showSnackbar("Error pinning mandi", Colors.red);
    }
    pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        showYesNoDialog(context, mandiName: widget.mandiName, onYes: pinMandi),
      },

      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: !widget.isHeader && _isHovered
                ? primaryYellowLight
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
                    widget.state,
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
                    widget.district,
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
                    widget.mandiName,
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
                    widget.commodity,
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
                    widget.variety,
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
                    widget.grade,
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
                    widget.minPrice,
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
                    widget.maxPrice,
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
                    widget.modalPrice,
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
                    widget.date,
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
      ),
    );
  }
}

class PinnedMandiCard extends StatelessWidget {
  const PinnedMandiCard({
    super.key,
    required this.pinnedMandi,
  });
  final PinnedMandi pinnedMandi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(right: 10, top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade500, width: 1),
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SvgPicture.asset(
                            "assets/svg/mandi_icon.svg",
                            width: 30,
                          ),
                        ),
                        Container(
                          width: 100,
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            pinnedMandi.marketName,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 100,
                              child: Text(
                                "${pinnedMandi.district}, ",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Row(
                          children: [
                            Text(
                              pinnedMandi.state,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.only(top: 10),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Text(
                                "View Details >",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color.fromARGB(255, 72, 172, 255),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: Offset(-1, 2),
                spreadRadius: 1,
                blurRadius: 3
              )
            ]
          ),
          child: SvgPicture.asset(
              "assets/svg/pinned_icon.svg",
              width: 16,
              color: Colors.grey.shade500,
            ),
        ),
        ],
      ),
    );
  }
}

class HomeTopBar extends StatefulWidget {
  const HomeTopBar({super.key, required this.user});

  final UserModel user;

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  int hoveredTab = 0;

  getTab({
    required String text,
    required IconData icon,
    required Function onClick,
    required int index,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        setState(() {
          hoveredTab = index;
        });
      },
      onExit: (event) {
        setState(() {
          hoveredTab = 0;
        });
      },
      child: GestureDetector(
        onTap: () {
          Provider.of<HomeProvider>(
            context,
            listen: false,
          ).setSelectedPage(index);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Provider.of<HomeProvider>(context).selectedPage == index
                ? Colors.black
                : hoveredTab == index
                ? const Color.fromARGB(255, 172, 240, 174)
                : Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      (hoveredTab == index) ||
                          (Provider.of<HomeProvider>(context).selectedPage ==
                              index)
                      ? Colors.white
                      : Colors.black,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color:
                            (hoveredTab == index) ||
                                (Provider.of<HomeProvider>(
                                      context,
                                    ).selectedPage ==
                                    index)
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 76, 175, 80),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/images/nav_bar_logo.png",
            width: 60,
          ),
          SizedBox(width: 20),
          getTab(
            text: "Home",
            icon: Icons.home_filled,
            index: 1,
            onClick: () {},
          ),
          getTab(
            text: "Plant Disease Prediction",
            icon: Icons.settings,
            index: 2,
            onClick: () {},
          ),
          getTab(
            text: "Dashboard",
            icon: Icons.dashboard_rounded,
            index: 3,
            onClick: () {},
          ),
          Expanded(child: SizedBox()),
          Text(
            "👋 Hello, ${widget.user.firstName}",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(100),
            ),
            child: widget.user.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: widget.user.photoUrl ?? "",
                      placeholder: (context, url) => const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 30,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  )
                : const Icon(Icons.person, color: Colors.grey, size: 30),
          ),
        ],
      ),
    );
  }
}

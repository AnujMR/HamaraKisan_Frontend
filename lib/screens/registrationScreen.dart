import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamarakisan_front/commonFunctions.dart';
import 'package:hamarakisan_front/models/userModel.dart';
import 'package:hamarakisan_front/navigators.dart';
import 'package:hamarakisan_front/providers/authProvider.dart';
import 'package:hamarakisan_front/screens/homeScreen.dart';
import 'package:hamarakisan_front/store.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  double dH = 0.0, dW = 0.0;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode pincodeFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String selectedState = "";
  String selectedDistrict = "";
  List<String> selectedCommodities = [];
  UserModel? user;

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

  customDropDownTextField({
    required Function(String?)? onChanged,
    String? Function(String?)? validator,
    required List<String> items,
    String hintText = "",

  }) {
    return SizedBox(
      // height: dW * 0.12,
      child: DropdownSearch<String>(
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
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
        ),
        popupProps: PopupProps.menu(
          fit: FlexFit.loose,
          showSearchBox: false,
          showSelectedItems: true,
          searchFieldProps: TextFieldProps(
            cursorColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: dW * 0.03),
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
        validator: validator,
      ),
    );
  }

  handleSubmit()async{
    if (_formKey.currentState!.validate()) {
                     if (selectedDistrict.trim().isEmpty) {
                        showSnackbar("Please select your state", Colors.red);
                        return;
                      }

                      if (selectedState.trim().isEmpty) {
                        showSnackbar("Please select your district", Colors.red);
                        return;
                      }
                      
                       if (selectedCommodities.isEmpty) {
                        showSnackbar(
                          "Please select atleast one commodity",
                          Colors.red,
                        );
                        return;
                      }
                      Map<String, dynamic> updateData = {
                        "firstName":firstNameController.text.trim(),
                        "lastName" :lastNameController.text.trim(),
                        "district": selectedDistrict,
                        "state": selectedState,
                        "interestedCom": selectedCommodities,
                        "isRegistered": true,
                      };
                      final res = await Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).updateUser(userData: updateData, idToken: Provider.of<AuthProvider>(context, listen: false).user.idToken);
                      if (res != null) {
                        showSnackbar("Registered successfully", Colors.green);
                        pushAndRemoveUntil(context, HomeScreen());
                      } else {
                        showSnackbar(
                          "An error occured! Please try again.",
                          Colors.red,
                        );
                      }
                    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = Provider.of<AuthProvider>(context, listen: false).user;
    firstNameController.text =
        user != null && user!.firstName.trim().isNotEmpty
            ? user!.firstName.trim()
            : "";
    lastNameController.text =
        user != null && user!.lastName.trim().isNotEmpty
            ? user!.lastName.trim().split(" ").length > 1
                ? user!.lastName.trim()
                : ""
            : "";
  }

  @override
  Widget build(BuildContext context) {
    dH = MediaQuery.of(context).size.height;
    dW = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            width: dW * 0.4,
            height: dH * 0.8,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 3,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Registation",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "First Name",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: dW * 0.16,
                              child: textField(
                                controller: firstNameController,
                                hintText: "Ex. Mahesh",
                                textInputType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                focusNode: firstNameFocusNode,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Name",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: dW * 0.16,
                              child: textField(
                                controller: lastNameController,
                                hintText: "Ex. Gupta",
                                textInputType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                focusNode: lastNameFocusNode,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "State",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: dW * 0.16,
                              child: customDropDownTextField(
                                onChanged: (st) {
                                  setState(() {
                                    selectedState = st ?? "";
                                    selectedDistrict = "";
                                  });
                                },
                                items: stateDistrictMap.keys
                                    .cast<String>()
                                    .toList(),
                                hintText: "Select State",
                                validator: (_) {
                                  if (selectedState.trim().isEmpty) {
                                    return 'Please select your state';
                                  }
                                }
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "District",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: dW * 0.16,
                              child: customDropDownTextField(
                                onChanged: (dist) {
                                  setState(() {
                                    selectedDistrict = dist ?? "";
                                  });
                                },
                                items: selectedState.isEmpty
                                    ? []
                                    : stateDistrictMap[selectedState]!
                                          .cast<String>()
                                          .toList(),
                                hintText: "Select district",
                                validator: (_) {
                                  if (selectedDistrict.trim().isEmpty) {
                                    return 'Please select your district';
                                  }
                                }
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(thickness: 0.5),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Interested Commodities",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: dW * 0.16,
                              child: customDropDownTextField(
                                onChanged: (com) {
                                  setState(() {
                                    if (com != null &&
                                        !selectedCommodities.contains(com))
                                      selectedCommodities.add(com);
                                  });
                                },
                                items: commodity_list,
                                hintText: "Select commodity",
                                validator: (_) {
                                  if (selectedCommodities.isEmpty) {
                                    return 'Please select atleast one commodity';
                                  }
                                }
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: dW * 0.16,
                      height: dH * 0.2,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: selectedCommodities.isEmpty
                          ? Text(
                              "Select atleast one commodity",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Wrap(
                                spacing: 6.0,
                                runSpacing: 6.0,
                                children: selectedCommodities
                                    .map(
                                      (com) => Chip(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        label: Text(
                                          com,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        deleteIcon: Icon(Icons.close, size: 18),
                                        onDeleted: () {
                                          setState(() {
                                            selectedCommodities.remove(com);
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                    ),
                    
                  ],
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
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
}

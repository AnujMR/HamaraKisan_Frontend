import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({super.key, required this.onClick, required this.text, this.fontSize = 16});
  final Function onClick;
  final String text;
  final double fontSize;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){widget.onClick();},
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_){
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_){
          setState(() {
            isHovered = false;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isHovered ? const Color.fromARGB(255, 55, 127, 57) : const Color.fromARGB(255, 76, 190, 80),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Text(widget.text, style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, fontSize: widget.fontSize, fontWeight: FontWeight.w500))),
        ),
      ),
    );
  }
}
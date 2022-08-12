import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ElementCircularState extends StatefulWidget {
  ElementCircularState(this.icon, this.value, this.color, this.onPressed,
      {this.scale = 1, this.text = "", this.strict = false,
        this.backgroundInvisible=false,this.bigIcon=false,this.iconColor=Colors.transparent, Key? key})
      : super(key: key);

  final IconData icon ;
  final String value;
  final Color color;
  final double scale;
  final bool strict;
  final String text;
  final bool backgroundInvisible,bigIcon;
  final Color iconColor;
  var onPressed = () async {};

  @override
  _ElementCircularStateState createState() => _ElementCircularStateState();
}

class _ElementCircularStateState extends State<ElementCircularState> {
  @override
  Widget build(BuildContext context) {
    var lightColor = HSLColor.fromColor(widget.color)
        .withLightness(
            math.pow(HSLColor.fromColor(widget.color).lightness, 0.3) as double)
        .toColor();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        shadowColor: widget.color.withOpacity(0.1),
        elevation: 0,
        primary: widget.backgroundInvisible?Colors.transparent:Colors.black.withOpacity(0.16),
        onPrimary: widget.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0 * widget.scale),
        ),
      ),
      onPressed: widget.onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: widget.strict?8.0 * widget.scale:8.0 * widget.scale,
            horizontal: widget.strict?8.0 * widget.scale:20* widget.scale),
        child: CircularPercentIndicator(
          animation: true,
          animateFromLastPercent: true,
          animationDuration: 500,
          radius: 32.0 * widget.scale,
          lineWidth: (widget.bigIcon?13.5:15.0) * widget.scale,
          percent: double.parse(widget.value) / 100,
          center: Icon(
            widget.icon,
            color: widget.iconColor==Colors.transparent?lightColor:widget.iconColor,
            size:(widget.bigIcon?42: 30) * widget.scale,
          ),
          footer: widget.strict&&widget.text == ""?Container():Column(
            children: [
              widget.text == ""
                  ? Text(
                      "${widget.value}%",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 18 * widget.scale,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                  : Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 18 * widget.scale,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
            ],
          ),
          progressColor: widget.color,
          backgroundColor: Colors.black.withOpacity(0.16),
        ),
      ),
    );
  }
}

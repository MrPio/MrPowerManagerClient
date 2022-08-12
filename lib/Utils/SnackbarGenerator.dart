import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackBarGenerator {
  static void makeSnackBar(BuildContext context, String text,
      {Color color = Colors.cyan, double fontSize = 16.0,int millis=3000,Color textColor=Colors.black,
        Color actionColor=Colors.transparent,String actionText="Undo",Function()? onActionPressed,
      Function()? onActionIgnored}) {
    var snackBar = SnackBar(
      content: Text(
        text,
        style: GoogleFonts.lato(fontSize: fontSize,color: textColor),
      ),
      backgroundColor: color,
      duration: Duration(milliseconds: millis),
      action: actionColor==Colors.transparent?null: SnackBarAction(
          label: "Undo",
          textColor: actionColor,
          onPressed: onActionPressed!,
      ),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
      if (reason != SnackBarClosedReason.action && onActionIgnored!=null) {
        onActionIgnored();
      }
    });
  }
}

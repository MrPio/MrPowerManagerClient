import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Utils/size_adjustaments.dart';

Future<String> inputDialog(
    BuildContext context,
    String contentText,
    String hint,
    IconData icon,
    {bool obscuring = false, bool numbers=false,String? title,}) async {
  final inputBoxText=TextEditingController();
  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

          title: title==null?null:Text(
            title,
            style: GoogleFonts.lato(fontSize: 20,),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  child: Text(
                    contentText,
                    style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              SizedBox(height: adjustSizeVertically(context, 20),),
              TextField(
                  keyboardType: numbers?TextInputType.number:TextInputType.text,
                  inputFormatters: numbers?[FilteringTextInputFormatter.digitsOnly]:[],
                  controller: inputBoxText,
                  obscureText: obscuring,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      hintText: hint,
                      icon: Icon(icon, size: 32))),

            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                primary: Colors.deepOrangeAccent,
                onPrimary: Colors.red[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('CANCEL',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
              onPressed: () {
                return Navigator.pop(context,'');
              },
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  primary: Colors.lightGreen,
                  onPrimary: Colors.green[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('CONFIRM',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
                onPressed: () {
                  return Navigator.pop(context,inputBoxText.text );
                })
          ]);
    },
  )??'';
}

class sliderDialog extends StatefulWidget {
  sliderDialog(this.title, this.sliderValue,this.division,this.icon,{Key? key}) : super(key: key);

  String title = '';
  int sliderValue = 50;
  final int division;
  final IconData icon;

  @override
  _sliderDialogState createState() => _sliderDialogState();
}

class _sliderDialogState extends State<sliderDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        buttonPadding: const EdgeInsets.all(12),
        contentPadding:const EdgeInsets.fromLTRB(16,24,16,12) ,
        title: Row(
          children: [
            SizedBox(width: adjustSizeHorizontally(context, 2),),
            Icon(widget.icon,size: adjustSizeHorizontally(context, 34),),
            SizedBox(width: adjustSizeHorizontally(context, 14),),
            Flexible(
              fit: FlexFit.tight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  widget.title+'     ',
                  style: GoogleFonts.lato(fontSize: 18,),
                ),
              ),
            ),
          ],
        ),
        content: Container(
          height: 50,
          width: double.infinity,
          child: Slider(
            value: (widget.sliderValue).roundToDouble(),
            min: 0,
            max: 100,
            divisions: widget.division,
            label:(widget.sliderValue).round().toString(),
            onChanged: (double value) {
              setState(() {
                widget.sliderValue = value.round();
              });
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              primary: Colors.redAccent,
              onPrimary: Colors.red[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text('CANCEL',
            style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                primary: Colors.lightGreen,
                onPrimary: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('OK',
    style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
              onPressed: () {
                Navigator.pop(context, widget.sliderValue);
              })
        ]);
  }
}

  Future<bool> yesNoDialog(
  BuildContext context,
  String title,
) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

          title: Text(
            title,
            style: GoogleFonts.lato(fontSize: 20),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                primary: Colors.deepOrangeAccent,
                onPrimary: Colors.red[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('CANCEL',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
              onPressed: () {
                return Navigator.pop(context, false);
              },
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  primary: Colors.lightGreen,
                  onPrimary: Colors.green[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('CONFIRM',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
                onPressed: () {
                  return Navigator.pop(context, true);
                })
          ]);
    },
  )??false;
}

Future<dynamic> okDialog(
  BuildContext context,
  String title,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

          title: Text(
            title,
            style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.w300),
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  primary: Colors.amber[700],
                  onPrimary: Colors.red[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Understood',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                })
          ]);
    },
  );
}


Future<bool> yesNoCupertinoDialog(BuildContext context,  String title,[String confirm='Ok',String cancel='Cancel']) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(

      content: Text(title,style: GoogleFonts.lato(fontSize: 16),),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(cancel),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        CupertinoDialogAction(
          child: Text(confirm),
          onPressed: () {
            return Navigator.of(context).pop(true);
          },
        )
      ],
    ),
  ) ??
      false; // In case the user dismisses the dialog by clicking away from it
}
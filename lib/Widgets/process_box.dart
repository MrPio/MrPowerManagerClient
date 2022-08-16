import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';

import '../Screens/Home.dart';
import '../Utils/size_adjustaments.dart';

class ProcessBox extends StatefulWidget {
  ProcessBox(this.title, this.image, {Key? key}) : super(key: key);

  String title;
  Image? image;
  static Map<String,bool> selected={};


  @override
  _ProcessBoxState createState() => _ProcessBoxState();
}

class _ProcessBoxState extends State<ProcessBox> {
  var backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    bool selected=ProcessBox.selected[widget.title]??false;

    if(widget.image!=null) {
      findColor();
    }

    var _borderRadiusUnselected =
    BorderRadius.circular(adjustSizeHorizontally(context, 28));
    var _borderRadiusSelected =
    BorderRadius.circular(adjustSizeHorizontally(context, 16));
    var trimmedText=widget.title.length>=23?widget.title.substring(0,20)+' ...':widget.title;

    var paletteGenerator;

    return GestureDetector(
      onTap: () {
        setState(() {
          Home.pcManagerState?.setState(() {
            ProcessBox.selected[widget.title] = !(ProcessBox.selected[widget.title]??false);
            for(var key in ProcessBox.selected.keys){
              if(key!=widget.title){
                ProcessBox.selected[key]=false;
              }
            }
          });
        });
      },
      child: AnimatedContainer(
        margin: EdgeInsets.all(
            selected ? 0 : adjustSizeHorizontally(context, 6)),
        decoration: BoxDecoration(
          color: selected
              ? backgroundColor.withOpacity(0.7)
              : backgroundColor.withOpacity(0.38),
          borderRadius: selected
              ? _borderRadiusSelected
              : _borderRadiusUnselected,
        ),
        duration: const Duration(milliseconds: 120),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.fromSize(size: const Size(0,7),),

            Flexible(
              flex: 3,
              child: widget.image==null?Icon(Icons.settings,size: 64,color: Colors.grey.shade800,):widget.image!,
            ),
            Flexible(
              flex: 2,
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(trimmedText, maxLines: 999,textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 17, fontWeight: FontWeight.w300),),
                  )),
            ),
            SizedBox.fromSize(size: const Size(0,4),)
          ],
        ),
      ),
    );
  }


  findColor()async{
    var palette= await PaletteGenerator.fromImageProvider(widget.image!.image);
    setState(() {
      backgroundColor=palette.dominantColor?.color??Colors.white;
    });
  }
}

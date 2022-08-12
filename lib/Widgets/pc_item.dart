import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Styles/pc_states.dart';

class PcItem extends StatefulWidget {
  PcItem(this.pcName, this.online, {Key? key}) : super(key: key);

  String pcName;
  bool online;

  @override
  _PcItemState createState() => _PcItemState();

  PcItem.copy(PcItem other):pcName=other.pcName,online=other.online;
}

class _PcItemState extends State<PcItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Column(
          children: [
            widget.online?Text(
               'online',
              style: GoogleFonts.lato(
                fontSize: 20,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ):Container(),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Icon(
                  Icons.circle,
                  color: widget.online?Colors.lightGreen:Colors.red,
                ),
                const SizedBox(
                  width: 35,
                ),
                Icon(
                  Icons.laptop,
                  color: Colors.grey[300] ?? Colors.grey,
                  size: 34,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.pcName,
                  style:
                      GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

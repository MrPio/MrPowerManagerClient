import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Screens/wattage_consumption.dart';
import 'package:mr_power_manager_client/Widgets/element_circular_status.dart';

import '../Screens/pc_manager.dart';
import '../Utils/SnackbarGenerator.dart';
import '../Utils/size_adjustaments.dart';

class LargeCommandShape extends StatefulWidget {

  LargeCommandShape(this.active, this.color, this.colorHighlight, this.title,
      this.bottom, this.icon, this.onTap,
      {super.key, required this.spots,
      required this.each,required this.unit,this.bottom2=''});

  static PcManagerState? pcManager;
  static String pcName = '';

  bool active = false;
  final Color color;
  final Color colorHighlight;
  final IconData icon;
  final String title;
  final Function onTap;
  final List<dynamic> spots;
  final int each;
  final String unit;

  final String bottom,bottom2;

  @override
  _LargeCommandShapeState createState() => _LargeCommandShapeState();
}

class _LargeCommandShapeState extends State<LargeCommandShape> {
  var hover = false;

  double tapPos=0;

  @override
  Widget build(BuildContext context) {
    var currentWattage=LargeCommandShape.pcManager?.widget.currentWattage??0;
    var maxWattage=LargeCommandShape.pcManager?.widget.maxWattage??0;
    var maxWattageSecure=maxWattage==0?100:maxWattage;
    List<FlSpot> spots=[];
    widget.spots.asMap().forEach((i, e) =>spots.add(FlSpot((i).toDouble(),e)));
    var chart =
        WattageConsumptionChart(spots: spots,each: 20,unit: widget.unit,);
    var headerLeft = widget.title.toLowerCase().contains('wattage')
        ? ElementCircularState(
            Icons.bolt,
      (currentWattage*100~/maxWattageSecure).toString(),
            widget.colorHighlight,
            () async {
              if (maxWattage == 0) {
                LargeCommandShape.pcManager?.requestMaxWattage();
                return;
              }
              SnackBarGenerator.makeSnackBar(
                  context, "Your pc is currently using $currentWattage Watts",
                  color: Colors.amber);
            },
            strict: true,
      text: '${currentWattage}W',
            backgroundInvisible: true,
            bigIcon: true,
          )
        : Padding(
          padding: EdgeInsets.all(adjustSizeHorizontally(context, 16)),
          child: Icon(
              widget.icon,
              size: adjustSizeHorizontally(context, 48),
              color: hover ? widget.colorHighlight : (Colors.grey[900]??Colors.black).withOpacity(0.72),
            ),
        );

    var _borderRadius =
        BorderRadius.circular(adjustSizeHorizontally(context, 26));
    var scale = adjustSizeHorizontally(context, 1);
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: adjustSizeHorizontally(context, 22)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: hover
              ? widget.color.withOpacity(0.6)
              : widget.active
                  ? widget.color
                  : widget.color,
          borderRadius: _borderRadius,
        ),
        height: adjustSizeHorizontally(context, widget.active ?
        widget.title.toLowerCase().contains('wattage')?406 :390:
        widget.title.toLowerCase().contains('wattage')?106:90),
        child: InkWell(
          onTap: () async {
            setState(() {
              hover = true;
              if (!widget.active &&
                  !(LargeCommandShape.pcManager!.widget.wattsActive ^
                  LargeCommandShape.pcManager!.widget.cpusActive ^
                  LargeCommandShape.pcManager!.widget.gpusActive ^
                  LargeCommandShape.pcManager!.widget.ramsActive ^
                  LargeCommandShape.pcManager!.widget.disksActive ^
                  LargeCommandShape.pcManager!.widget.tempsActive) ){
                Future.delayed(const Duration(milliseconds: 200), () async {
                  var add=adjustSizeVertically(context, 320)*math.pow(tapPos, 1);
                  LargeCommandShape.pcManager?.listviewController2.animateTo(
                      (LargeCommandShape.pcManager?.listviewController2.offset??0) +add,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.fastOutSlowIn);
                });
              }
              Future.delayed(const Duration(milliseconds: 120), () async {
                setState(() {
                  hover = false;
                });
              });
            });
            await widget.onTap();
          },
          onTapDown: (tapDownDetails) {
            tapPos=(tapDownDetails.globalPosition.dy-MediaQuery.of(context).size.height/3.0)/(MediaQuery.of(context).size.height/2.0);
            setState(() {
              hover = true;
            });
          },
          onTapCancel: () {
            setState(() {
              hover = false;
            });
          },
          onTapUp: (tapUpDetails) {
            setState(() {
              hover = false;
            });
          },
          splashColor: widget.colorHighlight,
          borderRadius: _borderRadius,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(4.0 * scale),
                                child: headerLeft,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.lato(
                                      fontSize: 20 * scale,
                                      color: hover
                                          ? widget.colorHighlight
                                          : (Colors.grey[900]??Colors.black).withOpacity(0.82),
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  height: adjustSizeVertically(context, 2),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 10 * scale,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: adjustSizeHorizontally(context, 6),
                                    ),
                                    Text(
                                      widget.bottom,
                                      style: GoogleFonts.lato(
                                          fontSize: 16 * scale,
                                          color: Colors.grey[100],
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                widget.bottom2!=''?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 10 * scale,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: adjustSizeHorizontally(context, 6),
                                    ),
                                    Text(
                                      widget.bottom2,
                                      style: GoogleFonts.lato(
                                          fontSize: 16 * scale,
                                          color: Colors.grey[100],
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ):Container(),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    widget.active? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Divider(
                                  color: Colors.white.withOpacity(0.65),
                                ),
                                chart,
                              ],
                            ),
                          )
                        : Container()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

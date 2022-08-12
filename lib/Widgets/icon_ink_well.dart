import 'package:flutter/material.dart';

class IconInkWell extends StatefulWidget {
  IconInkWell(this.icon,this.onTap,{this.radius=24.0,Key? key}) : super(key: key);
  final Function() onTap;
  final Icon icon;
  double radius;
  @override
  _IconInkWellState createState() => _IconInkWellState();
}

class _IconInkWellState extends State<IconInkWell> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        splashColor: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: widget.icon
        ),
        onTap: widget.onTap,
      ),
    );
  }
}

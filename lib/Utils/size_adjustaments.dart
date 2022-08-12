import 'package:flutter/material.dart';

double adjustSizeHorizontally(BuildContext context, double value) {
  return value * MediaQuery.of(context).size.width / 411.4;
}
double adjustSizeVertically(BuildContext context, double value) {
  return value * MediaQuery.of(context).size.height / 683.4;
}

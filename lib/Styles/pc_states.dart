import 'package:flutter/material.dart';

enum PcStates { online, offline, paused }

extension PcStatesExtension on PcStates {
  Color get color {
    switch (this) {
      case PcStates.online:
        return Colors.green;
      case PcStates.offline:
        return Colors.deepOrange;
      case PcStates.paused:
        return Colors.yellow;
      default:
        return Colors.transparent;
    }
  }


}

PcStates getState(String name){
  PcStates state;
  switch (name) {
    case 'ONLINE':
      state = PcStates.online;
      break;
    case 'OFFLINE':
      state = PcStates.offline;
      break;
    case 'PAUSED':
      state = PcStates.paused;
      break;
    default:
      state=PcStates.offline;
      break;
  }
  return state;
}

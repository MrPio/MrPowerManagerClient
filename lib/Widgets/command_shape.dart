import 'dart:math';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Pages/input_dialog.dart';
import 'package:mr_power_manager_client/Utils/SnackbarGenerator.dart';
import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';
import 'package:mr_power_manager_client/Utils/size_adjustaments.dart';

import '../Screens/Home.dart';
import '../Screens/pc_manager.dart';
import '../Styles/commands.dart';

class CommandShape extends StatefulWidget {
  CommandShape(
      this.pcName, this.color, this.text, this.icon, this.active, this.command,
      {super.key});

  static PcManagerState? pcManager;
  static Map<Commands,int> multiplication={};
  Color color = Colors.white;
  bool selected = false;
  IconData icon = Icons.alarm;
  String text = 'Sleep';
  bool active = true;
  String pcName = '';
  double scale = 1;

  Commands command = Commands.LOCK;

  @override
  State<CommandShape> createState() => _CommandShapeState();
}

class _CommandShapeState extends State<CommandShape> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    var _borderRadiusUnselected =
        BorderRadius.circular(adjustSizeHorizontally(context, 28));
    var _borderRadiusSelected =
        BorderRadius.circular(adjustSizeHorizontally(context, 16));
    var newCol = widget.active ? widget.color : Colors.black;
    var scale = adjustSizeHorizontally(context, 1);
    return GestureDetector(
      onTap: () {
        if (widget.text == "Lock" || widget.text == "Unlock") {
          CommandShape.pcManager?.setState(() {
            CommandShape.pcManager?.widget.isClipboardShared =
                !(CommandShape.pcManager?.widget.isClipboardShared ?? true);
          });
        } else if (widget.text == "Wifi") {
          CommandShape.pcManager?.setState(() {
            CommandShape.pcManager?.widget.wifi =
                !(CommandShape.pcManager?.widget.wifi ?? true);
          });
        } else if (widget.text == "Bluetooth") {
          CommandShape.pcManager?.setState(() {
            CommandShape.pcManager?.widget.bluetooth =
                !(CommandShape.pcManager?.widget.bluetooth ?? true);
          });
        }
        requestValueIfNeededAndSendCommand(null);
      },
      onTapDown: (tapDetails) {
        setState(() {
          hover = true;
        });
      },
      onTapCancel: () {
        Future.delayed(const Duration(milliseconds: 70), () async {
          setState(() {
            hover = false;
          });
        });
      },
      onTapUp: (tapDetails) {
        Future.delayed(const Duration(milliseconds: 70), () async {
          setState(() {
            hover = false;
          });
        });
      },
      onLongPress: () async {

        if([Commands.SOUND_UP,Commands.SOUND_DOWN,Commands.BRIGHTNESS_UP,
          Commands.BRIGHTNESS_DOWN,Commands.TRACK_PREVIOUS,Commands.TRACK_NEXT].contains(widget.command)){

          if(await yesNoDialog(context, 'Wanna set a command multiplication or schedule the command?',
              confirm: 'Multiplication',cancel: 'Schedule')){
            var val=await inputNumber(context, 'Input the number of time you want this command to be executed.'
                ' I will remember it.', Icons.numbers,title: 'Command multiplication',startValue: CommandShape.multiplication[widget.command]??1);
            if(val!=-1){
              CommandShape.multiplication[widget.command]=val;
              await StoreKeyValue.saveData('${Home.pcManagerState?.widget.pcName}-${widget.command}', val);
            }
            return;
          }
        }

        SnackBarGenerator.makeSnackBar(
            context, "Please select a date to schedule the command",
            color: Colors.blue, millis: 600);
        Future.delayed(const Duration(milliseconds: 600), () async {
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              minTime: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  DateTime.now().hour,
                  DateTime.now().minute + 1),
              maxTime: DateTime(DateTime.now().year + 3, 1, 1),
              theme: DatePickerTheme(
                backgroundColor: Colors.grey[900] ?? Colors.black,
                itemStyle: GoogleFonts.lato(
                  color: Colors.white,
                ),
                cancelStyle: GoogleFonts.lato(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                doneStyle: GoogleFonts.lato(
                  color: Colors.blue[300],
                  fontSize: 20,
                ),
              ), onConfirm: (date) {
            requestValueIfNeededAndSendCommand(date);
          }, currentTime: DateTime.now());
        });
      },
      child: AnimatedContainer(
        margin: EdgeInsets.all(hover ? 0 : adjustSizeHorizontally(context, 6)),
        decoration: BoxDecoration(
          color: hover ? newCol.withOpacity(0.6) : newCol,
          borderRadius: hover ? _borderRadiusSelected : _borderRadiusUnselected,
        ),
        duration: const Duration(milliseconds: 100),
        //curve: Curves.fastOutSlowIn,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 44 * scale,
              color: Colors.grey[800],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Text(
                  (CommandShape.multiplication[widget.command]??1)==1?
                  widget.text:widget.text+' (x${CommandShape.multiplication[widget.command]})',
                  style: GoogleFonts.lato(
                      fontSize: 17 * scale,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendCommand(String pcName, DateTime? scheduledDate,
      [int value = -1]) async {
    /*if (widget.command == Commands.UNLOCK) {
      var key = await StoreKeyValue.readStringData('key-$pcName');
      if (key == '') {
        CommandShape.requestPassword(context, pcName,"WINDOWS");
      }

      requestData(context, HttpType.post, '/sendKey', {
        'token': await StoreKeyValue.readStringData('token'),
        'pcName': pcName,
        'title': "WINDOWS",
        'key': await StoreKeyValue.readStringData('key-$pcName')
      });
    } else*/
    if (widget.command == Commands.HOTSPOT_ON ||
        widget.command == Commands.HOTSPOT_OFF ||
        widget.command == Commands.BLUETOOTH_OFF ||
        widget.command == Commands.BLUETOOTH_ON ||
        widget.command == Commands.RED_LIGHT_ON ||
        widget.command == Commands.RED_LIGHT_OFF ||
        widget.command == Commands.SCREENSHOT) {
      SnackBarGenerator.makeSnackBar(context,
          "Sorry but this feature isn't yet implemented... Look for it!");
      return;
    }

    if (widget.command == Commands.SHUTDOWN &&
        !await yesNoDialog(context,
            'Are you REALLY sure you want to shut down your pc? You may lose unsaved data!')) {
      return;
    }

    var pcManagerWidget = Home.pcManagerState?.widget;

    Home.pcManagerState?.setState(() {
      pcManagerWidget?.lastStatusEditedByClient = DateTime.now();
      switch (widget.command) {
        case Commands.SOUND_UP:
          Home.pcManagerState?.widget.volume =
              min(100, (pcManagerWidget?.volume ?? 0) + 2*(CommandShape.multiplication[widget.command]??1));
          break;
        case Commands.SOUND_DOWN:
          Home.pcManagerState?.widget.volume =
              max(0, (pcManagerWidget?.volume ?? 0) - 2*(CommandShape.multiplication[widget.command]??1));
          break;

        case Commands.BRIGHTNESS_UP:
          Home.pcManagerState?.widget.brightness =
              min(100, (pcManagerWidget?.brightness ?? 0) + 10*(CommandShape.multiplication[widget.command]??1));
          break;
        case Commands.BRIGHTNESS_DOWN:
          Home.pcManagerState?.widget.brightness =
              max(0, (pcManagerWidget?.brightness ?? 0) - 10*(CommandShape.multiplication[widget.command]??1));
          break;
/*        case Commands.NO_SOUND:
          var c = pcManagerWidget?.backupVolume;
          pcManagerWidget?.backupVolume = pcManagerWidget.volume;
          pcManagerWidget?.volume = c ?? 0;
          break;*/
      }
    });

    if (widget.command == Commands.WATTAGE) {
      SnackBarGenerator.makeSnackBar(context,
          "The estimation of today watt-hour is: ${PcManager.wattageValues24h.todayWattHour}Wh",
          color: Colors.amber);
      return;
    }
    if (widget.command == Commands.SHARE_CLIPBOARD) {
      Home.pcManagerState?.setState(() {
        Home.pcManagerState?.widget.lastStatusEditedByClient = DateTime.now();
        Home.pcManagerState?.widget.isClipboardShared =
            !(Home.pcManagerState?.widget.isClipboardShared ?? true);
      });
      var isClipboardShared =
          Home.pcManagerState?.widget.isClipboardShared ?? false;
      Home.pcManagerState?.sendCommand(scheduledDate,
          widget.command.name + '@@@' + isClipboardShared.toString(),
          value: value);
      
      if (isClipboardShared) {
        //LISTNER NON FUNZIONA, E POI SE isClipboardShared==TRUE FALLO PARTIRE ALLAVVIO
        ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
        Home.pcManagerState?.sendMessage("SHARE_CLIPBOARD@@@${data?.text}");
        ClipboardMonitor.registerCallback((str)=>Home.clipboardListener(context,str));
      }
      else{
        ClipboardMonitor.unregisterCallback((str)=>Home.clipboardListener(context,str));
      }
    } else if (widget.command == Commands.SEND_CLIPBOARD) {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      Home.pcManagerState?.sendCommand(null,"SEND_CLIPBOARD@@@${data?.text}");
    } else {
      var multi='';
      if([Commands.SOUND_UP,Commands.SOUND_DOWN,Commands.BRIGHTNESS_UP,
        Commands.BRIGHTNESS_DOWN,Commands.TRACK_PREVIOUS,Commands.TRACK_NEXT].contains(widget.command)) {
        multi='@@@${(CommandShape.multiplication[widget.command]??1)}';
      }
        Home.pcManagerState
          ?.sendCommand(scheduledDate, widget.command.name+multi, value: value);
    }
  }

  void requestValueIfNeededAndSendCommand(dynamic date) {
/*    if (widget.command.name.toLowerCase().contains('value')) {
      String value = '50';
      sliderDialog (context, "Give me the value to send:", value, () {
        sendCommand(widget.pcName, date, int.parse(value));
      }, () {});
    } else {
    NON SERVE MAI SU QUESTI OGGETTI SETTARE IL VALORE*/
    sendCommand(widget.pcName, date);
    //}
  }

  @override
  void initState() {
    super.initState();

    if([Commands.SOUND_UP,Commands.SOUND_DOWN,Commands.BRIGHTNESS_UP,
      Commands.BRIGHTNESS_DOWN,Commands.TRACK_PREVIOUS,Commands.TRACK_NEXT].contains(widget.command)) {

      ()async{
      var val=await StoreKeyValue.readIntData('${Home.pcManagerState?.widget.pcName}-${widget.command}');
      CommandShape.multiplication[widget.command]=val==0?1:val;
    }.call();
    }
  }
}

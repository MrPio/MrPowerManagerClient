import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Pages/input_dialog.dart';
import 'package:mr_power_manager_client/Screens/Home.dart';
import 'package:mr_power_manager_client/Utils/size_adjustaments.dart';
import 'package:mr_power_manager_client/Widgets/icon_ink_well.dart';

import '../Styles/background_gradient.dart';

class MyKeyboardListener extends StatefulWidget {
  const MyKeyboardListener({Key? key}) : super(key: key);

  @override
  MyKeyboardListenerState createState() => MyKeyboardListenerState();
}

class MyKeyboardListenerState extends State<MyKeyboardListener> {
  var _controller = TextEditingController();
  var _focusNode1 = FocusNode();
  var _focusNode2 = FocusNode();
  var _iconSize = 0.0;
  var lastSpeed=40;
  var lastQuality=40;
  Map<String,bool> hover={};
  Map<String,bool> down ={};

  var _listviewController1 = ScrollController();
  var _listviewController2 = ScrollController();

  var base64String;
  var oldImage;
bool hideBottom=false,isStreaming=false;
  @override
  Widget build(BuildContext context) {
    _iconSize=adjustSizeVertically(context, 42);
    return Container(
      decoration: getBackgroundGradient(),
      child: WillPopScope(
        onWillPop: ()async{
          setState(() {
            hideBottom=!hideBottom;
          });
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: [
              base64String==null?Container():Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  child: InteractiveViewer(
                    panEnabled: true, // Set it to false
                    boundaryMargin: EdgeInsets.all(0),
                    minScale: 1,

                    maxScale: 2,
                    onInteractionStart: (details) {
                        // hideHand=true;
                    },
                    child:  GestureDetector(
                        onDoubleTap: () {
                        },
                        child: Stack(children:
                        [
                          oldImage==null?Container():Image.memory(oldImage),
                          base64String==null?Container():Image.memory(base64String),
                        ])),
                  ),
                ),
              ),
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: 0,
                          height: 0,
                          child: TextField(
                            focusNode: _focusNode1,
                            cursorColor: Colors.transparent,
                            style: GoogleFonts.lato(
                                color: Colors.transparent, fontSize: 0),
                            maxLines: 999,
                            autofocus: false,
                            controller: _controller,
                          ),
                        ),
                        Container(
                          width: 0,
                          height: 0,
                          child: TextField(
                            focusNode: _focusNode2,
                          ),
                        ),
                        hideBottom||MediaQuery.of(context).viewInsets.bottom != 0||isStreaming?Container():Center(
                            child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(
                              MediaQuery.of(context).viewInsets.bottom != 0
                                  ? 22
                                  : 36),
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).viewInsets.bottom != 0
                                  ? 2
                                  : 6),
                          color: MediaQuery.of(context).viewInsets.bottom != 0
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white.withOpacity(0.8),
                          strokeWidth: 9,
                          dashPattern: const [20],
                          child: IconInkWell(
                            Icon(
                              Icons.desktop_windows,
                              size: MediaQuery.of(context).viewInsets.bottom != 0
                                  ? 76
                                  : adjustSizeVertically(context, 132),
                              color: MediaQuery.of(context).viewInsets.bottom != 0
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.8),
                            ),
                            () async{
                              if(! await yesNoDialog(context, 'You want to start the streaming of the screen?',)) {
                                return;
                              }

                              setState(() {
                                isStreaming=true;
                              });
                              Home.pcManagerState?.myKeyboardListener=this;
                              sendStreamingStart();
                              scheduleStreamingStart();
                            },
                            radius: 80,
                          ),
                        )),


                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          color: Colors.blue,
                        ),
                      )
                    ],
                  ),
                  hideBottom?Container(): Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_double_arrow_left,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            _listviewController2.animateTo(_listviewController2.offset - 160,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn);
                          },
                          splashColor: Colors.deepOrange,
                          alignment: Alignment.center,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            controller: _listviewController2,
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: [

                                  keyItem(Colors.white, Icons.keyboard_tab, "tab",                                 small: true),
                                  keyItem(Colors.white, Icons.switch_right, "alt+tab",
                                      small: true),
                                  keyItem(Colors.white, Icons.apps, "win+tab",
                                      small: true),
                                  keyItem(Colors.white, Icons.close, "alt+f4",
                                      small: true),
                                  keyItem(Colors.white, Icons.arrow_downward, "alt+esc",
                                      small: true),
                                  keyItem(Colors.white, Icons.copy, "ctrl+C",
                                      small: true),
                                  keyItem(Colors.white, Icons.paste, "ctrl+V",
                                      small: true),
                                  keyItem(Colors.white, Icons.list_alt, "ctrl+shift+esc",
                                      small: true),
                                  keyItem(Colors.white, Icons.fit_screen, "win+d",
                                      small: true),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_double_arrow_right,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            _listviewController2.animateTo(
                                _listviewController2.offset + 160,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn);
                          },
                          splashColor: Colors.deepOrange,
                          alignment: Alignment.center,
                        ),

                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          color: Colors.amber,
                        ),
                      )
                    ],
                  ),
                  hideBottom?Container(): Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_double_arrow_left,
                            color: Colors.white,
                            size: 42,
                          ),
                          onPressed: () {
                            _listviewController1.animateTo(_listviewController1.offset - 160,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn);
                          },
                          splashColor: Colors.deepOrange,
                          alignment: Alignment.center,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            controller: _listviewController1,
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: [
                                keyItem(Colors.pink,
                                    MediaQuery.of(context).viewInsets.bottom != 0?
                                    Icons.keyboard_hide:Icons.keyboard,
                                    MediaQuery.of(context).viewInsets.bottom != 0?"Hide":"Show",
                                      clickable: false),
                                  keyItem(Colors.lightBlue, Icons.window, "Win",
                                      clickable: true),
                                  keyItem(
                                      Colors.yellow, Icons.arrow_upward, "Shift",
                                      clickable: true),
                                  keyItem(Colors.orangeAccent,
                                      Icons.keyboard_command_key, "Ctrl",
                                      clickable: true),
                                  keyItem(Colors.greenAccent, Icons.alternate_email_outlined,
                                      "Alt",
                                      clickable: true),
                                  keyItem(Colors.blue, Icons.subdirectory_arrow_left,
                                      "Enter",
                                      clickable: true),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_double_arrow_right,
                            color: Colors.white,
                            size: 42,
                          ),
                          onPressed: () {
                            _listviewController1.animateTo(
                                _listviewController1.offset + 160,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn);
                          },
                          splashColor: Colors.deepOrange,
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                  ),
                ],
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 22.0),
                child: IconButton(onPressed: ()async{
                  Home.pcManagerState?.sendCommand(null, 'STREAMING_STOP',snackbar: false);
                  isStreaming=false;
                  Navigator.pop(context);
                }, icon: const Icon(Icons.arrow_back,size: 32,)),
              ),
              !isStreaming?Container():Row(
                mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: IconButton(onPressed: ()async{
                        lastSpeed = await showDialog<int>(
                            context: context,
                            builder: (context) => sliderDialog("Speed",lastSpeed==-1?50:lastSpeed,5,Icons.speed))??-1;
                        if(lastSpeed==-1) {
                          return;
                        }
                        Home.pcManagerState?.sendCommand(null, 'STREAMING_SPEED@@@$lastSpeed',snackbar: false);
                      }, icon: const Icon(Icons.speed,size: 30,)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: IconButton(onPressed: ()async{
                        lastQuality = await showDialog<int>(
                            context: context,
                            builder: (context) => sliderDialog("Quality",lastQuality==-1?50:lastQuality,10,Icons.high_quality))??-1;
                        if(lastQuality==-1) {
                          return;
                        }
                        Home.pcManagerState?.sendCommand(null, 'STREAMING_QUALITY@@@$lastQuality',snackbar: false);
                      }, icon: const Icon(Icons.high_quality,size: 30,)),
                    )
                  ],
              )
            ],
          ),
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  keyItem(Color color, IconData icon, String text,
      {bool small = false, bool clickable = false}) {
    var command=text.toLowerCase();
    var newColor = HSLColor.fromColor(color)
        .withLightness(0.80)
        .withSaturation(0.8)
        .toColor()
        .withOpacity(1);
    if (color == Colors.white) {
      newColor = Colors.white.withOpacity(1);
      color = Colors.white.withOpacity(0.7);
    }
    return Container(
      decoration: BoxDecoration(
          color: down[command]??false ? newColor.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(small ? 16 : 22)),
      child: InkWell(
        onTap: () {
          if(command == 'show'||command=='hide'){
            if (MediaQuery.of(context).viewInsets.bottom != 0) {
              FocusScope.of(context).unfocus();
            }
            else {
              _focusNode2.requestFocus();
              Future.delayed(const Duration(milliseconds: 100),()=>_focusNode1.requestFocus());
            }
            return;
          }
          if (clickable && command =='shift' || command == 'ctrl' || command == 'alt') {
            setState(() {
              down[command] = !(down[command]??false);
            });
          }
          else{
            sendKey(command);
          }
        },
        onLongPress: () {
          if (clickable && command != 'enter') {
            setState(() {
              down[command] = !(down[command]??false);
            });
          }
        },
        onTapDown: (value) => setState(() => hover[command] = true),
        onTapCancel: () => setState(() => hover[command] = false),
        onTapUp: (value) => setState(() => hover[command] = false),
        borderRadius: BorderRadius.circular(small ? 16 : 22),
        splashColor: Colors.white.withOpacity(0.3),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: small ? 4.0 : 8.0, horizontal: small ? 8.0 : 22.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: down[command]??false
                    ? _iconSize * 1.3
                    : (small ? _iconSize / 1.4 : _iconSize.toDouble()),
                color: hover[command]??false ? color : newColor,
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                text,
                style: GoogleFonts.lato(
                    fontSize: small ? 15 : 17,
                    fontWeight: FontWeight.w400,
                    color: hover[command]??false ? color : newColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  var lastText = "";

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (lastText.length == _controller.text.length + 1) {
        sendKey('backspace');
      }
      if (_controller.text.isEmpty) {
        return;
      }
      if (lastText.length == _controller.text.length - 1) {
        if (_controller.text.characters.last == ' ') {
          sendKey('space');
          return;
        }
        sendKey(_controller.text.characters.last.toString().toLowerCase());
      }
      lastText = _controller.text;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void sendKey(String command) {
    Set<String> toHold= {};
    down.forEach((key, value) => value?toHold.add(key):null);
    if(command.contains('+')) {
      var add=command.split('+');
      add.removeLast();
      toHold.addAll(add);
    }
    var commandString='KEYBOARD@@@';
    for (var e in toHold) {
      commandString+=e+':';
    }
    commandString+='@@@'+command.split('+').last;
    Home.pcManagerState?.sendCommand(null, commandString,snackbar: false);
  }

  sendStreamingStart()async{
    Home.pcManagerState?.sendCommand(null, 'STREAMING_START',snackbar: false);
  }
  scheduleStreamingStart()async{
    Future.delayed(const Duration(seconds: 5),(){
      if(!isStreaming) {
        return;
      }
      sendStreamingStart();
      scheduleStreamingStart();
    });
  }
}

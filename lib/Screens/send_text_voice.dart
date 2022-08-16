import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Styles/background_gradient.dart';
import 'package:mr_power_manager_client/Utils/size_adjustaments.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:vibration/vibration.dart';
import 'dart:io'as Io;
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


import 'Home.dart';

class SendTextVoice extends StatefulWidget {
  const SendTextVoice({Key? key}) : super(key: key);

  @override
  _SendTextVoiceState createState() => _SendTextVoiceState();
}

class _SendTextVoiceState extends State<SendTextVoice>
    with TickerProviderStateMixin {
  var _mic_on = false;
  var _input_text = true;
  var _hold = false;
  late final AnimationController _animationController;
  late final CurvedAnimation _curvedAnimation;
  late final AnimationController _animationControllerSlide;
  late final CurvedAnimation _curvedAnimationSlide;

  var _current_index = 0;

  String recordFilePath='';

  stt.SpeechToText speech= stt.SpeechToText();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: getBackgroundGradient(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: 1-_animationControllerSlide.value,
                child: Text(
                  _current_index==0?'Speak to write':'Walkie talkie',
                  style: GoogleFonts.lato(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox.fromSize(size: Size(0,22),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white
                                .withOpacity(_current_index == 0 ? 0 : 0.18),
                            blurRadius: 38.0,
                            spreadRadius: -25.0,
                          ),
                        ]),
                    child: IconButton(
                      icon: Icon(
                        Icons.keyboard_double_arrow_left,
                        color:
                            Colors.white.withOpacity(_current_index == 0 ? 0.2 : 1),
                      ),
                      iconSize: 80,
                      splashColor: _input_text
                          ? Colors.amberAccent
                          : Colors.tealAccent.shade400,
                      onPressed: () {
                        if (_current_index == 1) {
                          changeScreen(0);
                        }
                      },
                    ),
                  ),
                  Opacity(
                    opacity: 1 - _curvedAnimationSlide.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: adjustSizeHorizontally(context, 150),
                          height: adjustSizeHorizontally(context, 150),
                          child: GestureDetector(
                            onLongPress: () async {
                              _animationController.forward();

                              setState(() {
                                _hold = true;
                              });

                              Future.delayed(const Duration(milliseconds: 400),
                                  () async {
                                if (!_hold) {
                                  return;
                                }
                                _mic_on = true;
                                if(_current_index==0){
                                  speech.listen( onResult: (result) {
                                    speech_to_text=result.recognizedWords;
                                    if(speech_to_text.length!=last_speech_to_text){
                                      Home.pcManagerState?.sendCommand(null, 'SPEECH_TO_TEXT@@@'+speech_to_text.substring(last_speech_to_text),snackbar: false);
                                    }
                                    last_speech_to_text=speech_to_text.length;
                                  });
                                }
                                else{
                                startRecord();
                                }

                                if ((await Vibration.hasVibrator()) ?? false) {
                                  Vibration.vibrate(duration: 200);
                                }
                              });
                            },
                            onLongPressUp: () async {
                              setState(() {
                                _hold = false;
                                if(!_mic_on){
                                  return;
                                }
                                _mic_on = false;
                                _animationController.reverse();
                              });

                              if(_current_index==0){
                                speech.stop();
                                speech_to_text='';
                                last_speech_to_text=0;
                              }
                              else{
                                stopRecord();
                              List<int> recBytes = Io.File(await getFilePath()).readAsBytesSync();
                              String base64Rec = base64Encode(recBytes);
                              Home.pcManagerState?.sendBase64(base64Rec,
                                  _current_index==0?'SPEAK_TO_WRITE':'PLAY_AUDIO');
                              }


                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _current_index==0?Colors.amber.withOpacity(
                                          1 * (1 - _curvedAnimation.value)):
                                      Colors.tealAccent.withOpacity(
                                          1 * (1 - _curvedAnimation.value)),
                                      blurRadius: 64.0,
                                      spreadRadius: -23.0,
                                    ),
                                  ]),
                              child: FloatingActionButton(
                                elevation: _hold ? 0 : 12,
                                onPressed: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.62 *
                                                (1 - _curvedAnimation.value)),
                                            blurRadius: 44.0,
                                            spreadRadius: -14.0,
                                          ),
                                        ]),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          _current_index==0? Icons.message_outlined:Icons.mic_none,
                                          size:
                                              adjustSizeHorizontally(context, _current_index==0?90:100),
                                          color: Colors.white.withOpacity(1-_curvedAnimation.value),
                                        ),
                                        Icon(
                                          _current_index==0? Icons.message:Icons.mic,
                                          size:
                                              adjustSizeHorizontally(context, _current_index==0?90:100),
                                          color: Colors.white
                                              .withOpacity(_curvedAnimation.value),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                backgroundColor: _input_text
                                    ? Color.lerp(
                                        Colors.amber,
                                        Colors.deepOrange.shade700,
                                        _curvedAnimation.value)
                                    :Color.lerp(
                                    Colors.tealAccent.shade400,
                                    Colors.teal.shade700,
                                    _curvedAnimation.value),
                                splashColor: _input_text
                                    ? Colors.deepOrange.shade700
                                    : Colors.teal.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _current_index==0?'Press':'Hold',
                          style: GoogleFonts.lato(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              color: _input_text
                                  ? Color.lerp(
                                  Colors.amber.shade200,
                                  Colors.deepOrange.shade300,
                                  _curvedAnimation.value)
                                  : Color.lerp(
                                  Colors.tealAccent.shade200,
                                  Colors.teal.shade400,
                                  _curvedAnimation.value), ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white
                                .withOpacity(_current_index == 1 ? 0 : 0.18),
                            blurRadius: 38.0,
                            spreadRadius: -25.0,
                          ),
                        ]),
                    child: IconButton(
                      icon: const Icon(
                        Icons.keyboard_double_arrow_right,
                      ),
                      iconSize: 80,
                      splashColor: _input_text
                          ? Colors.amberAccent
                          : Colors.tealAccent.shade400,
                      color:
                          Colors.white.withOpacity(_current_index == 1 ? 0.2 : 1),
                      onPressed: () {
                        if (_current_index == 0) {
                          changeScreen(1);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  changeScreen(int index) {
    setState(() {
      _animationControllerSlide.forward();
      Future.delayed(Duration(milliseconds: 250), () {
        _current_index = index;
        _input_text = index == 0;
        _animationControllerSlide.reverse();
      });
    });
  }



  void startRecord() async {
    await Permission.microphone.request();
    bool hasPermission = true;//await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();
      RecordMp3.instance.start(recordFilePath, (type) {
        print( "Record error--->$type");
      });
    } else {
      print("No microphone permission");
    }
    setState(() {});
  }

/*  void pauseRecord() {
    if (RecordMp3.instance.status == RecordStatus.PAUSE) {
      bool s = RecordMp3.instance.resume();
      if (s) {
        setState(() {});
      }
    } else {
      bool s = RecordMp3.instance.pause();
      if (s) {
        statusText = "Recording pause...";
        setState(() {});
      }
    }
  }*/

  void stopRecord() {
    bool s = RecordMp3.instance.stop();
  }

/*  void resumeRecord() {
    bool s = RecordMp3.instance.resume();
    if (s) {
      statusText = "Recording...";
      setState(() {});
    }
  }*/

/*  String recordFilePath;

  void play() {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath, isLocal: true);
    }
  }*/

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/rec.mp3";
  }
String speech_to_text='';
  int last_speech_to_text=0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
      upperBound: 1,
    );
    _animationController.addListener(() => setState(() => {}));
    _curvedAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn);

    _animationControllerSlide = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
      upperBound: 1,
    );
    _animationControllerSlide.addListener(() => setState(() => {}));
    _curvedAnimationSlide = CurvedAnimation(
        parent: _animationControllerSlide, curve: Curves.fastOutSlowIn);

    speech.initialize(onStatus: (status) {},);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Pages/input_dialog.dart';
import 'Home.dart';

class WebcamStreaming extends StatefulWidget {
  const WebcamStreaming({Key? key}) : super(key: key);

  @override
  WebcamStreamingState createState() => WebcamStreamingState();
}

class WebcamStreamingState extends State<WebcamStreaming> {
  var base64String;
  var oldImage;

  bool isStreaming = true;

  int lastSpeed=50;

  var lastQuality=50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        base64String == null
            ? Container()
            : Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  child: InteractiveViewer(
                    panEnabled: true,
                    // Set it to false
                    boundaryMargin: const EdgeInsets.all(0),
                    minScale: 1,

                    maxScale: 2,
                    onInteractionStart: (details) {
                      // hideHand=true;
                    },
                    child: GestureDetector(
                        onDoubleTap: () {},
                        child: Stack(children: [
                          oldImage == null
                              ? Container()
                              : Image.memory(oldImage),
                          base64String == null
                              ? Container()
                              : Image.memory(base64String),
                        ])),
                  ),
                ),
              ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: IconButton(onPressed: ()async{
                lastSpeed = await showDialog<int>(
                    context: context,
                    builder: (context) => sliderDialog("Speed",lastSpeed==-1?50:lastSpeed,5,Icons.speed))??-1;
                if(lastSpeed==-1) {
                  return;
                }
                Home.pcManagerState?.sendCommand(null, 'WEBCAM_SPEED@@@$lastSpeed',snackbar: false);
              }, icon: const Icon(Icons.speed,size: 38,)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: IconButton(onPressed: ()async{
                lastQuality = await showDialog<int>(
                    context: context,
                    builder: (context) => sliderDialog("Quality",lastQuality==-1?50:lastQuality,10,Icons.high_quality))??-1;
                if(lastQuality==-1) {
                  return;
                }
                Home.pcManagerState?.sendCommand(null, 'WEBCAM_QUALITY@@@$lastQuality',snackbar: false);
              }, icon: const Icon(Icons.high_quality,size: 38,)),
            )
          ],
        )
      ],
    ));
  }

  @override
  void initState() {
    super.initState();
    Home.pcManagerState?.webcamStreaming = this;
    sendStreamingStart();
    scheduleStreamingStart();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    isStreaming = false;
    Home.pcManagerState?.sendCommand(null, 'WEBCAM_STOP', snackbar: false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }



  sendStreamingStart() async {
    Home.pcManagerState?.sendCommand(null, 'WEBCAM_START', snackbar: false);
  }

  scheduleStreamingStart() async {
    Future.delayed(const Duration(seconds: 5), () {
      if (!isStreaming) {
        return;
      }
      sendStreamingStart();
      scheduleStreamingStart();
    });
  }
}

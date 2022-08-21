import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mr_power_manager_client/Screens/pc_manager.dart';
import 'package:mr_power_manager_client/Screens/shimmer.dart';
import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';
import 'package:mr_power_manager_client/Utils/api_request.dart';
import 'package:mr_power_manager_client/Utils/size_adjustaments.dart';
import 'package:mr_power_manager_client/Widgets/icon_ink_well.dart';
import 'package:mr_power_manager_client/Widgets/pc_item.dart';

import '../Pages/input_dialog.dart';
import '../Styles/background_gradient.dart';
import '../Utils/SnackbarGenerator.dart';
import '../Widgets/process_box.dart';
import 'dart:io';
import 'dart:typed_data';

class Home extends StatefulWidget {

  static void clipboardListener(context,str) async {
    print('SHARE_CLIPBOARD_listner');
    if (str != '') {
      Home.pcManagerState?.sendMessage("SHARE_CLIPBOARD@@@$str");
      SnackBarGenerator.makeSnackBar(context, 'Clipboard shared!');
    }
  }

  Home({Key? key}) : super(key: key);

  static PcManagerState? pcManagerState;
  late final MyStompClient myStompClient;
  List<Widget> pcListWidget = [];
  List<Widget> shimmerPcListWidget = [];
  static String token = '';
  // static bool stopListenOnMessage=false;
  TextEditingController inputBoxText = TextEditingController();
  List<String> pcNames = [];
  Map<String, bool> pcStatus = {};
  List<String> pcMaxWattage = [];
  List<String> pcBatteryCapacity = [];

  bool isLoading = true;

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  bool tapped=false;
  String header='',message='';
  StringBuffer messageBuffer = StringBuffer();

  var lastSnackbar=DateTime.now();
  var messageStart=DateTime.now(),lastMessage=DateTime.now();
  List<double> times=[];

  // Timer clipboardTriggerTime= Timer.periodic(
  //   const Duration(seconds: 5),
  //       (timer) {
  //     Clipboard.getData('text/plain').then((clipboardContent) {
  //       log('Clipboard content ${clipboardContent?.text}');
  //
  //     });
  //   },
  // );

  @override
  Widget build(BuildContext context) {
    widget.shimmerPcListWidget = widget.isLoading
        ? [
            _buildPcItemShimmer(),
            _buildPcItemShimmer(),
            _buildPcItemShimmer(),
            _buildPcItemShimmer(),
            _buildPcItemShimmer(),
          ]
        : [];
    var listViewItems = [
      _buildColoredBox(),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Your computer list:',
        style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: 20,
      ),
      ...List.from(widget.pcListWidget)..addAll(widget.shimmerPcListWidget),
    ];
    return Container(
      decoration: getBackgroundGradient(),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              widget.isLoading = true;
            });
            await getPcList(context);
            setState(() {
              widget.isLoading = false;
            });
          },
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if (index > 3) {
                  if (listViewItems[index].runtimeType == PcItem) {
                    var old = listViewItems[index] as PcItem;
                    listViewItems[index] = PcItem(
                        old.pcName,
                        widget.pcStatus[old.pcName].toString().toLowerCase() ==
                            'true');
                    // print('updated ${widget.pcStatus[old.pcName]}');
                  }
                  return InkWell(
                    child: Dismissible(
                        background: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const <Widget>[
                              Icon(
                                Icons.delete,
                              )
                            ],
                          ),
                        ),
                        key: UniqueKey(),
                        confirmDismiss: listViewItems[index].runtimeType ==
                                PcItem
                            ? (direction) => yesNoDialog(context,
                                'Are you sure you wanna delete the pc [${(listViewItems[index] as PcItem).pcName}]?')
                            : null,
                        onDismissed: listViewItems[index].runtimeType == PcItem
                            ? ((direction) async {
                                final swiped = listViewItems[index];
                                listViewItems.removeAt(index);
                                SnackBarGenerator.makeSnackBar(
                                    context, "${swiped.pcName} deleted",
                                    color: Colors.black,
                                    textColor: Colors.white,
                                    actionColor: Colors.lightBlue,
                                    onActionIgnored: () async {
                                  var response = await requestData(
                                      context, HttpType.delete, "/deletePc", {
                                    'token': Home.token,
                                    'pcName': (swiped).pcName
                                  });
                                  SnackBarGenerator.makeSnackBar(
                                      context, response['result'].toString(),
                                      color: Colors.amber);
                                }, onActionPressed: () {
                                  final copied = PcItem.copy(swiped);
                                  setState(() =>
                                      listViewItems.insert(index, copied));
                                });
                              })
                            : (dismissed) {
                                yesNoCupertinoDialog(
                                    context,
                                    "Well... yeah, you deleted what you weren't supposed"
                                        " to be able to delete; does this make you feel satisfied?",
                                    'Yep',
                                    'Nope');
                              },
                        child: listViewItems[index]),
                    splashColor: Colors.grey[600],
                    onTap: () {
                      if(tapped) {
                        return;
                      }
                      tapped=true;
                      Future.delayed(const Duration(milliseconds: 400),
                          () async {
                            tapped=false;
                        PcManager.token = Home.token;
                        PcManager.myStompClient = widget.myStompClient;
                        var pcName = (listViewItems[index] as PcItem).pcName;
                        Navigator.pushNamed(context, '/pcManager', arguments: [
                          pcName,
                          widget.pcMaxWattage[index - 4],
                          widget.pcBatteryCapacity[index - 4],
                          widget.pcStatus[pcName].toString()
                        ]);
                      });
                    },
                  );
                } else {
                  return GestureDetector(
                    child: listViewItems[index],
                  );
                }
              },
              itemCount: listViewItems.length),
        ),
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (widget.isLoading) {
              return;
            }
            String? name = await inputDialog(context, 'Give a name to your pc',
                'name', Icons.drive_file_rename_outline);
            if (name != '') {
              if (widget.pcNames.contains(name)) {
                SnackBarGenerator.makeSnackBar(
                    context, "This name is already used!",
                    color: Colors.red);
                return;
              }
              Navigator.pushNamed(context, '/addPc',
                  arguments: {'pcName': widget.inputBoxText.text});
            }
          },
          child: const Icon(Icons.add, size: 30),
          backgroundColor: widget.isLoading ? Colors.grey[700] : Colors.orange,
          splashColor: Colors.deepOrange[700],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          //color:Colors.redAccent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              //children inside bottom appbar
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const <Widget>[
                SizedBox(
                  height: 44,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPcItemShimmer() {
    return PcItemShimmer(
      isLoading: widget.isLoading,
    );
  }

  Widget _buildColoredBox() {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: Stack(alignment: Alignment.center, children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Home.token,
              style: GoogleFonts.lato(
                  fontSize: 42,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            )
          ],
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconInkWell(
                    const Icon(
                      Icons.logout,
                      size: 38,
                      color: Colors.white,
                    ),
                    () async {
                      if (await (yesNoDialog(
                          context, "Are you sure to logout?"))) {
                        StoreKeyValue.removeData('token');
                        StoreKeyValue.removeData('email');
                        Navigator.of(context).pop();
                      }
                    },
                  )),
            ],
          ),
        )
      ]),
      color: Colors.orange,
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('HOME DISPOSING!!!!!!!!!!!!');
    widget.myStompClient.stompClient.deactivate();
  }

  var index=0,max=0;

  Future<void> sendMessage(Socket socket, String message) async {
    print('Client: $message');
    socket.write(message);
  }

  @override
  void initState() {
    super.initState();


    // Future.delayed(Duration.zero,()async{
    //   print('vado');
    //   final socket = await Socket.connect('192.168.56.1', 80);
    //   print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
    //
    //   // listen for responses from the server
    //   // socket.listen(
    //   //
    //   //   // handle data from the server
    //   //       (Uint8List data) {
    //   //     final serverResponse = String.fromCharCodes(data);
    //   //     print('Server: $serverResponse');
    //   //   },
    //   //
    //   //   // handle errors
    //   //   onError: (error) {
    //   //     print(error);
    //   //     socket.destroy();
    //   //   },
    //   //
    //   //   // handle server ending connection
    //   //   onDone: () {
    //   //     print('Server left.');
    //   //     socket.destroy();
    //   //   },
    //   // );
    //
    // });


    Future.delayed(const Duration(milliseconds: 0), () async {
      var token = await StoreKeyValue.readStringData('token');
      setState(() {
        Home.token = token;
      });
      requestData(context, HttpType.get, '/login',
          {'token': Home.token, 'imTheClient': 'true'});
      poolingImOnline();

      //===Here's the best part!==================================================
      widget.myStompClient = MyStompClient(Home.token, onConnect: (stompFrame) {
        sendOnline();
        print('connetto il socket!...');
        widget.myStompClient.subscribeOnline(stompFrame, (map) {
          bool state = map['online'].toString().toLowerCase() == 'true';
          setState(() {
            widget.pcStatus[map['pcName']] = state;
            // print(widget.pcStatus);
          });
          if (Home.pcManagerState?.mounted ?? false) {
            Home.pcManagerState?.setState(() {
              Home.pcManagerState?.widget.online = state;
              // print(Home.pcManagerState?.widget.online);
            });
          }
        });

        widget.myStompClient.subscribeMessage(stompFrame, (map) {
          // if(Home.stopListenOnMessage){
          //   return;
          // }
          // log(map['message'].split('@@@')[0]);
          // log('msg--->'+map['message']);
          // log('len--->'+map['message'].toString().length.toString());
          // log('match--->'+'1'.allMatches(map['message'].toString()).length.toString());
          sleep(const Duration(microseconds:1800));

         if((DateTime.now().difference(lastMessage).inMilliseconds>3000)) {
           log('RESETTO==================================================================');
           index=0;
         }
          lastMessage = DateTime.now();

          if (index == 0) {
            log('index == 0');
            messageBuffer=StringBuffer();
            // index=int.parse(map['message'].split('@@@')[1]);
            messageStart = DateTime.now();
            if(map['message'].split('@@@')[0]=='START_OF_MESSAGE'){
              log('[START_OF_MESSAGE] received');
              log(map['message']);
              header=map['message'].split('@@@')[1];
              max = int.parse(map['message'].split('@@@')[2]);
              log('max--->$max');
              index++;
              return;
            }
          }
          // log(((10000 * index ~/ max) / 100).toString()+'%');



          // if(map['message'].split('@@@')[0].contains('FILE_FROM_SERVER')){
          //   if((DateTime.now().difference(lastSnackbar).inMilliseconds>1000)) {
          //     lastSnackbar=DateTime.now();
          //     SnackBarGenerator.makeSnackBar(
          //         context, 'Incoming file... ${(10000 * index ~/ max) / 100}',
          //         color: Colors.teal.shade300);
          //   }
          // }

          // var startr=DateTime.now();
          // message+=map['message'];
          messageBuffer.write(map['message']);
          // messageBuffer.write(map['message'].split('@@@')[3]);
          // message+=map['message'];
          // times.add((DateTime.now().difference(startr).inMicroseconds/1000));
          // log((times.reduce((a, b) => a+b)/times.length).toString());

         log(index.toString());
          if(index==max) {
            log(messageBuffer.length.toString()+'===================================');
            index=0;

            if (header == "STREAMING") {
              Uint8List image;
              try{
                image=base64Decode(messageBuffer.toString());
              }catch(e){
                return;
              }
              Home.pcManagerState?.myKeyboardListener?.setState(() {
                Home.pcManagerState?.myKeyboardListener?.base64Image =
                    image;
                Future.delayed(const Duration(milliseconds: 200),(){
                  Home.pcManagerState?.myKeyboardListener?.oldImage =
                      image;
                });
              });
            }

            else if (header == "WEBCAM") {
              Uint8List image;
              try{
                image=base64Decode(messageBuffer.toString());
              }catch(e){
                return;
              }
              Home.pcManagerState?.webcamStreaming?.setState(() {
                Home.pcManagerState?.webcamStreaming?.frame = image;
                var lap=Home.pcManagerState?.webcamStreaming?.lastSpeed??50;
                Future.delayed(Duration(milliseconds: 130-lap),(){
                  Home.pcManagerState?.webcamStreaming?.oldImage =
                      image;
                });
              });
            }

            else if (header == "TASK_MANAGER") {
              log('TASK_MANAGER');
              var windows=messageBuffer.toString().split('#');

              List<String> windowsTitle = [];
              List<Uint8List?> windowsIcon = [];
              List<ProcessBox> windowsProcessBox=[];

              for (var window in windows){
                if(window=='' ||window.split('~').length<2) {
                  continue;
                }
                windowsTitle.add(window.split('~')[0]);
                Uint8List? image;
                try{
                  image=base64Decode(window.split('~')[1]);
                }catch(e){
                }
                windowsIcon.add(image);

                windowsProcessBox.add(
                    ProcessBox(
                        window.split('~')[0],
                        image==null?null:Image.memory(image))
                );
              }
              Home.pcManagerState?.setState(() {
                Home.pcManagerState?.taskManagerLoading = false;
              });

              bool todo=Home.pcManagerState?.widget.windowsTitle.isEmpty??true;
              for(String str in Home.pcManagerState?.widget.windowsTitle??[]){
                if(!windowsTitle.contains(str)){
                  todo=true;
                }
              }
              if(!todo){
                return;
              }

              Home.pcManagerState?.setState(() {
                Home.pcManagerState?.widget.windowsTitle=windowsTitle;
                Home.pcManagerState?.widget.windowsIcon=windowsIcon;
                Home.pcManagerState?.widget.windows=windowsProcessBox;
              });
            }

            else if (header == "CLIPBOARD_IMAGE") {
              log('SHARE_CLIPBOARD_IMAGE');
              Uint8List? image;
              try{
                image=base64Decode(messageBuffer.toString());
              }catch(e){
                print('err');
                return;
              }
              StoreKeyValue.writeImage(image, 'SharedImage ${
                  DateFormat('yyyy-MM-dd HH-mm-ss').format(DateTime.now())}.jpg');
              // SnackBarGenerator.makeSnackBar(context, 'Pc screenshot saved to gallery!',color: Colors.amber.shade600);
            }

            else if (header == "CLIPBOARD_IMAGE"){
              Clipboard.setData(ClipboardData(text: messageBuffer.toString()));
            }

            else if (header.toString().contains('FILE_FROM_SERVER')) {
              log('FILE_FROM_SERVER');
              String fileName=header.split(':')[1].split('.')[0];
              String fileExtension=header.split(':')[1].split('.')[1];
              Uint8List? file;
              try{
                file=base64Decode(messageBuffer.toString());
              }catch(e){
                print('err--->'+e.toString());
                return;
              }
              StoreKeyValue.writeFile(file,fileName,fileExtension);
              // SnackBarGenerator.makeSnackBar(context, 'Pc screenshot saved to gallery!',color: Colors.amber.shade600);
            }

            print('[$header] receiverd, took ---> ${(DateTime.now().difference(messageStart).inMicroseconds/1000)} millis');
            index=0;
          }
          else{
          index++;
          }

        });


        widget.myStompClient.subscribeStatusCallbacks.forEach((key, value) {
            widget.myStompClient.subscribeStatus(key, value);
        });

      });
      widget.myStompClient.stompClient.activate();
      //==========================================================================
      await getPcList(context);
      setState(() {
        widget.isLoading = false;
      });

      var lastPc=await StoreKeyValue.readStringData('lastPc');
      print('lastPc=$lastPc');
      if(lastPc!=''){
        var index=0;
        for(var pc in widget.pcListWidget){
          if(pc.runtimeType==PcItem && (pc as PcItem).pcName==lastPc){
            PcManager.token = Home.token;
            PcManager.myStompClient = widget.myStompClient;
            Navigator.pushNamed(context, '/pcManager', arguments: [
              lastPc,
              widget.pcMaxWattage[index ],
              widget.pcBatteryCapacity[index ],
              widget.pcStatus[lastPc].toString()
            ]);
          }
          index++;
        }
      }
    });
  }

  Future<void> getPcList(BuildContext context) async {
    setState(() {
      widget.pcListWidget = [];
    });
    final response = await requestData(context, HttpType.get, '/login',
        {'token': Home.token, 'imTheClient': 'true'});

    if (response.keys.isNotEmpty) {
      if (response['result'].toString().contains('user present in database!')) {
        var pcList = response['user']['pcList'];

        for (var pc in pcList) {
          widget.pcNames.add(pc['name']);
          widget.pcMaxWattage.add(pc['maxWattage'].toString());
          widget.pcBatteryCapacity.add(pc['batteryCapacityMw'].toString());
          widget.pcStatus[pc['name']] = false;
          var pcItem = PcItem(pc['name'], widget.pcStatus[pc['name']] ?? false);
          setState(() {
            widget.pcListWidget.add(pcItem);
          });
        }

        if (widget.pcListWidget.isEmpty) {
          widget.pcListWidget.add(Padding(
            padding: EdgeInsets.all(adjustSizeHorizontally(context, 40.0)),
            child: Text(
              "Nothing to show. You can add a pc installing "
              "MrPowerManager server on it and validate the code using the button below.",
              style: GoogleFonts.lato(
                  fontSize: adjustSizeHorizontally(context, 24)),
              textAlign: TextAlign.center,
            ),
          ));
        }
      } else {
        StoreKeyValue.removeData('token');
        StoreKeyValue.removeData('email');
        SnackBarGenerator.makeSnackBar(
            context, "This account was deleted! Restart the app",
            color: Colors.red);
      }
    } else {
      SnackBarGenerator.makeSnackBar(context, 'Failed to contact the server');
    }
  }

  poolingImOnline() async {
    Future.delayed(const Duration(seconds: 5), () {
      try{
      sendOnline();
      }
      catch(e){
        log('Could not sent online ---> '+e.toString());
      }
/*
      requestData(context, HttpType.get, '/login',
          {'token': Home.token, 'imTheClient': 'true'});
*/
      // print('Im online sent!');
      poolingImOnline();
    });
  }


  sendOnline(){
    // log('mandato l-online al server!');
      widget.myStompClient.stompClient.send(
          destination: "/app/setOnline/${PcManager.token}", body: 'true');
  }
}

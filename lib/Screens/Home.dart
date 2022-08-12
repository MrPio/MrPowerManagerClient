import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  static PcManagerState? pcManagerState;
  late final MyStompClient myStompClient;
  List<Widget> pcListWidget = [];
  List<Widget> shimmerPcListWidget = [];
  static String token = '';
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
    widget.myStompClient.stompClient.deactivate();
  }

  poolingImOnline() async {
    Future.delayed(const Duration(seconds: 30), () {
      requestData(context, HttpType.get, '/login',
          {'token': Home.token, 'imTheClient': 'true'});
      print('Im online sent!');
      poolingImOnline();
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 50), () async {
      var token = await StoreKeyValue.readStringData('token');
      setState(() {
        Home.token = token;
      });
      requestData(context, HttpType.get, '/login',
          {'token': Home.token, 'imTheClient': 'true'});
      poolingImOnline();

      //===Here's the best part!==================================================
      widget.myStompClient = MyStompClient(Home.token, onConnect: (stompFrame) {
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
}

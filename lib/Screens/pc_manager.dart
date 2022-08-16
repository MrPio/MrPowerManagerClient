import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mr_power_manager_client/Pages/passwords_list.dart';
import 'package:mr_power_manager_client/Screens/keyboard_listner.dart';
import 'package:mr_power_manager_client/Screens/wattage_consumption.dart';
import 'package:mr_power_manager_client/Screens/webcam_streaming.dart';
import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';
import 'package:mr_power_manager_client/Utils/size_adjustaments.dart';
import 'package:mr_power_manager_client/Widgets/process_box.dart';

import '../Pages/input_dialog.dart';
import '../Styles/background_gradient.dart';
import '../Styles/commands.dart';
import '../Utils/SnackbarGenerator.dart';
import '../Utils/api_request.dart';
import '../Utils/small_utils.dart';
import '../Widgets/command_shape.dart';
import '../Widgets/element_circular_status.dart';
import '../Widgets/large_command_shape.dart';
import 'Home.dart';

class WattageValues {
  List<double> watts = [];
  List<double> cpus = [];
  List<double> gpus = [];
  List<double> rams = [];
  List<double> disks = [];
  List<double> temps = [];
  List<double> means = [0, 0, 0, 0, 0, 0];
  double todayMaxWattage = 100;
  double todayWattHour = 0;
  double todayWattHourEstimated = 0;

  WattageValues() {
    watts = List.filled(WattageConsumptionChartState.intervals[2], 0.0,
        growable: true);
    cpus = List.filled(WattageConsumptionChartState.intervals[2], 0.0,
        growable: true);
    gpus = List.filled(WattageConsumptionChartState.intervals[2], 0.0,
        growable: true);
    rams = List.filled(WattageConsumptionChartState.intervals[2], 0.0,
        growable: true);
    disks = List.filled(WattageConsumptionChartState.intervals[2], 0.0,
        growable: true);
    temps = List.filled(WattageConsumptionChartState.intervals[2], 0.0,
        growable: true);
  }
}

class PcManager extends StatefulWidget {
  PcManager({Key? key}) : super(key: key);

  static WattageValues wattageValues24h = WattageValues();
  static WattageValues wattageValues4h = WattageValues();
  static WattageValues wattageValues1m = WattageValues();
  static MyStompClient? myStompClient;

  static String token = '';
  String pcName = "i7-10750H";
  int maxWattage = 0;
  int batteryCapacity = 0;
  double headerReduction = 0;
  bool isLoading = true;
  Color headerColor = Colors.blue[500] ?? Colors.grey;

  bool online = false;
  int volume = 0,
      backupVolume = 0,
      brightness = 0,
      battery = 0,
      batteryMinutes = 0,
      cpuUsage = 0,
      gpuUsage = 0,
      gpuTemp = 40,
      ramUsage = 0,
      diskUsage = 0,
      redLightLevel = 0,
      currentWattage = 0;
  var passwords = [];

  bool wifi = true,
      bluetooth = true,
      batteryPlugged = true,
      airplane = true,
      mute = true,
      redLight = true,
      saveBattery = true,
      hotspot = true,
      isLock = false;
  double opacityTop = 1, opacityBottom = 0;
  DateTime lastStatusEditedByClient = DateTime.fromMicrosecondsSinceEpoch(0);
  List<String> windowsTitle = [];
  List<String> lastWindowsTitle = [];
  List<Uint8List?> windowsIcon = [];
  List<ProcessBox> windows=[];

  bool wattsActive = false;
  bool cpusActive = false;
  bool gpusActive = false;
  bool ramsActive = false;
  bool disksActive = false;
  bool tempsActive = false;

  @override
  PcManagerState createState() => PcManagerState();
}

class PcManagerState extends State<PcManager>
    with SingleTickerProviderStateMixin {
  ScrollController listviewController = ScrollController();
  ScrollController listviewController2 = ScrollController();
  PageController pageController = PageController(initialPage: 0);
  MyKeyboardListenerState? myKeyboardListener;
  WebcamStreamingState? webcamStreaming;

  late AnimationController _FABController;
  bool _FABexpanded = false;
  static bool disposed = false;
  var _currentIndex = 0;
  FloatingActionButton? FAB;
  bool manuallySet = false;
  var deleteOpacity = 0.0;
  PasswordsListState? passwordsListState;
  int requestWattageDataCalled = 0;
  bool nestScroll = true;

  var passwordsList = PasswordsList(Colors.lightBlue);

  static bool passwordPaste = false;

  int lastQuality = 50;

  bool calledNavigator = false;

  bool taskManagerLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.pcName =
        (ModalRoute.of(context)!.settings.arguments as List<String>)[0]; //TODO
    widget.maxWattage = int.parse(
        (ModalRoute.of(context)!.settings.arguments as List<String>)[1]); //TODO
    widget.batteryCapacity = int.parse(
        (ModalRoute.of(context)!.settings.arguments as List<String>)[2]); //TODO
    widget.online =
        (ModalRoute.of(context)!.settings.arguments as List<String>)[3]
                .toLowerCase() ==
            'true'; //TODO

    //subscribe socket
    if (PcManager.myStompClient?.unsubscribe.keys.contains(widget.pcName) ??
        false) {
      PcManager.myStompClient?.unsubscribe[widget.pcName] = false;
    } else {
      var callback = (map) {
        Home.pcManagerState?.setState(() {
          var widget = Home.pcManagerState?.widget ?? this.widget;
          if ((DateTime.now().difference(widget.lastStatusEditedByClient))
                  .inSeconds <=
              2) {
            return;
          }
          // widget.pcState = getState(map['state']);
          widget.battery = (map['batteryPerc'] as int);
          widget.volume = (map['sound'] as int);
          widget.brightness = (map['brightness'] as int);
          widget.batteryMinutes = (map['batteryMinutes'] as int);
          widget.cpuUsage = (map['cpuLevel'] as int);
          widget.gpuUsage = (map['gpuLevel'] as int);
          widget.gpuTemp = (map['gpuTemp'] as int);
          widget.ramUsage = (map['ramLevel'] as int);
          widget.diskUsage = (map['storageLevel'] as int);
          widget.currentWattage = (map['wattage'] as int);
          // print('wattage new = ${map['wattage']}');

          widget.redLightLevel = (map['redLightLevel'] as int);

          widget.wifi = map['wifi'].toString().toLowerCase() == 'true';
          widget.bluetooth =
              map['bluetooth'].toString().toLowerCase() == 'true';
          widget.batteryPlugged =
              map['batteryPlugged'].toString().toLowerCase() == 'true';
          widget.airplane = map['airplane'].toString().toLowerCase() == 'true';
          widget.mute = map['mute'].toString().toLowerCase() == 'true';
          widget.redLight = map['redLight'].toString().toLowerCase() == 'true';
          widget.saveBattery =
              map['saveBattery'].toString().toLowerCase() == 'true';
          widget.hotspot = map['hotspot'].toString().toLowerCase() == 'true';
          widget.isLock = map['locked'].toString().toLowerCase() == 'true';

          var w1m = PcManager.wattageValues1m;

          w1m.watts.removeAt(0);
          w1m.watts.add(widget.currentWattage.toDouble());
          w1m.cpus.removeAt(0);
          w1m.cpus.add(widget.cpuUsage.toDouble());
          w1m.gpus.removeAt(0);
          w1m.gpus.add(widget.gpuUsage.toDouble());
          w1m.rams.removeAt(0);
          w1m.rams.add(widget.ramUsage.toDouble());
          w1m.disks.removeAt(0);
          w1m.disks.add(widget.diskUsage.toDouble());
          w1m.temps.removeAt(0);
          w1m.temps.add(widget.gpuTemp.toDouble());

          w1m.means = [
            w1m.watts.map((e) => e).reduce((a, b) => a + b) /
                w1m.watts.where((element) => element != 0).length,
            w1m.cpus.map((e) => e).reduce((a, b) => a + b) /
                w1m.cpus.where((element) => element != 0).length,
            w1m.gpus.map((e) => e).reduce((a, b) => a + b) /
                w1m.gpus.where((element) => element != 0).length,
            w1m.rams.map((e) => e).reduce((a, b) => a + b) /
                w1m.rams.where((element) => element != 0).length,
            w1m.disks.map((e) => e).reduce((a, b) => a + b) /
                w1m.disks.where((element) => element != 0).length,
            w1m.temps.map((e) => e).reduce((a, b) => a + b) /
                w1m.temps.where((element) => element != 0).length,
          ];

          w1m.todayWattHour =
              w1m.watts.map((e) => e).reduce((a, b) => a + b) / 3600;
        });
      };
      PcManager.myStompClient?.subscribeStatusCallbacks[widget.pcName] =
          callback;
      PcManager.myStompClient?.subscribeStatus(widget.pcName, callback);
    }
  }

  @override
  Widget build(BuildContext context) {
    var headerBottomScale = adjustSizeHorizontally(context, 0.74);

    var FABchilds = [
      RotationTransition(
        turns: Tween(begin: -0.5, end: 0.5).animate(_FABController),
        child: Icon(
          Icons.arrow_downward,
          size: adjustSizeVertically(context, 38),
        ),
      ),
      Container(),
      Container(),
      Icon(
        Icons.key,
        size: adjustSizeVertically(context, 38),
      ),
      Container(),
    ];

    var FABcolors = [
      [Colors.blue[900], Colors.blue, Colors.white],
      [Colors.red[800], Colors.redAccent[100], Colors.white],
      [Colors.white, Colors.white, Colors.white],
      [Colors.deepOrange[800], Colors.amber[600], Colors.white],
      [Colors.white, Colors.white, Colors.white],
    ];

    var FABonPress = [
      () {
        manuallySet = false;
        var span = adjustSizeVertically(context, 60);
        var minHeight = adjustSizeVertically(context, 70);
        if (listviewController.offset < (span + minHeight) / 3) {
          listviewController.animateTo(999,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn);
        } else if (listviewController.offset > 2 * (span + minHeight) / 3) {
          listviewController.animateTo(0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn);
        }
      },
      () {},
      () {},
      () async {
        var key =
            await PasswordsListState.requestPassword(context, widget.pcName);
        if (key != '') {
          passwordsListState?.getKeys();
          scheduleRefresh();
        }
      },
      () {},
    ];

    FAB = FloatingActionButton(
      splashColor: FABcolors[_currentIndex][0],
      backgroundColor: FABcolors[_currentIndex][1],
      foregroundColor: FABcolors[_currentIndex][2],
      child: FABchilds[_currentIndex],
      onPressed: FABonPress[_currentIndex],
    );

    var screens = [
      controlScreen(),
      taskManagerScreen(),
      chartsScreen(),
      passwordsScreen(),
      remoteControlScreen(),
    ];

    return Container(
      decoration: getBackgroundGradient(),
      child: Scaffold(
        body: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          backgroundColor: Colors.white,
          color: Colors.black,
          strokeWidth: 3.5,
          // displacement: 70,
          // edgeOffset: -30,
          notificationPredicate: (notification) {
            // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
            return notification.depth == 1;
          },
          onRefresh: () async {
            // SnackBarGenerator.makeSnackBar(context, "Reloading status...",
            //     color: Colors.amber, millis: 700);
            refresh();
            await Future.delayed(
              const Duration(milliseconds: 500),
              () {},
            );
          },
          child: Stack(
            children: [
              NestedScrollView(
                controller: listviewController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                        backgroundColor: widget.headerColor,
                        title: const Text(''),
                        pinned: true,
                        floating: false,
                        stretch: true,
                        forceElevated: innerBoxIsScrolled,
                        expandedHeight: adjustSizeVertically(
                          context,
                          nestScroll ? 270 : 116,
                        ),
                        toolbarHeight: adjustSizeVertically(context, 116),
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(18, 12)),
                        ),
                        flexibleSpace: Stack(
                          children: [
                            widget.opacityTop < 0.01
                                ? Container()
                                : Opacity(
                                    opacity: widget.opacityTop,
                                    child: ListView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        reverse: true,
                                        children: [
                                          SizedBox(
                                            height: 280,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        widget.online
                                                            ? 'online'
                                                            : '',
                                                        style: GoogleFonts.lato(
                                                          fontSize: 20,
                                                          color: Colors.green,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.circle,
                                                            color: widget.online
                                                                ? Colors.green
                                                                : Colors.red,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            widget.pcName,
                                                            style: GoogleFonts.lato(
                                                                fontSize: 30,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
/*                      ElevatedButton(
                                           child: Padding(
                                             padding: const EdgeInsets.all(6.0),
                                             child: Text(
                                               widget.pcName,
                                               style: GoogleFonts.lato(fontSize: 26,color: Colors.white),
                                               textAlign: TextAlign.center,
                                             ),
                                           ),
                                           style: ElevatedButton.styleFrom(
                                             elevation: 0,
                                             primary: Colors.black?.withOpacity(0.07),
                                             onPrimary: Colors.white,
                                             shadowColor: Colors.white.withOpacity(0.1),

                                             shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.circular(20.0),
                                             ),
                                           ), onPressed: () {  },
                                         ),*/
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      ElementCircularState(
                                                          widget.volume < 33
                                                              ? Icons
                                                                  .volume_mute
                                                              : widget.volume <
                                                                      67
                                                                  ? Icons
                                                                      .volume_down
                                                                  : Icons
                                                                      .volume_up,
                                                          widget.volume
                                                              .toString(),
                                                          Colors.blue,
                                                          () async {
                                                        final value =
                                                            await showDialog<
                                                                int>(
                                                          context: context,
                                                          builder: (context) =>
                                                              sliderDialog(
                                                            "Give me the value to send:",
                                                            widget.volume,
                                                            25,
                                                            Icons.volume_up,
                                                          ),
                                                        );
                                                        if (value == null) {
                                                          return;
                                                        }
                                                        setState(() {
                                                          widget.volume = value;
                                                        });
                                                        sendCommand(
                                                            null,
                                                            Commands.SOUND_VALUE
                                                                .name,
                                                            value: value);
                                                      }),
                                                      ElementCircularState(
                                                          widget.brightness < 50
                                                              ? Icons
                                                                  .wb_sunny_outlined
                                                              : Icons.wb_sunny,
                                                          widget.brightness
                                                              .toString(),
                                                          Colors.amber,
                                                          () async {
                                                        final value =
                                                            await showDialog<
                                                                int>(
                                                          context: context,
                                                          builder: (context) =>
                                                              sliderDialog(
                                                            "Give me the value to send:",
                                                            widget.brightness,
                                                            10,
                                                            Icons.wb_sunny,
                                                          ),
                                                        );
                                                        if (value == null) {
                                                          return;
                                                        }
                                                        setState(() {
                                                          widget.brightness =
                                                              value;
                                                        });
                                                        sendCommand(
                                                            null,
                                                            Commands
                                                                .BRIGHTNESS_VALUE
                                                                .name,
                                                            value: value);
                                                      }),
                                                      ElementCircularState(
                                                          widget.batteryPlugged
                                                              ? Icons
                                                                  .battery_charging_full
                                                              : Icons
                                                                  .battery_full,
                                                          widget.battery
                                                              .toString(),
                                                          Colors.green,
                                                          () async {
                                                        SnackBarGenerator.makeSnackBar(
                                                            context,
                                                            widget.batteryMinutes ==
                                                                    0
                                                                ? "Your battery is currently charging"
                                                                : "Battery left: ${widget.batteryMinutes} minutes.",
                                                            color:
                                                                Colors.green);
                                                      }),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElementCircularState(
                                                        Icons.memory,
                                                        widget.cpuUsage
                                                            .toString(),
                                                        Colors.deepOrangeAccent,
                                                        () async {
                                                          SnackBarGenerator
                                                              .makeSnackBar(
                                                                  context,
                                                                  "the CPU usage is ${widget.cpuUsage}%",
                                                                  color: Colors
                                                                      .deepOrangeAccent);
                                                        },
                                                        scale: 0.6,
                                                        text: "CPU",
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      ElementCircularState(
                                                        widget.gpuTemp > 75
                                                            ? Icons
                                                                .device_thermostat
                                                            : Icons
                                                                .bar_chart_outlined,
                                                        widget.gpuUsage
                                                            .toString(),
                                                        widget.gpuTemp > 75
                                                            ? Colors.redAccent
                                                            : Colors.pinkAccent,
                                                        () async {
                                                          SnackBarGenerator.makeSnackBar(
                                                              context,
                                                              "the GPU usage is ${widget.gpuUsage}%, the temp is ${widget.gpuTemp}°C",
                                                              color: widget
                                                                          .gpuTemp >
                                                                      75
                                                                  ? Colors
                                                                      .redAccent
                                                                  : Colors
                                                                      .pinkAccent);
                                                        },
                                                        scale: 0.6,
                                                        text: "GPU",
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      ElementCircularState(
                                                        Icons.workspaces_filled,
                                                        widget.ramUsage
                                                            .toString(),
                                                        Colors.purpleAccent[
                                                                100] ??
                                                            Colors.purpleAccent,
                                                        () async {
                                                          SnackBarGenerator.makeSnackBar(
                                                              context,
                                                              "the RAM usage is ${widget.ramUsage}%",
                                                              color: Colors
                                                                          .purpleAccent[
                                                                      100] ??
                                                                  Colors
                                                                      .purpleAccent);
                                                        },
                                                        scale: 0.6,
                                                        text: "RAM",
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      ElementCircularState(
                                                        Icons.storage,
                                                        widget.diskUsage
                                                            .toString(),
                                                        Colors.teal[300] ??
                                                            Colors.teal,
                                                        () async {
                                                          SnackBarGenerator.makeSnackBar(
                                                              context,
                                                              "the DISK usage is ${widget.diskUsage}%",
                                                              color: Colors
                                                                          .teal[
                                                                      300] ??
                                                                  Colors.teal);
                                                        },
                                                        scale: 0.6,
                                                        text: "DISK",
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ),
                            widget.opacityBottom < 0.01
                                ? Container()
                                : Opacity(
                                    opacity: widget.opacityBottom,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          widget.online ? 'online' : '',
                                          style: GoogleFonts.lato(
                                            fontSize: 20,
                                            color: Colors.green,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: widget.online
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              widget.pcName,
                                              style: GoogleFonts.lato(
                                                  fontSize: 30,
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              adjustSizeVertically(context, 6),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElementCircularState(
                                                widget.volume < 33
                                                    ? Icons.volume_mute
                                                    : widget.volume < 67
                                                        ? Icons.volume_down
                                                        : Icons.volume_up,
                                                widget.volume.toString(),
                                                Colors.blue, () async {
                                              final value =
                                                  await showDialog<int>(
                                                context: context,
                                                builder: (context) => sliderDialog(
                                                    "Give me the value to send:",
                                                    widget.volume,
                                                    20,
                                                    Icons.volume_up),
                                              );
                                              if (value == null) {
                                                return;
                                              }
                                              setState(() {
                                                widget.volume = value;
                                              });
                                              sendCommand(null,
                                                  Commands.SOUND_VALUE.name,
                                                  value: value);
                                            },
                                                scale: headerBottomScale,
                                                strict: true),
                                            ElementCircularState(
                                                widget.brightness < 50
                                                    ? Icons.wb_sunny_outlined
                                                    : Icons.wb_sunny,
                                                widget.brightness.toString(),
                                                Colors.amber, () async {
                                              final value =
                                                  await showDialog<int>(
                                                context: context,
                                                builder: (context) =>
                                                    sliderDialog(
                                                  "Give me the value to send:",
                                                  widget.brightness,
                                                  10,
                                                  Icons.wb_sunny,
                                                ),
                                              );
                                              if (value == null) {
                                                return;
                                              }
                                              setState(() {
                                                widget.brightness = value;
                                              });
                                              sendCommand(
                                                  null,
                                                  Commands
                                                      .BRIGHTNESS_VALUE.name,
                                                  value: value);
                                            },
                                                scale: headerBottomScale,
                                                strict: true),
                                            ElementCircularState(
                                              widget.batteryPlugged
                                                  ? Icons.battery_charging_full
                                                  : Icons.battery_full,
                                              widget.battery.toString(),
                                              Colors.green,
                                              () async {
                                                SnackBarGenerator.makeSnackBar(
                                                    context,
                                                    widget.batteryMinutes == 0
                                                        ? "Your battery is currently charging"
                                                        : "Battery left: ${widget.batteryMinutes} minutes.",
                                                    color: Colors.green);
                                              },
                                              scale: headerBottomScale,
                                              strict: true,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            ElementCircularState(
                                                Icons.memory,
                                                widget.cpuUsage.toString(),
                                                Colors.deepOrangeAccent,
                                                () async {
                                              SnackBarGenerator.makeSnackBar(
                                                  context,
                                                  "the CPU usage is ${widget.cpuUsage}%",
                                                  color:
                                                      Colors.deepOrangeAccent);
                                            },
                                                scale: headerBottomScale,
                                                strict: true),
                                            ElementCircularState(
                                                widget.gpuTemp > 75
                                                    ? Icons.device_thermostat
                                                    : Icons.bar_chart_outlined,
                                                widget.gpuUsage.toString(),
                                                widget.gpuTemp > 75
                                                    ? Colors.redAccent
                                                    : Colors.pinkAccent,
                                                () async {
                                              SnackBarGenerator.makeSnackBar(
                                                  context,
                                                  "the GPU usage is ${widget.gpuUsage}%, the temp is ${widget.gpuTemp}°C",
                                                  color: widget.gpuTemp > 75
                                                      ? Colors.redAccent
                                                      : Colors.pinkAccent);
                                            },
                                                scale: headerBottomScale,
                                                strict: true),
                                            ElementCircularState(
                                                Icons.workspaces_filled,
                                                widget.ramUsage.toString(),
                                                Colors.purpleAccent[100] ??
                                                    Colors.purpleAccent,
                                                () async {
                                              SnackBarGenerator.makeSnackBar(
                                                  context,
                                                  "the RAM usage is ${widget.ramUsage}%",
                                                  color: Colors
                                                          .purpleAccent[100] ??
                                                      Colors.purpleAccent);
                                            },
                                                scale: headerBottomScale,
                                                strict: true),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              adjustSizeVertically(context, 6),
                                        )
                                      ],
                                    ),
                                  ),
                          ],
                        )),
                  ];
                },
                body: Stack(
                  children: [
                    ListView(
                      controller: listviewController2,
                      children: [
                        screens[_currentIndex],
                      ],
                    ),
                    taskManagerLoading&&_currentIndex==1?
                    Center(
                      child: Container(
                        decoration:  BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(22)),
                            color: Colors.black.withOpacity(0.46)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                strokeWidth: 6,
                                color: Colors.blue,
                              ),
                              SizedBox.fromSize(size: const Size(0,16),),
                              Text('Loading...',style: GoogleFonts.lato(fontSize: 16),)
                            ],
                          ),
                        ),
                      ),
                    ):Container(),
                  ],
                ),
              ),
              _currentIndex == 3
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          color: Colors.black.withOpacity(0.48),
                          height: 60,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 28,
                              ),
                              SizedBox(
                                child: Transform.scale(
                                  scale: 1.45,
                                  child: Switch(
                                    onChanged: (bool value) {
                                      setState(() => passwordPaste = value);
                                    },
                                    value: passwordPaste,
                                    activeColor: Colors.amberAccent,
                                    hoverColor: Colors.white,
                                    activeTrackColor:
                                        Colors.amber.withOpacity(0.34),
                                    inactiveThumbColor: Colors.lightBlue,
                                    inactiveTrackColor:
                                        Colors.blue.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(passwordPaste ? 'Paste' : 'Copy',
                                  style: GoogleFonts.lato(
                                      fontSize: 22,
                                      color: passwordPaste
                                          ? Colors.amber.shade100
                                          : Colors.lightBlue.shade100)),
                            ],
                          ),
                        ),
                      ],
                    )
                  :
              _currentIndex==1 && ProcessBox.selected.values.contains(true)?
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fullscreen,size: 46,color: Colors.lightBlue.shade200,),
                                SizedBox.fromSize(size: const Size(0,4),),
                                Text('Bring to front',style: GoogleFonts.lato(fontSize: 18,color:Colors.lightBlue.shade200,fontWeight: FontWeight.w300),)
                              ],
                            ),
                          ),
                          splashColor: Colors.lightBlue,
                          onTap: (){
                            print(ProcessBox.selected.toString());
                            for(var title in ProcessBox.selected.keys){

                              if(ProcessBox.selected[title]??false)      {
                                print('eccomi');
                                sendCommand(null, 'WINDOW_FOCUS@@@$title',snackbar: false);
                              }
                            }
                          },
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22.0,vertical: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close,size: 46,color: Colors.redAccent.shade100,),
                                SizedBox.fromSize(size: const Size(0,4),),
                                Text('Terminate',style: GoogleFonts.lato(fontSize: 18,color: Colors.redAccent.shade100,fontWeight: FontWeight.w300),)
                              ],
                            ),
                          ),
                          splashColor: Colors.redAccent,
                          onTap: ()async{
                                  if(! await yesNoDialog(context,'Are you sure you want to close this window?')){
                                    return;
                                  }
                                  for(var title in ProcessBox.selected.keys){
                                    if(ProcessBox.selected[title]??false)      {
                                      sendCommand(null, 'WINDOW_KILL@@@$title',snackbar: false);
                                    }
                                  }                                                                

                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ):Container(),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        floatingActionButton: SizedBox(
          width: adjustSizeVertically(context, 66),
          height: adjustSizeVertically(context, 66),
          child: _currentIndex != 1 && _currentIndex != 2 && _currentIndex != 4 ? FAB : Container(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[700],
          backgroundColor: Colors.grey[900],
          iconSize: 30,
          showUnselectedLabels: false,
          unselectedIconTheme: const IconThemeData(size: 28),
          currentIndex: _currentIndex,
          onTap: (_index) {
            setState(() {
              _currentIndex = _index;

              if (_currentIndex == 2) {
                scheduleWattageData();
              }
              if(_currentIndex==1){
                taskManagerLoading=true;
              }
              if (_currentIndex != 0) {
                Future.delayed(const Duration(milliseconds: 740), () {
                  if (_currentIndex != 0) {
                    setState(() {
                      nestScroll = false;
                    });
                  }
                });
                if (!_FABexpanded) {
                  FAB?.onPressed!();
                }
              } else {
                setState(() {
                  nestScroll = true;
                });
                listviewController.animateTo(0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              }
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0
                  ? Icons.dashboard
                  : Icons.dashboard_outlined),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 1
                  ? Icons.list_alt
                  : Icons.list_alt_outlined),
              label: "TaskManager",
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2
                  ? Icons.bar_chart
                  : Icons.bar_chart_outlined),
              label: "Charts",
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 3 ? Icons.key : Icons.key_outlined),
              label: "Passwords",
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 4
                  ? Icons.settings_remote_outlined
                  : Icons.settings_remote),
              label: "Remote control",
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    disposed = true;
    listviewController.dispose();
    listviewController2.dispose();
    PcManager.myStompClient?.unsubscribe[widget.pcName] = true;
    StoreKeyValue.removeData('lastPc');
  }

  @override
  void initState() {
    super.initState();
    Home.pcManagerState = this;
    disposed = false;

    setState(() {
      widget.headerColor = [
        // Colors.blue[500] ?? Colors.blue,
        Colors.grey[900] ?? Colors.grey,
        // Colors.black.withOpacity(0.95),
      ][math.Random.secure().nextInt(1)];
    });
    refresh();
    // scheduleRefresh();//TODO
    requestWattageData(false);
    pollingActiveWindows();
    listviewController.addListener(() {
      var span = adjustSizeVertically(context, 60);
      var offset = listviewController.offset;
      var minHeight = adjustSizeVertically(context, 70);

      var fabExpanded = false;
      if (listviewController.offset < (span + minHeight) / 3) {
        fabExpanded = false;
      } else if (listviewController.offset > 2 * (span + minHeight) / 3) {
        fabExpanded = true;
      }

      setState(() {
        if (_FABexpanded != fabExpanded) {
          if (_FABexpanded) {
            _FABController.reverse(from: 1.0);
          } else {
            _FABController.forward(from: 0.0);
          }
          _FABexpanded = fabExpanded;
        }
        widget.opacityTop =
            math.min(1, math.max(0, 30 + span - offset) / (30 + span));
        widget.opacityBottom =
            math.min(1, math.max(0, (offset - minHeight) / span));
      });
    });
    // listviewController2.addListener(() {
    //   print(listviewController2.offset);
    //   // var span = adjustSizeVertically(context, 60);
    //   // var minHeight = adjustSizeVertically(context, 70);
    //
    //   // if(listviewController2.offset ==0 && _FABexpanded){
    //   //   FAB?.onPressed!();
    //   // }
    //   // else if(!manuallySet&&listviewController2.offset >(span + minHeight) / 3 && !_FABexpanded){
    //   //   FAB?.onPressed!();
    //   //   manuallySet=true;
    //   // }
    // });

    _FABController = AnimationController(
      duration: const Duration(milliseconds: 330),
      upperBound: 0.5,
      vsync: this,
    );

    CommandShape.pcManager = this;
    LargeCommandShape.pcManager = this;
    PasswordsList.pcManager = this;

    StoreKeyValue.saveData('lastPc', widget.pcName);
  }

  Future<void> refresh() async {
    //refresha solo le passwords
    if (disposed) {
      return;
    }
    setState(() {
      widget.isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 20), () async {
      var pcList = (await requestData(context, HttpType.get, '/login', {
        'token': await StoreKeyValue.readStringData('token'),
        'imTheClient': 'true'
      }))['user']['pcList'];
      var myPc;
      for (var pc in pcList) {
        if (pc['name'].toString() == widget.pcName) {
          myPc = pc;
        }
      }
      if (myPc == null) {
        throw ('how can the pc not be found in the list??');
      }
      if (disposed) {
        return;
      }
      setState(() {
        // widget.online = (myPc['state'].toString().toLowerCase()=='online');
        // widget.battery = int.parse(status['batteryPerc'].toString());
        // widget.volume = int.parse(status['sound'].toString());
        // widget.brightness = int.parse(status['brightness'].toString());
        // widget.batteryMinutes = int.parse(status['batteryMinutes'].toString());
        // widget.cpuUsage = int.parse(status['cpuLevel'].toString());
        // widget.gpuUsage = int.parse(status['gpuLevel'].toString());
        // widget.gpuTemp = int.parse(status['gpuTemp'].toString());
        // widget.ramUsage = int.parse(status['ramLevel'].toString());
        // widget.diskUsage = int.parse(status['storageLevel'].toString());
        // widget.currentWattage=(myPc['wattage'] as double).toInt();
        //
        // widget.redLightLevel = int.parse(status['redLightLevel'].toString());
        //
        // widget.wifi = status['wifi'].toString().toLowerCase() == 'true';
        // widget.bluetooth =
        //     status['bluetooth'].toString().toLowerCase() == 'true';
        // widget.batteryPlugged =
        //     status['batteryPlugged'].toString().toLowerCase() == 'true';
        // widget.airplane = status['airplane'].toString().toLowerCase() == 'true';
        // widget.mute = status['mute'].toString().toLowerCase() == 'true';
        // widget.redLight = status['redLight'].toString().toLowerCase() == 'true';
        // widget.saveBattery =
        //     status['saveBattery'].toString().toLowerCase() == 'true';
        // widget.hotspot = status['hotspot'].toString().toLowerCase() == 'true';
        // widget.isLock = status['locked'].toString().toLowerCase() == 'true';

        widget.passwords = [];
        for (var title in (myPc['passwords'] as Map).keys) {
          widget.passwords.add(title);
        }

        if (passwordsListState != null && passwordsListState!.mounted) {
          passwordsListState?.setState(() {});
        }

        widget.isLoading = false;
      });
    });
  }

  Future<void> scheduleRefresh() async {
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!widget.isLoading) {
        await refresh();
      }
      // scheduleRefresh();
    });
  }

  requestOneWattageDate(int intervals, int seconds, WattageValues wattageValues,
      bool justAppend) async {
    var now = DateTime.now().toUtc();

    var response =
        await requestData(context, HttpType.get, '/requestTodayWattage', {
      'token': 'MrPio',
      'pcName': 'i7-10750H',
      'intervals': '$intervals',
      'endDate': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      'durationSeconds': '$seconds',
      'onlyGpu': 'false',
      'onlyBatteryCharge': 'false',
    });

    List<FlSpot> watts = [];
    double max = requestList(response['watts'], watts);

    if (!justAppend) {
      wattageValues.watts =
          (response['watts'] as List<dynamic>).map((e) => e as double).toList();
      wattageValues.cpus =
          (response['cpus'] as List<dynamic>).map((e) => e as double).toList();
      wattageValues.gpus =
          (response['gpus'] as List<dynamic>).map((e) => e as double).toList();
      wattageValues.rams =
          (response['rams'] as List<dynamic>).map((e) => e as double).toList();
      wattageValues.disks =
          (response['disks'] as List<dynamic>).map((e) => e as double).toList();
      wattageValues.temps =
          (response['temps'] as List<dynamic>).map((e) => e as double).toList();
      ;
    } else {
      wattageValues.watts.removeAt(0);
      wattageValues.watts.add((response['watts'] as List<dynamic>).last);
      wattageValues.cpus.removeAt(0);
      wattageValues.cpus.add((response['cpus'] as List<dynamic>).last);
      wattageValues.gpus.removeAt(0);
      wattageValues.gpus.add((response['gpus'] as List<dynamic>).last);
      wattageValues.rams.removeAt(0);
      wattageValues.rams.add((response['rams'] as List<dynamic>).last);
      wattageValues.disks.removeAt(0);
      wattageValues.disks.add((response['disks'] as List<dynamic>).last);
      wattageValues.temps.removeAt(0);
      wattageValues.temps.add((response['temps'] as List<dynamic>).last);
    }

    wattageValues.todayMaxWattage = max;
    wattageValues.means = [
      wattageValues.watts.map((e) => e).reduce((a, b) => a + b) /
          wattageValues.watts.length,
      wattageValues.cpus.map((e) => e).reduce((a, b) => a + b) /
          wattageValues.cpus.length,
      wattageValues.gpus.map((e) => e).reduce((a, b) => a + b) /
          wattageValues.gpus.length,
      wattageValues.rams.map((e) => e).reduce((a, b) => a + b) /
          wattageValues.rams.length,
      wattageValues.disks.map((e) => e).reduce((a, b) => a + b) /
          wattageValues.disks.length,
      wattageValues.temps.map((e) => e).reduce((a, b) => a + b) /
          wattageValues.temps.length,
    ];
    // print('secs:$seconds');
    // print(wattageValues.means.toString());
    wattageValues.todayWattHour = response['wattHour'];
    wattageValues.todayWattHourEstimated = response['wattHourEstimated'];
  }

  Future<void> requestWattageData(bool justAppend) async {
    if (!mounted) {
      print('scappo da requestWattageData!');
      return;
    }
    var intervals = WattageConsumptionChartState.intervals;

    if (!justAppend) {
      await requestOneWattageDate(
          intervals[0], 86400, PcManager.wattageValues24h, false);
      await requestOneWattageDate(
          intervals[1], 14400, PcManager.wattageValues4h, false);
    } else {
      requestWattageDataCalled += justAppend ? 1 : 0;
      if (requestWattageDataCalled % 6 == 0) {
        await requestOneWattageDate(
            intervals[0], 86400, PcManager.wattageValues24h, true);
      }
      await requestOneWattageDate(
          intervals[1], 14400, PcManager.wattageValues4h, true);
    }

    setState(() {
      WattageConsumptionChartState.loading = false;
    });
  }

  requestList(List<dynamic> list, List<FlSpot> output) {
    int count = 0;
    double previous = 0;
    int zeroTolerance = 0;
    double max = 0;
    for (var val in list) {
      var toAdd = val as double;
      if (count < 2 && previous == 0 && list[1] != 0) {
        toAdd = list[1];
      }

      if (previous != 0 && val == 0 && zeroTolerance < 1) {
        zeroTolerance++;
        toAdd = previous;
      } else if (val != 0) {
        zeroTolerance = 0;
      }
      if (val > max) {
        max = val;
      }
      output.add(FlSpot((count++).toDouble(), toAdd));
      previous = toAdd;
    }
    return max;
  }

  Future<void> scheduleWattageData() async {
    if (_currentIndex != 1) {
      return;
    }
    Future.delayed(const Duration(seconds: 242), () async {
      // if (!widget.isLoading) {
      await requestWattageData(true);
      // }
      scheduleWattageData();
    });
  }

  /**
   * se il pc è online mando il comando tramite socket, altrimenti lo mando alla api per memorizzarlo
   */
  void sendCommand(DateTime? scheduledDate, String command,
      {int value = -1, bool snackbar = true}) async {
    var newToken = keepOnlyAlphaNum(PcManager.token);
    var newPcName = keepOnlyAlphaNum(widget.pcName);
    var formattedDate = '';
    if (scheduledDate != null) {
      scheduledDate = scheduledDate.toUtc();
      formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(scheduledDate);
    }
    if (widget.online) {
      PcManager.myStompClient?.stompClient.send(
          destination: "/app/scheduleCommand/$newToken/$newPcName",
          body: '$command~${value.toString()}~$formattedDate');

      if (snackbar) {
        SnackBarGenerator.makeSnackBar(
            context,
            command.contains('RECORD_SECONDS')
                ? 'Command sent successfully! Check your desktop to find your recording!'
                : "Command sent successfully!",
            millis: 500,
            color: Colors.amber);
      }
    } else {
      var args = {
        'token': await StoreKeyValue.readStringData('token'),
        'pcName': widget.pcName,
        'command': command
      };
      if (scheduledDate != null) {
        args.addAll({'scheduleDate': formattedDate});
      }
      if (0 <= value && value <= 100) {
        args.addAll({'value': value.toString()});
      }

      var response =
          await requestData(context, HttpType.post, '/scheduleCommand', args);
      if (response['result'].toString().contains('successfully')) {
        if (snackbar) {
          SnackBarGenerator.makeSnackBar(context, "Command sent successfully!",
              millis: 800, color: Colors.amber);
        }
      } else {
        SnackBarGenerator.makeSnackBar(context, response['result'].toString(),
            millis: 1500, color: Colors.red);
      }
    }
  }

  sendBase64(String data, String header) {
    Home.stopListenOnMessage = true;
    setState(() {});
    var BYTES_LIMIT = 14000;
    var max = data.length ~/ BYTES_LIMIT;
    var msg = '';
    for (int i = 0; i < max + 1; i++) {
      if (data.length > BYTES_LIMIT) {
        msg = header + '@@@$i@@@$max@@@' + data.substring(0, BYTES_LIMIT);
      } else {
        msg = header + '@@@$i@@@$max@@@' + data;
      }

      if (data.length > BYTES_LIMIT) {
        data = data.substring(BYTES_LIMIT);
      }
      PcManager.myStompClient?.stompClient.send(
          destination: "/app/sendMessage/${PcManager.token}/${widget.pcName}",
          body: msg);

      Home.stopListenOnMessage = false;
    }
  }

  controlScreen() {
    return Column(
      children: [
        getSilverAnimatorBox(),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          // to disable GridView's scrolling
          shrinkWrap: true,
          // You won't see infinite size error
          controller: null,
          crossAxisCount: 3,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          crossAxisSpacing: 0,
          children: [
            CommandShape(
                widget.pcName,
                Colors.deepOrange[300] ?? Colors.deepOrange,
                'Sleep',
                Icons.alarm,
                true,
                Commands.SLEEP),
            CommandShape(
                widget.pcName,
                Colors.deepOrange[400] ?? Colors.deepOrange,
                'Lock',
                Icons.lock,
                true,
                Commands.LOCK),
            CommandShape(
                widget.pcName,
                Colors.deepOrange[500] ?? Colors.deepOrange,
                'Shutdown',
                Icons.power_settings_new,
                true,
                Commands.SHUTDOWN),

            // CommandShape(
            //     widget.pcName,
            //     Colors.lightBlue[300] ?? Colors.blue,
            //     'Wifi',
            //     Icons.wifi,
            //     widget.wifi,
            //     widget.wifi ? Commands.WIFI_OFF : Commands.WIFI_ON),
            // CommandShape(
            //     widget.pcName,
            //     Colors.lightBlue[400] ?? Colors.blue,
            //     'Bluetooth',
            //     Icons.bluetooth,
            //     widget.bluetooth,
            //     widget.bluetooth
            //         ? Commands.BLUETOOTH_OFF
            //         : Commands.BLUETOOTH_ON),
            // CommandShape(
            //     widget.pcName,
            //     Colors.lightBlue[500] ?? Colors.lightBlue,
            //     'Hotspot',
            //     Icons.wifi_tethering,
            //     widget.hotspot,
            //     widget.hotspot
            //         ? Commands.HOTSPOT_OFF
            //         : Commands.HOTSPOT_ON),

            CommandShape(widget.pcName, Colors.lightGreen[300] ?? Colors.green,
                'Previous', Icons.skip_previous, true, Commands.TRACK_PREVIOUS),
            CommandShape(widget.pcName, Colors.lightGreen[400] ?? Colors.green,
                'Play/Pause', Icons.play_arrow, true, Commands.PLAY_PAUSE),
            CommandShape(widget.pcName, Colors.lightGreen[500] ?? Colors.green,
                'Next', Icons.skip_next, true, Commands.TRACK_NEXT),

            CommandShape(
                widget.pcName,
                Colors.yellow[300] ?? Colors.yellow,
                'Mute',
                Icons.volume_off,
                true,
                widget.mute ? Commands.NO_SOUND : Commands.NO_SOUND),
            //TODO
            CommandShape(widget.pcName, Colors.yellow[400] ?? Colors.yellow,
                'Sound -', Icons.volume_down, true, Commands.SOUND_DOWN),
            CommandShape(widget.pcName, Colors.yellow[500] ?? Colors.yellow,
                'Sound +', Icons.volume_up, true, Commands.SOUND_UP),

            CommandShape(
                widget.pcName,
                Colors.lightBlue[300] ?? Colors.lightBlue,
                'Hibernate',
                Icons.bedtime,
                true,
                Commands.HIBERNATE),
            CommandShape(
                widget.pcName,
                Colors.lightBlue[400] ?? Colors.lightBlue,
                'Light -',
                Icons.wb_sunny_outlined,
                true,
                Commands.BRIGHTNESS_DOWN),
            CommandShape(
                widget.pcName,
                Colors.lightBlue[500] ?? Colors.lightBlue,
                'Light +',
                Icons.wb_sunny,
                true,
                Commands.BRIGHTNESS_UP),

            CommandShape(
                widget.pcName,
                Colors.pinkAccent[100] ?? Colors.pinkAccent,
                'Keyboard',
                Icons.keyboard,
                true,
                Commands.KEYBOARD),
            CommandShape(
                widget.pcName,
                Colors.pinkAccent[300] ?? Colors.pinkAccent,
                'Share clip.',
                Icons.content_paste,
                true,
                Commands.SHARE_CLIPBOARD),
          ],
        ),
        SizedBox(
          height: adjustSizeVertically(context, 16),
        ),
      ],
    );
  }

  taskManagerScreen() {
    return Column(
      children: [
        getSilverAnimatorBox(),
        widget.windowsTitle.isEmpty
            ? SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: MediaQuery.of(context).size.height / 4),
                  child: Text(
                    widget.online
                        ? "Nothing to show for now."
                        : "Sorry but the pc seems to be offline, cannot collect any data from it.",
                    style: GoogleFonts.lato(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.9,
                maxCrossAxisExtent:MediaQuery.of(context).size.width/3-1,
                ),
          itemCount: widget.windowsTitle.length,
          itemBuilder: (BuildContext context, int index) {
              return widget.windows[index];
          },
        ),
            ),
        SizedBox.fromSize(size: Size(0,70),)
      ],
    );
  }

  chartsScreen() {
    var index = WattageConsumptionChartState.currentIndex;
    var means = index == 0
        ? PcManager.wattageValues24h.means
        : index == 1
            ? PcManager.wattageValues4h.means
            : PcManager.wattageValues1m.means;

    var wattHour = index == 0
        ? PcManager.wattageValues24h.todayWattHour
        : index == 1
            ? PcManager.wattageValues4h.todayWattHour
            : PcManager.wattageValues1m.todayWattHour;

    var data = index == 0
        ? PcManager.wattageValues24h
        : index == 1
            ? PcManager.wattageValues4h
            : PcManager.wattageValues1m;

    return Column(
      children: [
        getSilverAnimatorBox(),
        SizedBox(
          height: adjustSizeVertically(context, 10),
        ),
        LargeCommandShape(
            widget.wattsActive,
            Colors.blueGrey,
            Colors.amber,
            "Wattage consumption",
            "You used ${wattHour.toStringAsFixed(1)} Wh",
            bottom2: "Watt mean is  ${means[0].toStringAsFixed(1)}W",
            Icons.bolt, () async {
          if (widget.maxWattage == 0) {
            requestMaxWattage();
          } else {
            setState(() {
              widget.wattsActive = !widget.wattsActive;
              if (widget.wattsActive) {
                widget.cpusActive = false;
                widget.ramsActive = false;
                widget.gpusActive = false;
                widget.disksActive = false;
                widget.tempsActive = false;
              }
            });
          }
        }, spots: data.watts, each: 20, unit: 'W'),
        SizedBox(
          height: adjustSizeVertically(context, 10),
        ),
        const Divider(thickness: 1),
        SizedBox(
          height: adjustSizeVertically(context, 10),
        ),
        LargeCommandShape(
            widget.cpusActive,
            const Color(0xFF5b8b6e),
            Colors.white,
            "Cpu usage",
            "Cpu mean is ${means[1].toStringAsFixed(1)}%",
            Icons.memory, () async {
          setState(() {
            widget.cpusActive = !widget.cpusActive;
            if (widget.cpusActive) {
              widget.wattsActive = false;
              widget.ramsActive = false;
              widget.gpusActive = false;
              widget.disksActive = false;
              widget.tempsActive = false;
            }
          });
        }, spots: data.cpus, each: 20, unit: '%'),
        SizedBox(
          height: adjustSizeVertically(context, 16),
        ),
        LargeCommandShape(
            widget.gpusActive,
            const Color(0xFF758b58),
            Colors.white,
            "Gpu usage",
            "Gpu mean is ${means[2].toStringAsFixed(1)}%",
            Icons.bar_chart, () async {
          setState(() {
            widget.gpusActive = !widget.gpusActive;
            if (widget.gpusActive) {
              widget.wattsActive = false;
              widget.ramsActive = false;
              widget.cpusActive = false;
              widget.disksActive = false;
              widget.tempsActive = false;
            }
          });
        }, spots: data.gpus, each: 20, unit: '%'),
        SizedBox(
          height: adjustSizeVertically(context, 16),
        ),
        LargeCommandShape(
            widget.ramsActive,
            const Color(0xFF8b5d76),
            Colors.white,
            "Ram usage",
            "Ram mean is ${means[3].toStringAsFixed(1)}%",
            Icons.workspaces_filled, () async {
          setState(() {
            widget.ramsActive = !widget.ramsActive;
            if (widget.ramsActive) {
              widget.wattsActive = false;
              widget.gpusActive = false;
              widget.cpusActive = false;
              widget.disksActive = false;
              widget.tempsActive = false;
            }
          });
        }, spots: data.rams, each: 20, unit: '%'),
        SizedBox(
          height: adjustSizeVertically(context, 16),
        ),
        LargeCommandShape(
            widget.disksActive,
            const Color(0xFF8b5d5e),
            Colors.white,
            "Disk usage",
            "Disk mean is ${means[4].toStringAsFixed(1)}%",
            Icons.storage, () async {
          setState(() {
            widget.disksActive = !widget.disksActive;
            if (widget.disksActive) {
              widget.wattsActive = false;
              widget.ramsActive = false;
              widget.cpusActive = false;
              widget.gpusActive = false;
              widget.tempsActive = false;
            }
          });
        }, spots: data.disks, each: 20, unit: '%'),
        SizedBox(
          height: adjustSizeVertically(context, 16),
        ),
        LargeCommandShape(
            widget.tempsActive,
            const Color(0xFF8b7b5c),
            Colors.white,
            "Temperature",
            "Temp mean is ${means[5].toStringAsFixed(1)} °C",
            Icons.thermostat, () async {
          setState(() {
            widget.tempsActive = !widget.tempsActive;
            if (widget.tempsActive) {
              widget.wattsActive = false;
              widget.ramsActive = false;
              widget.cpusActive = false;
              widget.disksActive = false;
              widget.gpusActive = false;
            }
          });
        }, spots: data.temps, each: 5, unit: '°C'),
        SizedBox(
          height: adjustSizeVertically(context, 16),
        ),
      ],
    );
  }

  passwordsScreen() {
    return Column(
      children: [
        getSilverAnimatorBox(),
        passwordsList,
      ],
    );
  }

  remoteControlScreen() {
    return Column(
      children: [
        getSilverAnimatorBox(),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              shrinkWrap: true,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.screen_share,
                        color: Colors.yellow.shade200,
                      ),
                      onPressed: () {
                        calledNavigator = true;
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (!calledNavigator) {
                            return;
                          }
                          calledNavigator = false;
                          Navigator.pushNamed(context, '/keyboardListener');
                        });
                      },
                      splashColor: Colors.black.withOpacity(1),
                      highlightColor: Colors.black.withOpacity(0.2),
                      iconSize: 110,
                    ),
                    Text(
                      'Remote control                                keyboard',
                      style: GoogleFonts.lato(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.yellow.shade300),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.orange.shade200,
                      ),
                      onPressed: () {
                        calledNavigator = true;
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (!calledNavigator) {
                            return;
                          }
                          calledNavigator = false;
                          Navigator.pushNamed(context, '/webcamStreaming');
                        });
                      },
                      splashColor: Colors.black.withOpacity(1),
                      highlightColor: Colors.black.withOpacity(0.2),
                      iconSize: 110,
                    ),
                    Text(
                      'Remote stream                       webcam',
                      style: GoogleFonts.lato(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.orange.shade300),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: Colors.deepOrange.shade200,
                      ),
                      onPressed: () {
                        calledNavigator = true;
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (!calledNavigator) {
                            return;
                          }
                          calledNavigator = false;
                          Navigator.pushNamed(context, '/sendTextVoice');
                        });
                      },
                      splashColor: Colors.black.withOpacity(1),
                      highlightColor: Colors.black.withOpacity(0.2),
                      iconSize: 110,
                    ),
                    Text(
                      'Control using your voice',
                      style: GoogleFonts.lato(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.deepOrange.shade300),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.camera,
                        color: Colors.redAccent.shade100,
                      ),
                      onPressed: () async {
                        if (!await yesNoDialog(
                            context,
                            'Wanna set your pc to record the screen? Please note that this feature required FFmpeg to be installed on your pc;'
                            'you can follow this guide to do so: https://www.wikihow.com/Install-FFmpeg-on-Windows')) {
                          return;
                        }
                        var fps = await inputDialog(
                            context,
                            'The number of frame per second. [1-60]',
                            '30',
                            Icons.format_paint_sharp,
                            numbers: true,
                            title: 'FPS');
                        if (fps == '' ||
                            int.parse(fps) > 60 ||
                            int.parse(fps) < 1) {
                          return;
                        }
                        int minutes = (await inputMinuteHours(
                            context,
                            'Gimme the duration of the recording',
                            Icons.timer));
                        if (minutes == 0) {
                          SnackBarGenerator.makeSnackBar(
                              context, 'Please give me a value greater than 0!',
                              color: Colors.red);
                          return;
                        } else if (minutes == -1) {
                          return;
                        }
                        var h265 = await yesNoDialog(
                            context,
                            'Wanna use the newer codec HEVC(H.265)? You gain'
                            'better compression paying in higher cpu\'s usage',
                            confirm: 'H.265',
                            cancel: 'H.264');
                        lastQuality = await showDialog<int>(
                                context: context,
                                builder: (context) => sliderDialog(
                                    "Quality",
                                    lastQuality == -1 ? 50 : lastQuality,
                                    20,
                                    Icons.high_quality)) ??
                            -1;
                        if (lastQuality == -1) {
                          return;
                        }
                        var quality = 51 - lastQuality * 51 / 100;

                        var command =
                            'RECORD_SECONDS@@@$fps@@@${minutes * 60}@@@$quality@@@$h265';

                        sendCommand(null, command);
                      },
                      splashColor: Colors.black.withOpacity(1),
                      highlightColor: Colors.black.withOpacity(0.2),
                      iconSize: 110,
                    ),
                    Text(
                      'Schedule record                       screen',
                      style: GoogleFonts.lato(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.redAccent.shade200),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  getSilverAnimatorBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      height: !_FABexpanded ? 0 : adjustSizeVertically(context, 128),
    );
  }

  requestMaxWattage() async {
    if (await yesNoDialog(context,
        "Looks like you haven't set the wattage of your pc's power supply... wanna do it now?")) {
      String wattage = await inputDialog(
          context,
          "Please input your power supply wattage, you can read it on the"
              " stick on the back of your charger. If your charger only display Voltage and Current,"
              " just multiply them. Note that the value should be lower than 80W for low end laptop,"
              " lower than 150W for mid-range laptop and near 210W for high-rage gaming laptop",
          "Wattage",
          Icons.offline_bolt,
          numbers: true,
          title: 'MaxWattage');

      if (wattage == '') {
        return;
      }
      var value = int.parse(wattage);
      if (value < 2000 && value > 9) {
        var response =
            await requestData(context, HttpType.post, '/addPcMaxWattage', {
          'token': PcManager.token,
          'pcName': widget.pcName,
          'value': wattage,
        });
        SnackBarGenerator.makeSnackBar(context, response['result'],
            color: Colors.amber);
        widget.maxWattage = value;
        if (response['result'].toString().contains('uccessfully')) {
          widget.maxWattage = value;
        }
      } else {
        SnackBarGenerator.makeSnackBar(
            context, "The value cannot exceed the range[10,2000]!",
            color: Colors.red);
      }
    }
  }

  void pollingActiveWindows() async {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_currentIndex==1) {
        sendCommand(null, 'TASK_MANAGER', snackbar: false);
      }
      pollingActiveWindows();
    });
  }
}

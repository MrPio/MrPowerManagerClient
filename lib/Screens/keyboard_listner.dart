import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Widgets/icon_ink_well.dart';

import '../Styles/background_gradient.dart';

class MyKeyboardListener extends StatefulWidget {
  const MyKeyboardListener({Key? key}) : super(key: key);

  @override
  _MyKeyboardListenerState createState() => _MyKeyboardListenerState();
}

class _MyKeyboardListenerState extends State<MyKeyboardListener> {
  var _controller = TextEditingController();
  var focusNode = FocusNode();
  var _iconSize = 36;
  List<bool> hover = List.filled(99, false);
  List<bool> down = List.filled(99, false);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: getBackgroundGradient(),
      child: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Stack(
                children: [
                  TextField(
                    focusNode: focusNode,
                    cursorColor: Colors.transparent,
                    style: GoogleFonts.lato(
                        color: Colors.transparent, fontSize: 0),
                    maxLines: 999,
                    autofocus: false,
                    controller: _controller,
                  ),
                  Center(
                      child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: Radius.circular(MediaQuery.of(context).viewInsets.bottom != 0?22:36),
                    padding: EdgeInsets.all(MediaQuery.of(context).viewInsets.bottom != 0?2:6),
                    color: MediaQuery.of(context).viewInsets.bottom != 0
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    strokeWidth: 8,
                    dashPattern: const [20],
                    child: IconInkWell(
                      Icon(
                        Icons.touch_app,
                        size: MediaQuery.of(context).viewInsets.bottom != 0?76:146,
                        color: MediaQuery.of(context).viewInsets.bottom != 0
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                      ),
                      () {
                        if (MediaQuery.of(context).viewInsets.bottom != 0) {
                          FocusScope.of(context).unfocus();
                        } else {
                          focusNode.requestFocus();
                        }
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  children: [
                    keyItem(Colors.white, Icons.close, "alt+f4", 5,
                        small: true),
                    keyItem(Colors.white, Icons.switch_right, "alt+tab", 6,
                        small: true),
                    keyItem(Colors.white, Icons.apps, "win+tab", 11,
                        small: true),
                    keyItem(Colors.white, Icons.arrow_downward, "alt+esc", 8,
                        small: true),
                    keyItem(Colors.white, Icons.copy, "ctrl+c", 9, small: true),
                    keyItem(Colors.white, Icons.paste, "ctrl+v", 10,
                        small: true),
                    keyItem(Colors.white, Icons.list_alt, "ctrl+shift+esc", 12,
                        small: true),
                  ],
                ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  children: [
                    keyItem(Colors.lightBlue, Icons.window, "Win", 0,
                        clickable: true),
                    keyItem(Colors.yellow, Icons.arrow_upward, "Shift", 1,
                        clickable: true),
                    keyItem(Colors.orangeAccent, Icons.keyboard_command_key,
                        "Ctrl", 2,
                        clickable: true),
                    keyItem(Colors.greenAccent, Icons.keyboard_alt, "Alt", 3,
                        clickable: true),
                    keyItem(
                        Colors.blue, Icons.subdirectory_arrow_left, "Enter", 4,
                        clickable: true),
                  ],
                ),
              ),
            ),
          ],
        )),
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  keyItem(Color color, IconData icon, String text, int i,
      {bool small = false, bool clickable = false}) {
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
          color: down[i] ? newColor.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(small ? 16 : 22)),
      child: InkWell(
        onTap: () {
          if (clickable && i == 1 || i == 2 || i == 3) {
            setState(() {
              down[i] = !down[i];
            });
          }
        },
        onLongPress: () {
          if (clickable && i != 4) {
            setState(() {
              down[i] = !down[i];
            });
          }
        },
        onTapDown: (value) => setState(() => hover[i] = true),
        onTapCancel: () => setState(() => hover[i] = false),
        onTapUp: (value) => setState(() => hover[i] = false),
        borderRadius: BorderRadius.circular(small ? 16 : 22),
        splashColor: Colors.white.withOpacity(0.3),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: small ? 4.0 : 8.0, horizontal: small ? 8.0 : 22.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: down[i]
                    ? _iconSize * 1.3
                    : (small ? _iconSize / 1.4 : _iconSize.toDouble()),
                color: hover[i] ? color : newColor,
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                text,
                style: GoogleFonts.lato(
                    fontSize: small ? 15 : 17,
                    fontWeight: FontWeight.w400,
                    color: hover[i] ? color : newColor),
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
        print('backspace');
      }
      if (_controller.text.isEmpty) {
        return;
      }
      if (lastText.length == _controller.text.length - 1) {
        print(_controller.text.characters.last.toString().toLowerCase());
      }
      lastText = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
  }
}

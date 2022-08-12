import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Pages/input_dialog.dart';
import 'package:mr_power_manager_client/Screens/Home.dart';
import 'package:mr_power_manager_client/Screens/pc_manager.dart';
import 'package:mr_power_manager_client/Styles/commands.dart';
import 'package:mr_power_manager_client/Utils/SnackbarGenerator.dart';
import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';

import '../Styles/pc_states.dart';
import '../Utils/api_request.dart';
import '../Utils/encrypt_password.dart';
import '../Utils/size_adjustaments.dart';

class PasswordsList extends StatefulWidget {
  PasswordsList(this.baseColor, {Key? key}) : super(key: key);

  final baseColor;
  static PcManagerState? pcManager;
  final keys = [];

  @override
  PasswordsListState createState() => PasswordsListState();
}

class PasswordsListState extends State<PasswordsList> {
  final Map<int, bool> hovers = {};
  final Map<String, bool> filters = {};

  @override
  Widget build(BuildContext context) {
    var passwords = PasswordsList.pcManager?.widget.passwords ?? [];
    PasswordsList.pcManager?.passwordsListState = this;

    return passwords.isEmpty?
    SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12,vertical: MediaQuery.of(context).size.height/4),
        child: Text(
          "You haven't stored any password yet! Please use the button below to add one.",
          style: GoogleFonts.lato(fontSize: 28),textAlign: TextAlign.center,
        ),
      ),
    )
    :Column(
      children: [
        GridView.builder(
          controller: PasswordsList.pcManager?.listviewController2,
          shrinkWrap: true,
          itemCount: passwords.length,
          itemBuilder: (context, index) {
            if (filters[passwords[index]] ?? false) return Container();
            var newColor = widget.keys.contains(passwords[index])
                ? widget.baseColor
                : Colors.deepOrange;

            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: hovers[index] ?? false ? 14 : 18,
                  vertical: hovers[index] ?? false ? 4 : 8),
              child: InkWell(
                splashColor: Colors.redAccent[600],
                borderRadius: BorderRadius.circular(adjustSizeHorizontally(
                    context, hovers[index] ?? false ? 20 : 28)),
                onTapDown: (details) => setState(() {
                  hovers[index] = true;
                }),
                onTapUp: (details) {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () {
                      setState(() {
                        hovers[index] = false;
                      });
                    },
                  );
                },
                onTap: () async {
                  if(!(PasswordsList.pcManager?.widget.online??false)){
                    await okDialog(
                        context,
                        "Sorry, but for security reasons you cannot send the key when "
                            "your pc is offline because in that case it would be necessary"
                            " to store it!");
                    return;
                  }

                  if (!widget.keys.contains(passwords[index])) {
                    await okDialog(
                        context,
                        "Sorry, but this smartphone doesn't"
                        "hold the key for this password, so you just have its encrypted "
                            "value which can't be decrypted without the key.");
                    return;
                  }
                  var key = '';
                  var keys = await StoreKeyValue.readStringListData(
                      'key-${PasswordsList.pcManager?.widget.pcName}');
                  for (var line in keys!) {
                    if (passwords[index] == line.split('@')[0]) {
                      key = line.split('@')[1];
                      break;
                    }
                  }
                  var com=PcManagerState.passwordPaste?"PASTE":"COPY";
                  PasswordsList.pcManager?.sendCommand(null, '${com}_PASSWORD_@@@@@@@@@@@@${passwords[index]}@@@@@@@@@@@@$key');

/*              var response=await requestData(context, HttpType.post, '/sendKey', {
                    'token': PcManager.token,
                    'pcName': PasswordsList.pcManager?.widget.pcName ?? '',
                    'title': passwords[index],
                    'key': key
                  });
                  SnackBarGenerator.makeSnackBar(context,
                      response['result'].toString().contains('successfully')?'Key successfully sent to your pc!':'Failed'
                      ,color: Colors.orange,textColor: Colors.white);
                  requestData(context, HttpType.post, '/scheduleCommand', {
                    'token': PcManager.token,
                    'pcName': PasswordsList.pcManager?.widget.pcName ?? '',
                    'command': Commands.PASSWORD.name
                  });*/
                },
                onLongPress: () async {
                  if (!await yesNoDialog(context,
                      'You sure you want to delete the password [${passwords[index]}]?')) {
                    return;
                  }

                  setState(() {
                    filters[passwords[index]] = true;
                  });
                  SnackBarGenerator.makeSnackBar(context,
                      '[${passwords[index]}] password removed from the list',
                      color: Colors.grey[900] ?? Colors.black,
                      actionColor: Colors.lightBlue,
                      textColor: Colors.white, onActionIgnored: () async {

                    var response = await requestData(
                        context, HttpType.delete, "/deletePassword", {
                      'token': PcManager.token,
                      'pcName': PasswordsList.pcManager?.widget.pcName ?? '',
                      'title': passwords[index],
                    });
                    var keys = await StoreKeyValue.readStringListData(
                        'key-${PasswordsList.pcManager?.widget.pcName}');
                    keys?.removeWhere((element) => element.contains(passwords[index]));
                    await StoreKeyValue.saveData('key-${PasswordsList.pcManager?.widget.pcName}', keys!);
                    SnackBarGenerator.makeSnackBar(
                        context, response['result'].toString(),
                        color: Colors.amberAccent);
                    filters[passwords[index]] = false;

                  }, onActionPressed: () {
                    setState(() {
                      filters[passwords[index]] = false;
                    });
                  });
                },
                onTapCancel: () {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () {
                      setState(() {
                        hovers[index] = false;
                      });
                    },
                  );
                },
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                      color: hovers[index] ?? false
                          ? newColor.withOpacity(0.5)
                          : newColor,
                      borderRadius: BorderRadius.circular(adjustSizeHorizontally(
                          context, hovers[index] ?? false ? 20 : 28))),
                  duration: const Duration(milliseconds: 120),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox.fromSize(
                        size: const Size(16, 0),
                      ),
                      Icon(
                        widget.keys.contains(passwords[index])
                            ? Icons.key
                            : Icons.key_off,
                        color: widget.keys.contains(passwords[index])
                            ? (Colors.white)
                            : Colors.grey[800],
                        size: adjustSizeHorizontally(context, 36),
                      ),
                      SizedBox.fromSize(
                        size: const Size(8, 0),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            passwords[index],
                            style: GoogleFonts.lato(
                                fontSize: adjustSizeHorizontally(context, 16)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              crossAxisSpacing: 6,
              mainAxisSpacing: 4,
              childAspectRatio: 3,
              maxCrossAxisExtent: adjustSizeHorizontally(context, 200)),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getKeys();
  }

  getKeys() async {
    var keys = await StoreKeyValue.readStringListData(
        'key-${PasswordsList.pcManager?.widget.pcName}');
    setState(() {
      for (var line in keys!) {
        widget.keys.add(line.split('@')[0]);
      }
    });
  }

  static Future<String> requestPassword(
      BuildContext context, String pcName) async {
    var keys = (await StoreKeyValue.readStringListData('key-$pcName') ?? []);

    if (keys.isEmpty &&
        !await yesNoDialog(
            context,
            "You haven't registered any password for [$pcName] yet. Do you want to do it now?"
            " Please note that we won't save nor upload your password, instead it will "
            "encrypted using SHA256 encryption. "
            "Your pc will be give the encrypted value of the password, while your "
            "smartphone will store the key.")) {
      return '';
    }
    var title = await inputDialog(context, "Give a title to the password",
        "title",  Icons.title,
        obscuring: false);

    for (String key
        in (await StoreKeyValue.readStringListData('key-$pcName')) ?? []) {
      if (key.split('@')[0].contains(title)) {
        SnackBarGenerator.makeSnackBar(context,
            "This title has already been used! Please try with another one.",
            color: Colors.red);
        return '';
      }
    }

    var password = await inputDialog(context, "Insert here your password",
        "password",  Icons.shield,
        obscuring: true);
    if (password == '') {
      return '';
    }

    var encList = encryptFernet(password);
    var key = encList[0];
    var encryptedPassword = encList[1];
    StoreKeyValue.appendString('key-$pcName', '$title@$key');
    var response = await requestData(context, HttpType.post, "/storePassword", {
      'token': await StoreKeyValue.readStringData('token'),
      'pcName': pcName,
      'title': title,
      'password': encryptedPassword
    });
    SnackBarGenerator.makeSnackBar(context, response['result']);

    return key;
  }
}

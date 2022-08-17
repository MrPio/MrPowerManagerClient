import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Pages/input_dialog.dart';
import 'package:mr_power_manager_client/Screens/Home.dart';
import 'package:mr_power_manager_client/Screens/pc_manager.dart';
import 'package:mr_power_manager_client/Styles/commands.dart';
import 'package:mr_power_manager_client/Utils/SnackbarGenerator.dart';
import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';
import 'package:palette_generator/palette_generator.dart';

import '../Styles/pc_states.dart';
import '../Utils/api_request.dart';
import '../Utils/encrypt_password.dart';
import '../Utils/size_adjustaments.dart';
import 'package:favicon/favicon.dart' as favi;

class PasswordsList extends StatefulWidget {
  PasswordsList( {Key? key}) : super(key: key);

  static PcManagerState? pcManager;
  final keys = [];

  @override
  PasswordsListState createState() => PasswordsListState();
}

class PasswordsListState extends State<PasswordsList> {
  final Map<int, bool> hovers = {};
  final Map<String, bool> filters = {};
  final baseColor=Colors.lightBlue;
  var loginColor=Colors.grey.shade700;
  Map<String,String> faviconUrls = {};
  Map<String,Color> dominantColors={};

  @override
  Widget build(BuildContext context) {
    var passwordsAndLogins = PasswordsList.pcManager?.widget.passwordsAndLogins ?? [];
    var logins = PasswordsList.pcManager?.widget.logins ?? [];
    PasswordsList.pcManager?.passwordsListState = this;


    return passwordsAndLogins.isEmpty?
    SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12,vertical: MediaQuery.of(context).size.height/4),
        child: Text(
          "You haven't stored any password yet! Please use the button below to add one.",
          style: GoogleFonts.lato(fontSize: adjustSizeHorizontally(context, 28)),textAlign: TextAlign.center,
        ),
      ),
    )
    :Column(
      children: [
        GridView.builder(
          controller: PasswordsList.pcManager?.listviewController2,
          shrinkWrap: true,
          itemCount: passwordsAndLogins.length,
          itemBuilder: (context, index) {
            if (filters[passwordsAndLogins[index]] ?? false) return Container();

            var isLogin=logins.contains(passwordsAndLogins[index]);

            var loginColor=dominantColors[passwordsAndLogins[index]]?.withOpacity(0.33)??Colors.grey.shade800;

            var newColor = widget.keys.contains(passwordsAndLogins[index])
                ? (isLogin?loginColor:baseColor)
                : Colors.deepOrange;

            var faviUrl=faviconUrls[passwordsAndLogins[index]]??'';


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

                  if (!widget.keys.contains(passwordsAndLogins[index])) {
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
                    if (passwordsAndLogins[index] == line.split('@')[0]) {
                      key = line.split('@')[1];
                      break;
                    }
                  }
                  var com=PcManagerState.passwordPaste?"PASTE":"COPY";
                  PasswordsList.pcManager?.sendCommand(null, '${com}_PASSWORD_@@@@@@@@@@@@${passwordsAndLogins[index]}@@@@@@@@@@@@$key');

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
                      isLogin?'You sure you want to delete the login [${passwordsAndLogins[index]}]?':
                      'You sure you want to delete the password [${passwordsAndLogins[index]}]?')) {
                    return;
                  }

                  setState(() {
                    filters[passwordsAndLogins[index]] = true;
                  });
                  SnackBarGenerator.makeSnackBar(context,
                      isLogin?'[${passwordsAndLogins[index]}] login removed from the list':
                      '[${passwordsAndLogins[index]}] password removed from the list',
                      color: Colors.grey[900] ?? Colors.black,
                      actionColor: Colors.lightBlue,
                      textColor: Colors.white, onActionIgnored: () async {

                    var response = await requestData(
                        context, HttpType.delete, "/deletePassword", {
                      'token': PcManager.token,
                      'pcName': PasswordsList.pcManager?.widget.pcName ?? '',
                      'title': passwordsAndLogins[index],
                    });
                    var keys = await StoreKeyValue.readStringListData(
                        'key-${PasswordsList.pcManager?.widget.pcName}');
                    keys?.removeWhere((element) => element.contains(passwordsAndLogins[index]));
                    await StoreKeyValue.saveData('key-${PasswordsList.pcManager?.widget.pcName}', keys!);

                    var favis = await StoreKeyValue.readStringListData(
                        'favicon-${PasswordsList.pcManager?.widget.pcName}');
                    favis?.removeWhere((element) => element.contains(passwordsAndLogins[index]));
                    await StoreKeyValue.saveData('favicon-${PasswordsList.pcManager?.widget.pcName}', favis!);


                    SnackBarGenerator.makeSnackBar(
                        context, response['result'].toString(),
                        color: Colors.amberAccent);
                    filters[passwordsAndLogins[index]] = false;

                  }, onActionPressed: () {
                    setState(() {
                      filters[passwordsAndLogins[index]] = false;
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
                      isLogin &&faviUrl!='' && widget.keys.contains(passwordsAndLogins[index])?
                          Image.network(
                              faviUrl,
                            width: 38,
                            height: 38,
                          ):
                      Icon(
                        widget.keys.contains(passwordsAndLogins[index])
                            ? (isLogin?Icons.person:Icons.key)
                            : (isLogin?Icons.person_off:Icons.key_off),
                        color: widget.keys.contains(passwordsAndLogins[index])
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
                            passwordsAndLogins[index],
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
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 2.6,
              maxCrossAxisExtent: adjustSizeHorizontally(context, 240)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height*0.7*max(0,12-passwordsAndLogins.length)/12,)
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getKeys();
    getDominantColors();
  }

  getKeys() async {
    var keys = await StoreKeyValue.readStringListData(
        'key-${PasswordsList.pcManager?.widget.pcName}')??[];
    var favicons=await StoreKeyValue.readStringListData(
        'favicon-${PasswordsList.pcManager?.widget.pcName}')??[];
    Map<String,String> urls={};
    for (var favicon in favicons){
      urls[favicon.split('@')[0]]=favicon.split('@')[1];
    }

    setState(() {
      for (var line in keys) {
        widget.keys.add(line.split('@')[0]);
      }
      faviconUrls=urls;
    });


  }

  getDominantColors() async{
    var favicons=await StoreKeyValue.readStringListData(
        'favicon-${PasswordsList.pcManager?.widget.pcName}')??[];
    for (var favi in favicons){
      var palette= await PaletteGenerator.fromImageProvider(Image.network(favi.split('@')[1]).image);
      dominantColors[favi.split('@')[0]]=palette.dominantColor?.color??Colors.grey.shade800;
    }
    setState(() { });
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
    bool alsoUsername= await yesNoDialog(context, 'Wanna register a full login or just a password?',confirm: 'Full login',cancel: 'Just a pass');
    var title = await inputDialog(context, alsoUsername?'Give a title to this login':'Give a title to the password',
        "title",  Icons.title, obscuring: false);

    for (String key
        in (await StoreKeyValue.readStringListData('key-$pcName')) ?? []) {
      if (key.split('@')[0].contains(title)) {
        if(title!=''){
        SnackBarGenerator.makeSnackBar(context,
            "This title has already been used! Please try with another one.",
            color: Colors.red);
        }
        return '';
      }
    }
    var username='',url='';
    var args='';



    if(alsoUsername){
      url= await inputDialog(context, "Copy here the url of the login page:",
          "url",  Icons.web,
          obscuring: false);
      if(url!=''){
        var newUrl=url;
        if(!url.contains('https://') && !url.contains('http://')){
          newUrl='http://'+url;
        }
        try{
          var faviUrl=(await favi.Favicon.getBest(newUrl))?.url;
          StoreKeyValue.appendString('favicon-$pcName', '$title@$faviUrl');
        }
        catch(s){}

      if(await yesNoDialog(context, 'Wanna also add actions (Tabs/Enter) to perform when accessing the page before pasting the credentials?',confirm: 'Yes',cancel: 'No')){
        var argsList=await inputTabAndEnter(context, 'Please reproduce here the sequence of Tabs/Enters to press '
            'after accessing the page, before the input of the credentials', Icons.keyboard);
        args=argsList.toString();
      }
      }


      username = await inputDialog(context, "Insert here your username",
          "username", Icons.person,
          obscuring: false);
      if (username == '') {
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
    var encryptedUsername=alsoUsername?encryptFernetWithKey(username, key):'';
    var encryptedUrl=alsoUsername?encryptFernetWithKey(url, key):'';
    StoreKeyValue.appendString('key-$pcName', '$title@$key');
    print(
        {
          'token': await StoreKeyValue.readStringData('token'),
          'pcName': pcName,
          'title': title,
          'username': encryptedUsername,
          'url':encryptedUrl,
          'password': encryptedPassword,
          'args':args
        }.toString()
    );

    var response = await requestData(context, HttpType.post, "/storeLogin", {
      'token': await StoreKeyValue.readStringData('token'),
      'pcName': pcName,
      'title': title,
      'username': encryptedUsername,
      'url':encryptedUrl,
      'password': encryptedPassword,
      'args':args
    });
    SnackBarGenerator.makeSnackBar(context, response['result']);

    return key;
  }
}

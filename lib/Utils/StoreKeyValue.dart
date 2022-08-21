import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreKeyValue {
  static Future<SharedPreferences> get _prefs async {
    final sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getKeys());
    return sharedPreferences;
  }

  //----------------------------------------------------------------
  static Future<void> saveData(String key, Object value) async {
    switch (value.runtimeType) {
      case String:
        _saveStringData(key, value as String);
        break;
      case bool:
        _saveBoolData(key, value as bool);
        break;
      case int:
        _saveIntData(key, value as int);
        break;
      case double:
        _saveDoubleData(key, value as double);
        break;
      case List<String>:
        _saveStringListData(key, value as List<String>);
    }
    print("Saved [$key]:[$value] as ${value.runtimeType}");
  }

  static Future<void> appendString(String key, String value) async {
    var list=(await readStringListData(key))??[];
    list.add(value);
    (await _prefs).setStringList(key, list);
  }


  static Future<void> _saveStringData(String key, String value) async {
    (await _prefs).setString(key, value);
  }

  static Future<void> _saveBoolData(String key, bool value) async {
    (await _prefs).setBool(key, value);
  }

  static Future<void> _saveIntData(String key, int value) async {
    (await _prefs).setInt(key, value);
  }

  static Future<void> _saveDoubleData(String key, double value) async {
    (await _prefs).setDouble(key, value);
  }

  static Future<void> _saveStringListData(String key, List<String> value) async {
    (await _prefs).setStringList(key, value);
  }

  //----------------------------------------------------------------
  static Future<String> readStringData(String key) async {
    return (await _prefs).getString(key) ?? '';
  }

  static Future<bool> readBoolData(String key) async {
    return (await _prefs).getBool(key) ?? false;
  }

  static Future<int> readIntData(String key) async {
    return (await _prefs).getInt(key) ?? 0;
  }

  static Future<double> readDoubleData(String key) async {
    return (await _prefs).getDouble(key) ?? 0;
  }

  static Future<List<String>?> readStringListData(String key) async {
    return (await _prefs).getStringList(key);
  }

  //----------------------------------------------------------------
  static Future<Set<String>?> getKeys() async {
    return (await _prefs).getKeys();
  }

  //----------------------------------------------------------------
  static Future<void> removeData(String key) async {
    (await _prefs).remove(key);
  }



  static Future<void> writeImage(Uint8List data, String name) async {
    // storage permission ask
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Directory? tempDir = await getExternalStorageDirectory();
    String tempPath = tempDir?.path??'';
    var filePath = tempPath + '/$name';
    print(filePath);

    // the data
    var bytes = ByteData.view(data.buffer);
    final buffer = bytes.buffer;
    // save the data in the path
    await (await File(filePath).create(recursive: true)).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),mode: FileMode.write);
    GallerySaver.saveImage(filePath);
  }

  static Future<void> writeFile(Uint8List data, String name,String ext,
      {MimeType mimeType = MimeType.OTHER}) async {
    // storage permission ask
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    String path = await FileSaver.instance.saveAs(name, data,ext,mimeType);
    log(path);
  }

}

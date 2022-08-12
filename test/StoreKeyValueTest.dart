import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';

main() {
  StoreKeyValue.saveData("test001", "pippo pad!");
  StoreKeyValue.readStringData("test001")
      .then((value) => print("value=$value"));
}

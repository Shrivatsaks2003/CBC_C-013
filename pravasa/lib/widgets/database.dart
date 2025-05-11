import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('settings');
  }

  static Future<void> setEmergencyNumber(String number) async {
    final box = Hive.box('settings');
    await box.put('emergency_number', number);
  }

  static String getEmergencyNumber() {
    final box = Hive.box('settings');
    return box.get('emergency_number', defaultValue: '');
  }
}

import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Stream for water level data
  Stream<String> getWaterLevelStream() {
    return _database.child('sensor_data/sensors/water_level').onValue.map((event) {
      final data = event.snapshot.value;
      return data?.toString() ?? 'UNKNOWN';
    });
  }

  // Stream for pressure data
  Stream<double> getPressureStream() {
    return _database.child('sensor_data/sensors/bmp280/pressure').onValue.map((event) {
      final data = event.snapshot.value;
      return data != null ? double.parse(data.toString()) : 0.0;
    });
  }

  // Stream for temperature data
  Stream<double> getTemperatureStream() {
    return _database.child('sensor_data/sensors/ds18b20/temperature').onValue.map((event) {
      final data = event.snapshot.value;
      return data != null ? double.parse(data.toString()) : 0.0;
    });
  }

  // Stream for pressure setpoint
  Stream<double> getPressureSetpointStream() {
    return _database.child('sensor_data/pid/pressure/setpoint').onValue.map((event) {
      final data = event.snapshot.value;
      return data != null ? double.parse(data.toString()) : 1000.0;
    });
  }

  // Stream for temperature setpoint
  Stream<double> getTemperatureSetpointStream() {
    return _database.child('sensor_data/pid/temperature/setpoint').onValue.map((event) {
      final data = event.snapshot.value;
      return data != null ? double.parse(data.toString()) : 45.0;
    });
  }

  // Update pressure setpoint
  Future<void> updatePressureSetpoint(double value) async {
    await _database.child('sensor_data/pid/pressure').update({
      'setpoint': value
    });
  }

  // Update temperature setpoint
  Future<void> updateTemperatureSetpoint(double value) async {
    await _database.child('sensor_data/pid/temperature').update({
      'setpoint': value
    });
  }
} 
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/telemetry_data.dart';

class RobotApiService extends ChangeNotifier {
  String _baseUrl = '';
  bool _isConnected = false;
  TelemetryData? _latestData;
  Timer? _pollingTimer;
  String _connectionStatus = 'Desconectado';

  // Robot configuration
  double _lineKp = 0.028;
  double _lineKi = 0.0006;
  double _lineKd = 0.0012;
  double _targetSpeedMps = 1.0;
  double _maxSpeedMps = 1.2;

  bool get isConnected => _isConnected;
  TelemetryData? get latestData => _latestData;
  String get connectionStatus => _connectionStatus;
  String get baseUrl => _baseUrl;

  double get lineKp => _lineKp;
  double get lineKi => _lineKi;
  double get lineKd => _lineKd;
  double get targetSpeedMps => _targetSpeedMps;
  double get maxSpeedMps => _maxSpeedMps;

  /// Check connection to default robot IP (192.168.4.1)
  Future<bool> checkConnection() async {
    try {
      _baseUrl = 'http://192.168.4.1';
      final response = await http
          .get(Uri.parse('$_baseUrl/status'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _isConnected = true;
        _connectionStatus = 'Conectado';
        await _loadConfiguration();
        startPolling();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _connectionStatus = 'Error de conexión: ${e.toString()}';
      _isConnected = false;
      notifyListeners();
      if (kDebugMode) {
        print('Connection error: $e');
      }
    }
    return false;
  }

  /// Connect to custom IP address
  Future<bool> connect(String ip) async {
    try {
      // Limpiar la IP de espacios en blanco
      final cleanIp = ip.trim();
      _baseUrl = 'http://$cleanIp';

      final response = await http
          .get(Uri.parse('$_baseUrl/status'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _isConnected = true;
        _connectionStatus = 'Conectado a $cleanIp';
        await _loadConfiguration();
        startPolling();
        notifyListeners();
        return true;
      } else {
        _connectionStatus = 'Error: código ${response.statusCode}';
        _isConnected = false;
        notifyListeners();
      }
    } catch (e) {
      _connectionStatus = 'Error: ${e.toString()}';
      _isConnected = false;
      notifyListeners();
      if (kDebugMode) {
        print('Connection error to $ip: $e');
      }
    }
    return false;
  }

  /// Disconnect from robot
  void disconnect() {
    _isConnected = false;
    _connectionStatus = 'Desconectado';
    _pollingTimer?.cancel();
    _pollingTimer = null;
    notifyListeners();
  }

  /// Start polling telemetry data
  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      fetchTelemetry();
    });
  }

  /// Fetch telemetry data from /telemetry endpoint
  Future<void> fetchTelemetry() async {
    if (!_isConnected || _pollingTimer == null) return;

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/telemetry'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestData = TelemetryData.fromJson(data);
        notifyListeners();
      } else {
        // Si hay error de conexión persistente, desconectar
        if (kDebugMode) {
          print('Telemetry status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Silenciar errores ocasionales pero loguear si es en debug
      if (kDebugMode) {
        print('Error fetching telemetry: $e');
      }
    }
  }

  /// Load robot configuration from /config endpoint
  Future<void> _loadConfiguration() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/config'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final linePid = data['line_pid'] ?? {};
        final speeds = data['speeds'] ?? {};

        _lineKp = (linePid['kp'] ?? 0.028).toDouble();
        _lineKi = (linePid['ki'] ?? 0.0006).toDouble();
        _lineKd = (linePid['kd'] ?? 0.0012).toDouble();
        _targetSpeedMps = (speeds['target_mps'] ?? 1.0).toDouble();
        _maxSpeedMps = (speeds['max_mps'] ?? 1.2).toDouble();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading config: $e');
      }
    }
  }

  /// Update robot configuration (POST /config)
  Future<bool> updateConfiguration({
    double? kp,
    double? ki,
    double? kd,
    double? targetSpeed,
    double? maxSpeed,
    bool? motorsEnabled,
  }) async {
    if (!_isConnected) return false;

    try {
      final params = <String, String>{};
      if (kp != null) params['kp'] = kp.toString();
      if (ki != null) params['ki'] = ki.toString();
      if (kd != null) params['kd'] = kd.toString();
      if (targetSpeed != null) params['target_speed'] = targetSpeed.toString();
      if (maxSpeed != null) params['max_speed'] = maxSpeed.toString();
      if (motorsEnabled != null) params['motors_enabled'] = motorsEnabled ? '1' : '0';

      final response = await http.post(
        Uri.parse('$_baseUrl/config'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await _loadConfiguration();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating config: $e');
      }
    }
    return false;
  }

  /// Enable motors (POST /control)
  Future<bool> enableMotors() async {
    return _sendControlCommand('enable');
  }

  /// Disable motors (POST /control)
  Future<bool> disableMotors() async {
    return _sendControlCommand('disable');
  }

  /// Manual motor control (POST /control)
  Future<bool> manualControl(double left, double right) async {
    return _sendControlCommand('manual:left=$left,right=$right');
  }

  /// Start calibration sequence (POST /calibrate)
  Future<bool> startCalibration() async {
    if (!_isConnected) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/calibrate'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting calibration: $e');
      }
      return false;
    }
  }

  /// Get calibration status (GET /calibration/status)
  Future<Map<String, dynamic>?> getCalibrationStatus() async {
    if (!_isConnected) return null;

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/calibration/status'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching calibration status: $e');
      }
    }
    return null;
  }

  /// Send control command helper
  Future<bool> _sendControlCommand(String command) async {
    if (!_isConnected) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/control'),
        headers: {'Content-Type': 'text/plain'},
        body: command,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending control command: $e');
      }
      return false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isConnected = false;
    super.dispose();
  }
}


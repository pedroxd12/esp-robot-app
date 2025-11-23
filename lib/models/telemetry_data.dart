class TelemetryData {
  // Line following data
  final double linePositionMm;
  final double normalizedError;
  final double coverage;
  final bool lineDetected;
  final int rawMask;

  // IMU data
  final double yawDeg;
  final bool imuCalibrated;

  // Wheels data
  final double leftSpeedMps;
  final double rightSpeedMps;
  final double leftFilteredMps;
  final double rightFilteredMps;

  // Control data
  final double targetSpeed;
  final double adaptiveScale;
  final double steering;
  final double curvature;

  // Status
  final bool calibrating;
  final bool motorsEnabled;

  // Sensors (8 IR sensors)
  final List<double> irSensors;

  final DateTime timestamp;

  TelemetryData({
    required this.linePositionMm,
    required this.normalizedError,
    required this.coverage,
    required this.lineDetected,
    required this.rawMask,
    required this.yawDeg,
    required this.imuCalibrated,
    required this.leftSpeedMps,
    required this.rightSpeedMps,
    required this.leftFilteredMps,
    required this.rightFilteredMps,
    required this.targetSpeed,
    required this.adaptiveScale,
    required this.steering,
    required this.curvature,
    required this.calibrating,
    required this.motorsEnabled,
    required this.irSensors,
    required this.timestamp,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    final line = json['line'] ?? {};
    final imu = json['imu'] ?? {};
    final wheels = json['wheels'] ?? {};
    final control = json['control'] ?? {};
    final status = json['status'] ?? {};
    final sensors = json['sensors'] ?? [];

    return TelemetryData(
      linePositionMm: (line['position_mm'] ?? 0.0).toDouble(),
      normalizedError: (line['normalized_error'] ?? 0.0).toDouble(),
      coverage: (line['coverage'] ?? 0.0).toDouble(),
      lineDetected: line['detected'] ?? false,
      rawMask: line['mask'] ?? 0,
      yawDeg: (imu['yaw_deg'] ?? 0.0).toDouble(),
      imuCalibrated: imu['calibrated'] ?? false,
      leftSpeedMps: (wheels['left_mps'] ?? 0.0).toDouble(),
      rightSpeedMps: (wheels['right_mps'] ?? 0.0).toDouble(),
      leftFilteredMps: (wheels['left_filtered'] ?? 0.0).toDouble(),
      rightFilteredMps: (wheels['right_filtered'] ?? 0.0).toDouble(),
      targetSpeed: (control['target_speed'] ?? 0.0).toDouble(),
      adaptiveScale: (control['adaptive_scale'] ?? 1.0).toDouble(),
      steering: (control['steering'] ?? 0.0).toDouble(),
      curvature: (control['curvature'] ?? 0.0).toDouble(),
      calibrating: status['calibrating'] ?? false,
      motorsEnabled: status['motors_enabled'] ?? false,
      irSensors: List<double>.from((sensors as List).map((e) => (e ?? 0.0).toDouble())),
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
    );
  }

  factory TelemetryData.dummy() {
    return TelemetryData(
      linePositionMm: 0.0,
      normalizedError: 0.0,
      coverage: 0.0,
      lineDetected: false,
      rawMask: 0,
      yawDeg: 0.0,
      imuCalibrated: false,
      leftSpeedMps: 0.0,
      rightSpeedMps: 0.0,
      leftFilteredMps: 0.0,
      rightFilteredMps: 0.0,
      targetSpeed: 0.0,
      adaptiveScale: 1.0,
      steering: 0.0,
      curvature: 0.0,
      calibrating: false,
      motorsEnabled: false,
      irSensors: List.filled(8, 0.0),
      timestamp: DateTime.now(),
    );
  }

  double get averageSpeed => (leftFilteredMps + rightFilteredMps) / 2.0;

  bool get isMoving => averageSpeed.abs() > 0.01;
}


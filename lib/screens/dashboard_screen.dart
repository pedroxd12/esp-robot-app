import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/robot_api_service.dart';
import '../widgets/metric_card.dart';
import '../widgets/speed_chart.dart';
import '../widgets/sensor_visualizer.dart';
import '../models/telemetry_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.4.1');
  bool _showConnectionBar = true;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de conexión superior
          _buildConnectionBar(context),

          // Contenido principal
          Expanded(
            child: Consumer<RobotApiService>(
              builder: (context, robotService, child) {
                final telemetry = robotService.latestData ?? TelemetryData.dummy();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y Logo del Robot
                      _buildHeader(robotService.isConnected),
                      const SizedBox(height: 24),

                      // Visualización del Robot
                      _buildRobotVisualizer(telemetry),
                      const SizedBox(height: 24),

                      // Métricas principales
                      _buildMetricsGrid(telemetry),
                      const SizedBox(height: 24),

                      // Gráfico de velocidad
                      const SpeedChart(),
                      const SizedBox(height: 24),

                      // Sensores
                      SensorVisualizer(telemetry: telemetry),
                      const SizedBox(height: 24),

                      // Controles de dirección
                      if (robotService.isConnected) _buildControls(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBar(BuildContext context) {
    return Consumer<RobotApiService>(
      builder: (context, robotService, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showConnectionBar ? null : 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icono del carro
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: robotService.isConnected
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: robotService.isConnected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Campo de IP
                    Expanded(
                      child: TextField(
                        controller: _ipController,
                        enabled: !robotService.isConnected,
                        decoration: InputDecoration(
                          hintText: 'IP del Robot (192.168.4.1 - AP del ESP32)',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Botón de conexión
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (robotService.isConnected) {
                          robotService.disconnect();
                        } else {
                          final success = await robotService.connect(_ipController.text);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Conectado exitosamente'
                                      : 'Error al conectar con el robot',
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        robotService.isConnected ? Icons.close : Icons.wifi,
                        size: 20,
                      ),
                      label: Text(
                        robotService.isConnected ? 'Desconectar' : 'Conectar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: robotService.isConnected
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    // Botón para ocultar/mostrar
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showConnectionBar = !_showConnectionBar;
                        });
                      },
                      icon: Icon(
                        _showConnectionBar
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isConnected) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'CUCHAU',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: (isConnected ? Colors.green : Colors.grey).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isConnected ? Colors.green : Colors.grey,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isConnected ? 'ONLINE' : 'OFFLINE - Modo Demo',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobotVisualizer(TelemetryData telemetry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Estado del Robot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip(
                  telemetry.lineDetected ? 'Línea OK' : 'Sin Línea',
                  telemetry.lineDetected ? Icons.check_circle : Icons.warning,
                  telemetry.lineDetected ? Colors.green : Colors.orange,
                ),
                _buildStatusChip(
                  telemetry.motorsEnabled ? 'Motores ON' : 'Motores OFF',
                  Icons.settings,
                  telemetry.motorsEnabled ? Colors.blue : Colors.grey,
                ),
                _buildStatusChip(
                  telemetry.calibrating ? 'Calibrando...' : 'Operando',
                  Icons.tune,
                  telemetry.calibrating ? Colors.orange : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth.clamp(200.0, 300.0);
                return Center(
                  child: CustomPaint(
                    size: Size(width, width * 0.67),
                    painter: RobotPainter(
                      leftSpeed: telemetry.leftFilteredMps,
                      rightSpeed: telemetry.rightFilteredMps,
                      linePosition: telemetry.linePositionMm,
                      lineDetected: telemetry.lineDetected,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(TelemetryData telemetry) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        MetricCard(
          title: 'Velocidad Promedio',
          value: telemetry.averageSpeed.toStringAsFixed(2),
          subtitle: 'm/s',
          icon: Icons.speed,
          color: Theme.of(context).colorScheme.primary,
        ),
        MetricCard(
          title: 'Error de Línea',
          value: telemetry.normalizedError.toStringAsFixed(3),
          subtitle: 'normalizado',
          icon: Icons.linear_scale,
          color: _getErrorColor(telemetry.normalizedError),
        ),
        MetricCard(
          title: 'Orientación',
          value: '${telemetry.yawDeg.toStringAsFixed(1)}°',
          subtitle: telemetry.imuCalibrated ? 'Calibrado' : 'No calibrado',
          icon: Icons.explore,
          color: telemetry.imuCalibrated
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        MetricCard(
          title: 'Velocidad Objetivo',
          value: telemetry.targetSpeed.toStringAsFixed(2),
          subtitle: 'm/s',
          icon: Icons.my_location,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    final robotService = Provider.of<RobotApiService>(context, listen: false);
    final telemetry = robotService.latestData;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Controles del Robot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    if (telemetry?.motorsEnabled ?? false) {
                      await robotService.disableMotors();
                    } else {
                      await robotService.enableMotors();
                    }
                  },
                  icon: Icon(telemetry?.motorsEnabled ?? false ? Icons.stop : Icons.play_arrow),
                  label: Text(telemetry?.motorsEnabled ?? false ? 'Detener' : 'Iniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: telemetry?.motorsEnabled ?? false
                        ? Colors.red
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await robotService.startCalibration();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Calibración iniciada. Coloca el robot sobre blanco, luego sobre negro.'
                                : 'Error al iniciar calibración',
                          ),
                          backgroundColor: success ? Colors.blue : Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.tune),
                  label: const Text('Calibrar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showPIDTuningDialog(context),
              icon: const Icon(Icons.settings),
              label: const Text('Ajustar Parámetros PID'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPIDTuningDialog(BuildContext context) {
    final robotService = Provider.of<RobotApiService>(context, listen: false);

    final kpController = TextEditingController(text: robotService.lineKp.toString());
    final kiController = TextEditingController(text: robotService.lineKi.toString());
    final kdController = TextEditingController(text: robotService.lineKd.toString());
    final speedController = TextEditingController(text: robotService.targetSpeedMps.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuste de Parámetros PID'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kpController,
                decoration: const InputDecoration(
                  labelText: 'Kp (Proporcional)',
                  hintText: '0.028',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kiController,
                decoration: const InputDecoration(
                  labelText: 'Ki (Integral)',
                  hintText: '0.0006',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kdController,
                decoration: const InputDecoration(
                  labelText: 'Kd (Derivativo)',
                  hintText: '0.0012',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: speedController,
                decoration: const InputDecoration(
                  labelText: 'Velocidad Objetivo (m/s)',
                  hintText: '1.0',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final kp = double.tryParse(kpController.text);
              final ki = double.tryParse(kiController.text);
              final kd = double.tryParse(kdController.text);
              final speed = double.tryParse(speedController.text);

              if (kp != null && ki != null && kd != null && speed != null) {
                final success = await robotService.updateConfiguration(
                  kp: kp,
                  ki: ki,
                  kd: kd,
                  targetSpeed: speed,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Parámetros actualizados correctamente'
                            : 'Error al actualizar parámetros',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }


  Color _getErrorColor(double error) {
    final absError = error.abs();
    if (absError < 0.1) return Colors.green;
    if (absError < 0.3) return Colors.orange;
    return Colors.red;
  }
}

// Painter personalizado para dibujar el robot seguidor de línea
class RobotPainter extends CustomPainter {
  final double leftSpeed;
  final double rightSpeed;
  final double linePosition;
  final bool lineDetected;

  RobotPainter({
    required this.leftSpeed,
    required this.rightSpeed,
    required this.linePosition,
    required this.lineDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Dibujar la línea negra (track)
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, centerY + 40, size.width, 30),
        const Radius.circular(4),
      ),
      linePaint,
    );

    // Línea central de la pista
    final centerLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(
        Offset(x, centerY + 55),
        Offset(x + 10, centerY + 55),
        centerLinePaint,
      );
    }

    // Cuerpo del robot (rectángulo redondeado)
    final bodyPaint = Paint()
      ..color = const Color(0xFF2A2A3E)
      ..style = PaintingStyle.fill;

    final robotWidth = 100.0;
    final robotHeight = 80.0;

    // Calcular desplazamiento basado en linePosition (-42mm a +42mm aprox)
    final maxLineOffset = 42.0;
    final robotOffsetX = (linePosition / maxLineOffset) * 30.0;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + robotOffsetX, centerY),
        width: robotWidth,
        height: robotHeight,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Borde brillante
    final borderPaint = Paint()
      ..color = lineDetected ? const Color(0xFF00E5FF) : Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(bodyRect, borderPaint);

    // Ruedas
    final wheelPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;

    final wheelBorderPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final wheelWidth = 15.0;
    final wheelHeight = 30.0;

    // Rueda izquierda
    final leftWheelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + robotOffsetX - robotWidth / 2 - 5, centerY),
        width: wheelWidth,
        height: wheelHeight,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(leftWheelRect, wheelPaint);
    canvas.drawRRect(leftWheelRect, wheelBorderPaint);

    // Indicador de velocidad rueda izquierda
    if (leftSpeed.abs() > 0.01) {
      final speedIndicatorPaint = Paint()
        ..color = leftSpeed > 0 ? Colors.green : Colors.red
        ..style = PaintingStyle.fill;

      final speedHeight = (leftSpeed.abs() / 1.5 * wheelHeight).clamp(0.0, wheelHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX + robotOffsetX - robotWidth / 2 - 5, centerY),
            width: wheelWidth * 0.5,
            height: speedHeight,
          ),
          const Radius.circular(2),
        ),
        speedIndicatorPaint,
      );
    }

    // Rueda derecha
    final rightWheelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + robotOffsetX + robotWidth / 2 + 5, centerY),
        width: wheelWidth,
        height: wheelHeight,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rightWheelRect, wheelPaint);
    canvas.drawRRect(rightWheelRect, wheelBorderPaint);

    // Indicador de velocidad rueda derecha
    if (rightSpeed.abs() > 0.01) {
      final speedIndicatorPaint = Paint()
        ..color = rightSpeed > 0 ? Colors.green : Colors.red
        ..style = PaintingStyle.fill;

      final speedHeight = (rightSpeed.abs() / 1.5 * wheelHeight).clamp(0.0, wheelHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX + robotOffsetX + robotWidth / 2 + 5, centerY),
            width: wheelWidth * 0.5,
            height: speedHeight,
          ),
          const Radius.circular(2),
        ),
        speedIndicatorPaint,
      );
    }

    // Sensores IR representados como puntos en la parte inferior
    final sensorPaint = Paint()
      ..color = lineDetected ? Colors.greenAccent : Colors.grey
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final sensorX = centerX + robotOffsetX - 35 + (i * 10);
      canvas.drawCircle(
        Offset(sensorX, centerY + robotHeight / 2 - 5),
        3,
        sensorPaint,
      );
    }

    // Indicador de dirección (flecha)
    if (leftSpeed.abs() > 0.01 || rightSpeed.abs() > 0.01) {
      final arrowPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(centerX + robotOffsetX, centerY - robotHeight / 2 - 10);
      path.lineTo(centerX + robotOffsetX, centerY - robotHeight / 2 - 30);
      path.moveTo(centerX + robotOffsetX, centerY - robotHeight / 2 - 30);
      path.lineTo(centerX + robotOffsetX - 8, centerY - robotHeight / 2 - 22);
      path.moveTo(centerX + robotOffsetX, centerY - robotHeight / 2 - 30);
      path.lineTo(centerX + robotOffsetX + 8, centerY - robotHeight / 2 - 22);

      canvas.drawPath(path, arrowPaint);
    }

    // Texto de velocidades
    _drawSpeedIndicator(canvas, Offset(centerX + robotOffsetX - 40, centerY + 90), leftSpeed, 'L');
    _drawSpeedIndicator(canvas, Offset(centerX + robotOffsetX + 40, centerY + 90), rightSpeed, 'R');

    // Indicador de posición de línea
    if (lineDetected) {
      final lineIndicatorPaint = Paint()
        ..color = Colors.yellowAccent
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(centerX + robotOffsetX, centerY + 55),
        5,
        lineIndicatorPaint,
      );
    }
  }

  void _drawSpeedIndicator(Canvas canvas, Offset position, double speed, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label: ${speed.toStringAsFixed(2)} m/s',
        style: const TextStyle(
          color: Color(0xFF00E5FF),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy));
  }

  @override
  bool shouldRepaint(RobotPainter oldDelegate) {
    return oldDelegate.leftSpeed != leftSpeed ||
        oldDelegate.rightSpeed != rightSpeed ||
        oldDelegate.linePosition != linePosition ||
        oldDelegate.lineDetected != lineDetected;
  }
}


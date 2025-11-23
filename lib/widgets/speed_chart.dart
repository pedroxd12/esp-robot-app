import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/robot_api_service.dart';
import '../theme/app_theme.dart';

class SpeedChart extends StatefulWidget {
  const SpeedChart({super.key});

  @override
  State<SpeedChart> createState() => _SpeedChartState();
}

class _SpeedChartState extends State<SpeedChart> {
  final List<FlSpot> _leftSpeedData = [];
  final List<FlSpot> _rightSpeedData = [];
  final List<FlSpot> _targetSpeedData = [];
  int _timeCounter = 0;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    // Inicializar con datos demo
    for (int i = 0; i < 10; i++) {
      _leftSpeedData.add(FlSpot(i.toDouble(), 0));
      _rightSpeedData.add(FlSpot(i.toDouble(), 0));
      _targetSpeedData.add(FlSpot(i.toDouble(), 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RobotApiService>(
      builder: (context, robotService, child) {
        // Actualizar datos solo si hay nuevos datos (verificar por timestamp)
        if (robotService.latestData != null) {
          final data = robotService.latestData!;
          // Solo actualizar si el timestamp es diferente al último
          if (_lastUpdateTime == null || data.timestamp != _lastUpdateTime) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && (_lastUpdateTime == null || data.timestamp != _lastUpdateTime)) {
                _lastUpdateTime = data.timestamp;
                _updateSpeedData(
                  data.leftFilteredMps,
                  data.rightFilteredMps,
                  data.targetSpeed,
                );
              }
            });
          }
        }

        return Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Velocidad en Tiempo Real',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Leyenda
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Rueda Izq', AppColors.success),
                    const SizedBox(width: 16),
                    _buildLegendItem('Rueda Der', AppColors.accent),
                    const SizedBox(width: 16),
                    _buildLegendItem('Objetivo', AppColors.warning),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 0.5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.border,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toStringAsFixed(1)} m/s',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}s',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      minX: _leftSpeedData.first.x,
                      maxX: _leftSpeedData.last.x,
                      minY: -0.5,
                      maxY: 2.0,
                      lineBarsData: [
                        // Rueda izquierda
                        LineChartBarData(
                          spots: _leftSpeedData,
                          isCurved: true,
                          color: AppColors.success,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.success.withValues(alpha: 0.1),
                          ),
                        ),
                        // Rueda derecha
                        LineChartBarData(
                          spots: _rightSpeedData,
                          isCurved: true,
                          color: AppColors.accent,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.accent.withValues(alpha: 0.1),
                          ),
                        ),
                        // Velocidad objetivo
                        LineChartBarData(
                          spots: _targetSpeedData,
                          isCurved: false,
                          color: AppColors.warning,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          dashArray: [5, 5],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _updateSpeedData(double leftSpeed, double rightSpeed, double targetSpeed) {
    setState(() {
      _timeCounter++;
      _leftSpeedData.add(FlSpot(_timeCounter.toDouble(), leftSpeed));
      _rightSpeedData.add(FlSpot(_timeCounter.toDouble(), rightSpeed));
      _targetSpeedData.add(FlSpot(_timeCounter.toDouble(), targetSpeed));

      // Mantener solo los últimos 30 puntos
      if (_leftSpeedData.length > 30) {
        _leftSpeedData.removeAt(0);
        _rightSpeedData.removeAt(0);
        _targetSpeedData.removeAt(0);
      }
    });
  }
}


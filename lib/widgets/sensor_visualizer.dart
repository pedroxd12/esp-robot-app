import 'package:flutter/material.dart';
import '../models/telemetry_data.dart';
import '../theme/app_theme.dart';

class SensorVisualizer extends StatelessWidget {
  final TelemetryData telemetry;

  const SensorVisualizer({
    super.key,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sensores IR
            Row(
              children: [
                Icon(Icons.sensors, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Sensores Infrarrojos (IR)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Visualización de sensores IR
            _buildIRSensorsVisualization(context),
            const SizedBox(height: 24),

            // Información de la línea
            _buildLineInfo(context),
            const SizedBox(height: 24),

            // Estado de los motores
            Text(
              'Velocidad de Ruedas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildWheelSpeedBar(
              context,
              'Rueda Izquierda',
              telemetry.leftFilteredMps,
              Icons.circle,
            ),
            const SizedBox(height: 12),

            _buildWheelSpeedBar(
              context,
              'Rueda Derecha',
              telemetry.rightFilteredMps,
              Icons.circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIRSensorsVisualization(BuildContext context) {
    return Column(
      children: [
        // Sensores visuales
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(8, (index) {
            final value = telemetry.irSensors.length > index
                ? telemetry.irSensors[index]
                : 0.0;
            final isActive = value > 0.5;

            return Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.accent.withValues(alpha: value)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive ? AppColors.accent : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fiber_manual_record,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Indicador de línea detectada
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: telemetry.lineDetected
                ? AppColors.success.withValues(alpha: 0.2)
                : AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: telemetry.lineDetected ? AppColors.success : AppColors.error,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                telemetry.lineDetected ? Icons.check_circle : Icons.warning,
                color: telemetry.lineDetected ? AppColors.success : AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                telemetry.lineDetected ? 'Línea Detectada' : 'Línea Perdida',
                style: TextStyle(
                  color: telemetry.lineDetected ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow('Posición de línea', '${telemetry.linePositionMm.toStringAsFixed(1)} mm'),
          const SizedBox(height: 8),
          _buildInfoRow('Error normalizado', telemetry.normalizedError.toStringAsFixed(3)),
          const SizedBox(height: 8),
          _buildInfoRow('Cobertura', '${(telemetry.coverage * 100).toStringAsFixed(0)}%'),
          const SizedBox(height: 8),
          _buildInfoRow('Curvatura', telemetry.curvature.toStringAsFixed(3)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWheelSpeedBar(
    BuildContext context,
    String label,
    double speedMps,
    IconData icon,
  ) {
    final maxSpeed = 1.5; // m/s
    final normalizedSpeed = (speedMps.abs() / maxSpeed).clamp(0.0, 1.0);
    final color = speedMps > 0 ? AppColors.success : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${speedMps.toStringAsFixed(2)} m/s',
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: normalizedSpeed,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

# Aplicación de Control para Seguidor de Línea ESP32

## 📱 Descripción
Esta aplicación Flutter permite monitorear y controlar un robot seguidor de línea basado en ESP32 en tiempo real.

## 🔌 Conexión

### 1. Conectar al ESP32
El ESP32 crea un Access Point WiFi con las siguientes credenciales:
- **SSID**: `LINEBOT_AP`
- **Contraseña**: `seguidor123`
- **IP del robot**: `192.168.4.1`

### 2. Pasos de conexión:
1. Conecta tu dispositivo móvil a la red WiFi `LINEBOT_AP`
2. Abre la aplicación
3. Verifica que la IP sea `192.168.4.1`
4. Presiona el botón **Conectar**

## 📊 Características de la Aplicación

### Dashboard Principal
- **Estado del Robot**: Muestra si la línea está detectada, estado de motores y calibración
- **Métricas en tiempo real**:
  - Velocidad promedio de las ruedas
  - Error de seguimiento de línea
  - Orientación IMU (si está disponible)
  - Velocidad objetivo
- **Visualización del robot**: Representación gráfica del robot sobre la pista

### Gráfica de Velocidad
Muestra en tiempo real:
- 🟢 **Velocidad rueda izquierda** (verde)
- 🔵 **Velocidad rueda derecha** (azul)
- 🟡 **Velocidad objetivo** (amarillo, línea punteada)

### Sensores IR
- Visualización de los 8 sensores infrarrojos
- Indicador de línea detectada/perdida
- Información detallada:
  - Posición de la línea (mm)
  - Error normalizado
  - Cobertura de sensores
  - Métrica de curvatura

### Velocidad de Ruedas
- Barras indicadoras de velocidad en m/s para cada rueda
- Código de colores según velocidad

## 🎮 Controles

### Botón Iniciar/Detener
- **Verde (Iniciar)**: Activa el modo de seguimiento de línea
- **Rojo (Detener)**: Desactiva los motores

### Botón Calibrar
Inicia la secuencia de calibración de sensores IR:
1. Coloca el robot sobre superficie blanca
2. Espera 1.5 segundos
3. Coloca el robot sobre la línea negra
4. Espera 2 segundos
5. La calibración se guarda automáticamente

### Ajustar Parámetros PID
Permite ajustar en tiempo real:
- **Kp** (Proporcional): Respuesta inmediata al error
- **Ki** (Integral): Corrección de error acumulado
- **Kd** (Derivativo): Anticipación de cambios
- **Velocidad objetivo**: Velocidad deseada en m/s

**Valores por defecto**:
```
Kp: 0.028
Ki: 0.0006
Kd: 0.0012
Velocidad: 1.0 m/s
```

## 🔧 Endpoints API del ESP32

La aplicación se comunica con los siguientes endpoints:

### GET `/telemetry`
Obtiene telemetría completa cada 100ms:
```json
{
  "timestamp": 1234567890,
  "line": {
    "position_mm": 12.5,
    "normalized_error": 0.297,
    "coverage": 2.5,
    "detected": true,
    "mask": 24
  },
  "imu": {
    "yaw_deg": 45.2,
    "calibrated": true
  },
  "wheels": {
    "left_mps": 0.95,
    "right_mps": 1.05,
    "left_filtered": 0.94,
    "right_filtered": 1.04
  },
  "control": {
    "target_speed": 1.0,
    "adaptive_scale": 0.85,
    "steering": 0.15,
    "curvature": 0.45
  },
  "status": {
    "calibrating": false,
    "motors_enabled": true
  },
  "sensors": [0.0, 0.2, 0.8, 1.0, 0.9, 0.3, 0.0, 0.0]
}
```

### GET `/status`
Estado rápido del robot

### GET `/config`
Obtiene configuración actual (PID, velocidades)

### POST `/config`
Actualiza configuración (form-encoded):
```
kp=0.028&ki=0.0006&kd=0.0012&target_speed=1.0
```

### POST `/control`
Comandos de control:
- `enable`: Activa motores en modo seguimiento
- `disable`: Desactiva motores
- `manual:left=0.5,right=0.3`: Control manual

### POST `/calibrate`
Inicia secuencia de calibración de sensores IR

### GET `/calibration/status`
Estado de la calibración actual

## 📈 Algoritmo de Control

El robot utiliza:
1. **PID de línea**: Calcula corrección de dirección basada en error
2. **Velocidad adaptativa**: Reduce velocidad en curvas
3. **Control de velocidad por rueda**: PID independiente para cada motor
4. **Recuperación de línea**: Usa IMU cuando pierde la línea
5. **Anti-windup**: Previene saturación del integrador

## 🐛 Troubleshooting

### No se conecta al robot
- Verifica que estés conectado al WiFi `LINEBOT_AP`
- Asegúrate de que la IP sea `192.168.4.1`
- Reinicia el ESP32

### Datos no se actualizan
- Verifica la conexión WiFi
- Reconecta la aplicación
- El ESP32 envía datos cada 100ms

### Calibración no funciona
- Asegúrate de tener superficie blanca uniforme
- La línea negra debe ser clara y continua
- Espera los tiempos indicados entre pasos

### Valores PID incorrectos
- Usa los valores por defecto como referencia
- Aumenta Kp para respuesta más rápida (puede oscilar)
- Aumenta Kd para suavizar movimientos
- Aumenta Ki solo si hay error constante

## 🎯 Consejos de Uso

1. **Calibra siempre** antes de usar en una nueva pista
2. **Ajusta la velocidad** según la complejidad del circuito
3. **Monitorea la gráfica** para optimizar el PID
4. **Observa el error normalizado**: debe estar cerca de 0 en rectas
5. **Verifica los sensores IR**: al menos 3-4 deben detectar en curvas

## 📱 Compatibilidad

- Android 6.0+
- iOS 12.0+
- Requiere permisos de WiFi/red

## 🔄 Actualización de Firmware

Si necesitas actualizar el código del ESP32, el archivo C completo está en el repositorio.


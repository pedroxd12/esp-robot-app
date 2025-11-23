# LineBot Pro - Aplicación de Control

Aplicación Flutter profesional para monitorear y calibrar un robot seguidor de línea basado en ESP32.

## 🚀 Características

- **Monitoreo en Tiempo Real**: Visualización de datos de sensores IR, velocidad y control
- **Calibración Automática**: Inicia el proceso de calibración desde la app
- **Diseño Minimalista**: Interfaz oscura moderna y profesional
- **Gráficos en Tiempo Real**: Visualización de velocidad de ambas ruedas
- **Métricas Detalladas**: Posición de línea, error, cobertura, IMU y más

## 📱 Pantallas

### Pantalla de Conexión
- Instrucciones para conectarse al WiFi del robot
- SSID: `LINEBOT_AP`
- Contraseña: `seguidor123`
- Verificación de conexión automática

### Dashboard Principal
- **Visualizador de Sensores IR**: 8 sensores con indicación de activación
- **Métricas de Línea**: Posición, error normalizado, cobertura
- **Gráfico de Velocidad**: Historial de velocidad de ruedas izquierda y derecha
- **Panel de Control**: Velocidad objetivo, steering, adaptativo, curvatura
- **Estado IMU**: Yaw y estado de calibración
- **Botón de Calibración**: Inicia proceso de calibración remota

## 🔧 Configuración

### Requisitos
- Flutter SDK 3.9.2 o superior
- Dispositivo Android/iOS con WiFi
- Robot ESP32 configurado con el firmware proporcionado

### Instalación

1. Clonar el repositorio:
```bash
cd untitled
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Conectar tu dispositivo o iniciar un emulador

4. Ejecutar la aplicación:
```bash
flutter run
```

## 📡 API del Robot

El robot ESP32 expone los siguientes endpoints:

### GET /telemetry
Retorna telemetría en tiempo real en formato JSON:
```json
{
  "line_mm": 12.5,
  "line_norm": 0.123,
  "coverage": 2.5,
  "line_detected": true,
  "mask": 255,
  "yaw": 45.2,
  "calibrated": true,
  "speed_l": 0.95,
  "speed_r": 0.98,
  "target_speed": 1.0,
  "adaptive": 0.92,
  "steering": 0.05,
  "curvature": 0.15,
  "cal_running": false,
  "sensors": [0.1, 0.2, 0.8, 0.9, 0.85, 0.3, 0.15, 0.1]
}
```

### POST /calibrate
Inicia el proceso de calibración de sensores IR.

## 🎨 Paleta de Colores

- **Background**: `#0A0E27`
- **Surface**: `#1A1F3A`
- **Primary**: `#6C63FF`
- **Accent**: `#00F5FF`
- **Success**: `#00D9A3`
- **Warning**: `#FFB800`
- **Error**: `#FF5757`

## 📦 Dependencias Principales

- `http: ^1.1.0` - Comunicación HTTP con el robot
- `fl_chart: ^0.66.0` - Gráficos en tiempo real
- `google_fonts: ^6.1.0` - Tipografía profesional

## 🤝 Uso

1. **Conectar al Robot**:
   - Enciende tu robot ESP32
   - Conecta tu dispositivo al WiFi `LINEBOT_AP` (contraseña: `seguidor123`)
   - Abre la aplicación y presiona "Conectar al Robot"

2. **Monitorear**:
   - La aplicación se conectará automáticamente al robot en `192.168.4.1`
   - Los datos se actualizan cada 100ms
   - Observa los sensores IR, velocidades y métricas de control en tiempo real

3. **Calibrar**:
   - Presiona el botón "Iniciar Calibración"
   - Sigue las instrucciones en el robot:
     - Coloca sobre fondo blanco uniforme
     - Luego sobre la línea negra
   - La calibración se guarda automáticamente en el ESP32

## 📄 Licencia

Este proyecto es de código abierto y está disponible para uso personal y educativo.

## 🛠️ Solución de Problemas

### No se puede conectar al robot
- Verifica que estés conectado al WiFi `LINEBOT_AP`
- Asegúrate de que el robot esté encendido
- Comprueba que la IP sea `192.168.4.1`

### Los datos no se actualizan
- Verifica la conexión WiFi
- Reinicia la aplicación
- Verifica que el servidor HTTP del ESP32 esté funcionando

### Errores de calibración
- Asegúrate de seguir las instrucciones en pantalla
- Verifica que los sensores IR estén limpios
- Intenta calibrar nuevamente en mejores condiciones de iluminación


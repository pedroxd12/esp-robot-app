# 🚗 CUCHAU - Robot Control Dashboard

Una aplicación Flutter moderna y elegante para controlar y monitorear el robot Cuchau en tiempo real.

## ✨ Características

### 🎨 Diseño Mejorado
- **Tema oscuro futurista** con colores cian y naranja
- **Visualización 3D del robot** tipo carro con 4 ruedas
- **Animaciones suaves** y efectos de brillo
- **Interfaz intuitiva** y responsive

### 🔌 Conexión Flexible
- **Barra de conexión superior** que se puede mostrar/ocultar
- **Modo demo**: Ver la interfaz sin necesidad de estar conectado
- **Conexión WiFi** al robot mediante IP
- **Estado de conexión en tiempo real**

### 📊 Monitoreo de Telemetría
- **Velocidad**: Gráfico en tiempo real con historial
- **Batería**: Indicador con código de colores
- **Temperatura**: Monitor de temperatura del sistema
- **Distancia**: Sensor de obstáculos con alarma visual
- **Motores**: Barras de progreso para cada motor

### 🎮 Controles
- **Dirección**: Adelante, atrás, izquierda, derecha
- **Parar**: Botón de emergencia destacado
- **Respuesta instantánea** a los comandos

### 🚨 Alertas de Seguridad
- **Alerta de obstáculo** cuando está a menos de 30 cm
- **Indicadores de batería baja** con colores
- **Advertencia de temperatura alta**

## 🚀 Instalación

### Requisitos Previos
- Flutter SDK 3.5.4 o superior
- Dart SDK
- Android Studio o VS Code con extensiones de Flutter

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <url-del-repositorio>
cd cuchau
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 📱 Uso

### Conectarse al Robot

1. **Abrir la aplicación** - La barra de conexión aparecerá en la parte superior
2. **Ingresar la IP** del robot (ej: `192.168.1.100`)
3. **Presionar "Conectar"**
4. **Esperar confirmación** de conexión exitosa

### Modo Demo

- Puedes **usar la aplicación sin conectarte** al robot
- Se mostrará **"OFFLINE - Modo Demo"** en el encabezado
- Los datos mostrados serán valores predeterminados
- Ideal para **probar la interfaz** o **hacer demos**

### Ocultar/Mostrar Barra de Conexión

- Presiona el **botón de flecha** (↑/↓) en la barra de conexión
- La barra se ocultará para dar **más espacio** a la interfaz
- Vuelve a presionar para mostrarla cuando necesites conectar/desconectar

## 🎨 Personalización

### Colores del Tema

Edita `lib/theme/app_theme.dart` para cambiar los colores:

```dart
primary: const Color(0xFF00E5FF),  // Cian brillante
secondary: const Color(0xFFFF6B35), // Naranja
```

### Diseño del Robot

Modifica `RobotPainter` en `lib/screens/dashboard_screen.dart` para cambiar la apariencia del robot.

## 🔧 API del Robot

La aplicación espera que el robot tenga los siguientes endpoints:

### GET `/status`
Verifica que el robot esté disponible.

### GET `/telemetry`
Retorna datos de telemetría en formato JSON:

```json
{
  "speed": 2.5,
  "batteryLevel": 85.0,
  "temperature": 35.0,
  "obstacleDistance": 50,
  "motorLeftPower": 70.0,
  "motorRightPower": 70.0
}
```

### POST `/command`
Envía comandos al robot:

```json
{
  "command": "forward",
  "params": {}
}
```

**Comandos disponibles**: `forward`, `backward`, `left`, `right`, `stop`

## 📦 Dependencias

- **flutter**: Framework UI
- **provider**: Gestión de estado
- **http**: Comunicación con el robot
- **fl_chart**: Gráficos de telemetría
- **cupertino_icons**: Iconos adicionales

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── models/
│   └── telemetry_data.dart     # Modelo de datos
├── screens/
│   └── dashboard_screen.dart   # Pantalla principal
├── services/
│   └── robot_api_service.dart  # Servicio de API
├── theme/
│   └── app_theme.dart          # Configuración de tema
└── widgets/
    ├── metric_card.dart        # Tarjeta de métrica
    ├── speed_chart.dart        # Gráfico de velocidad
    └── sensor_visualizer.dart  # Visualizador de sensores
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT.

## 👨‍💻 Autor

Desarrollado con ❤️ para el Robot Cuchau

## 🐛 Reportar Problemas

Si encuentras algún bug o tienes una sugerencia, por favor abre un issue en el repositorio.

---

**¡Disfruta controlando a Cuchau! 🚗💨**


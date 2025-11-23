# Solución de Problemas - CUCHAU LineBot

## Problemas Corregidos

### 1. ✅ Error de Desbordamiento de RenderFlex (MetricCard)
**Problema Original:**
```
A RenderFlex overflowed by 34 pixels on the bottom.
Column:file:///C:/Users/abdie/AndroidStudioProjects/untitled/lib/widgets/metric_card.dart:27:16
```

**Solución Aplicada:**
- Reducido el padding de 16 a 12 píxeles
- Reducido tamaños de iconos de 36 a 28
- Reducido tamaños de fuente (title: 12→11, value: 20→18, subtitle: 10→9)
- Añadido `mainAxisSize: MainAxisSize.min` para que la Column use solo el espacio necesario
- Añadido `FittedBox` para el valor para escalar dinámicamente
- Añadido `maxLines` y `overflow: TextOverflow.ellipsis` para evitar texto desbordado

### 2. ✅ Error "RobotApiService was used after being disposed"
**Problema Original:**
```
I/flutter (21956): Error fetching telemetry: A RobotApiService was used after being disposed.
I/flutter (21956): Once you have called dispose() on a RobotApiService, it can no longer be used.
```

**Solución Aplicada:**
- Cambiado `ChangeNotifierProvider` por `MultiProvider` en `main.dart`
- Añadido `lazy: false` para que el servicio se cree inmediatamente
- Modificado `ConnectionScreen` para usar el Provider global en lugar de crear instancia local
- Eliminado `dispose()` local en `ConnectionScreen`
- Mejorado el método `dispose()` del servicio para establecer `_pollingTimer = null` y `_isConnected = false`
- Añadida verificación `_pollingTimer == null` en `fetchTelemetry()` para evitar llamadas después de dispose

### 3. ✅ Problemas de Comunicación con ESP32
**Problema Original:**
- Timeouts muy cortos causaban errores frecuentes
- No había manejo robusto de errores de conexión
- IP no se limpiaba correctamente

**Solución Aplicada:**
- Aumentados todos los timeouts:
  - `/status`: 5s → 10s
  - `/telemetry`: 1s → 3s
  - `/config`: 2s → 5s
  - `/calibrate`: 2s → 5s
  - `/control`: 2s → 5s
- Añadido `.trim()` para limpiar espacios en blanco de la IP
- Mejorado logging de errores en modo debug
- Aumentado intervalo de polling: 100ms → 200ms para reducir carga
- Añadidos mensajes de error más descriptivos

## Configuración de Red para ESP32

### 1. Conexión al Access Point del ESP32
El ESP32 crea un Access Point WiFi con los siguientes parámetros:
- **SSID:** `LINEBOT_AP`
- **Contraseña:** `seguidor123`
- **IP del ESP32:** `192.168.4.1`
- **Canal:** 6
- **Modo:** WPA2-PSK

### 2. Pasos para Conectar desde Android

1. **Conectar al WiFi del Robot:**
   - Ir a Configuración → WiFi en tu dispositivo Android
   - Buscar red `LINEBOT_AP`
   - Conectar usando contraseña: `seguidor123`

2. **Verificar Conexión:**
   - Android puede advertir "Internet no disponible" - IGNORAR
   - Asegurarse de que WiFi permanece conectado
   - La IP del ESP32 será: `192.168.4.1`

3. **Iniciar la App:**
   - Abrir la app CUCHAU
   - La app intentará conectar automáticamente a `192.168.4.1`
   - Si falla, puedes ingresar la IP manualmente

### 3. Endpoints API del ESP32

El código C del ESP32 expone estos endpoints HTTP:

| Endpoint | Método | Descripción | Timeout |
|----------|---------|-------------|---------|
| `/telemetry` | GET | Datos completos del robot | 3s |
| `/status` | GET | Estado rápido (online, calibrando, etc.) | 10s |
| `/config` | GET | Obtener configuración PID y velocidades | 5s |
| `/config` | POST | Actualizar configuración | 5s |
| `/control` | POST | Comandos de control (enable/disable/manual) | 5s |
| `/calibrate` | POST | Iniciar calibración de sensores IR | 5s |
| `/calibration/status` | GET | Estado de calibración | 5s |

### 4. Formato de Datos de Telemetría

El ESP32 envía JSON en este formato:
```json
{
  "timestamp": 1234567890,
  "line": {
    "position_mm": 12.5,
    "normalized_error": -0.123,
    "coverage": 2.5,
    "detected": true,
    "mask": 255
  },
  "imu": {
    "yaw_deg": 45.2,
    "calibrated": true
  },
  "wheels": {
    "left_mps": 0.85,
    "right_mps": 0.90,
    "left_filtered": 0.87,
    "right_filtered": 0.89
  },
  "control": {
    "target_speed": 1.0,
    "adaptive_scale": 0.95,
    "steering": 0.05,
    "curvature": 0.12
  },
  "status": {
    "calibrating": false,
    "motors_enabled": true
  },
  "sensors": [0.1, 0.2, 0.8, 0.9, 0.85, 0.3, 0.15, 0.05]
}
```

## Problemas Comunes y Soluciones

### Problema: "No se pudo conectar con el robot"
**Causas posibles:**
1. No estás conectado al WiFi `LINEBOT_AP`
2. El ESP32 no está encendido
3. El servidor HTTP del ESP32 no se inició correctamente

**Soluciones:**
1. Verificar conexión WiFi al Access Point del ESP32
2. Verificar que el LED del ESP32 esté encendido
3. Reiniciar el ESP32
4. Revisar logs del ESP32 por puerto serial: `ESP_LOGI(TAG, "HTTP API listo en http://192.168.4.1")`

### Problema: La app se conecta pero no muestra datos
**Causas posibles:**
1. El polling se detuvo
2. El endpoint `/telemetry` no responde
3. Error en formato JSON del ESP32

**Soluciones:**
1. Desconectar y reconectar desde la app
2. Verificar logs de la app en Logcat (buscar "Error fetching telemetry")
3. Probar endpoint manualmente: `curl http://192.168.4.1/telemetry`

### Problema: Desbordamiento visual en pantallas pequeñas
**Solución:**
- Ya corregido en `metric_card.dart`
- Las tarjetas ahora se escalan automáticamente
- Si persiste en otros widgets, ajustar `childAspectRatio` en GridView

### Problema: El robot no responde a comandos
**Causas posibles:**
1. Motores deshabilitados
2. Robot en modo calibración
3. Timeout de comandos

**Soluciones:**
1. Presionar botón "Iniciar" en la app
2. Esperar a que termine calibración
3. Verificar en logs del ESP32: `cfg.motors_enabled`

## Mejoras Implementadas

### Performance
- Polling reducido a 200ms (era 100ms) para reducir carga de red
- Timeouts aumentados para redes lentas
- Manejo de errores silencioso para evitar spam en logs

### Estabilidad
- Provider global evita múltiples instancias del servicio
- Verificaciones de `_isConnected` antes de cada llamada HTTP
- Limpieza correcta en `dispose()`

### UX
- Mensajes de error más descriptivos
- Indicadores visuales de estado (ONLINE/OFFLINE)
- Escalado automático de texto en tarjetas métricas

## Testing

### Prueba de Conectividad Manual
```bash
# Desde terminal/CMD conectado al mismo WiFi:
curl http://192.168.4.1/status
# Debe devolver: {"online":true,"calibrating":false,...}

curl http://192.168.4.1/telemetry
# Debe devolver JSON completo con todos los datos
```

### Verificar Logs del ESP32
```bash
# Conectar por USB y abrir monitor serial
# Buscar estas líneas:
# "HTTP API listo en http://192.168.4.1"
# "SoftAP activo"
# "Cliente conectado"
```

### Debug en Android
```bash
# Ver logs de Flutter:
flutter logs

# O usar Logcat:
adb logcat | grep flutter
```

## Próximos Pasos Recomendados

1. **Añadir reconexión automática:** Si se pierde conexión, reintentar automáticamente
2. **Persistencia de IP:** Guardar última IP usada en SharedPreferences
3. **Modo offline mejorado:** Mostrar datos históricos cuando no hay conexión
4. **Gráficos en tiempo real:** SpeedChart funcional con datos de telemetría
5. **Notificaciones:** Alertas cuando robot pierde línea o se detiene

## Estructura de Archivos Modificados

```
lib/
├── main.dart                    ✅ Corregido: Provider global
├── models/
│   └── telemetry_data.dart     ✅ Sin cambios necesarios
├── screens/
│   ├── connection_screen.dart  ✅ Corregido: Usa Provider global
│   └── dashboard_screen.dart   ✅ Sin cambios necesarios
├── services/
│   └── robot_api_service.dart  ✅ Corregido: Timeouts, dispose
├── widgets/
│   └── metric_card.dart        ✅ Corregido: Overflow fix
└── theme/
    └── app_theme.dart          ✅ Sin cambios necesarios
```

## Contacto y Soporte

Si encuentras más problemas:
1. Revisar logs de Flutter: `flutter logs`
2. Revisar logs del ESP32 por serial
3. Verificar versiones:
   - Flutter SDK: `flutter --version`
   - Dart SDK: Incluido en Flutter
   - ESP-IDF: Verificar en código C

---
**Última actualización:** 2025-11-23
**Versión de la app:** 1.0.0
**Versión del firmware ESP32:** Ver código C adjunto


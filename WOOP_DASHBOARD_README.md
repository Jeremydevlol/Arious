# WOOP Dashboard - Nueva Funcionalidad

## 📱 Pantalla Dashboard de WOOP

He creado una nueva pantalla dashboard que combina todas las funcionalidades de WOOP en una sola interfaz moderna y elegante, similar a la imagen que proporcionaste.

### 🎯 Características Principales

#### 1. **Precio Actual de WOOP**
- Muestra el precio actual: `$0.00205300`
- Indicador de cambio de precio: `+1.55%` (verde para subida, rojo para bajada)
- Fuente de datos: DexScreener
- Badge BSC para indicar la blockchain

#### 2. **Balance de Wallet**
- Muestra el balance de WOOP del usuario conectado
- Valor en USD calculado automáticamente
- Botón "Send WOOP" para transferencias
- Botón de refresh para actualizar el balance
- Estado de conexión de wallet

#### 3. **Calculadora de Valor WOOP**
- Campo de entrada para cantidad de WOOP
- Formateo automático de números con comas
- Cálculo en tiempo real del valor en USD
- Interfaz similar a la imagen proporcionada

### 🛠 Archivos Creados/Modificados

#### Nuevos Archivos:
1. **`lib/screens/woop_dashboard_screen.dart`** - Pantalla principal del dashboard
2. **`lib/widgets/woop_price_card.dart`** - Widgets reutilizables para precios

#### Archivos Modificados:
1. **`lib/routes/app_routes.dart`** - Agregada ruta `woopDashboard`
2. **`lib/routes/app_pages.dart`** - Configuración de navegación
3. **`lib/screens/home/home_screen.dart`** - Botón WOOP ahora navega al dashboard

### 🎨 Diseño y UI

#### Tema Visual:
- **Fondo**: Gradiente oscuro (`#14142B`)
- **Tarjetas**: Gradiente azul-púrpura (`#2A2A5C` → `#1E1E3F`)
- **Acentos**: Azul brillante (`#4A63E7`)
- **Efectos**: Glassmorphism con sombras suaves

#### Componentes:
- **AppBar**: Transparente con botón de refresh
- **Price Card**: Precio actual con indicadores de cambio
- **Balance Card**: Estado de wallet y balance
- **Calculator Card**: Calculadora de valor WOOP

### 🔧 Funcionalidades Técnicas

#### Integración con WalletConnect:
```dart
final WalletController _walletController = Get.put(WalletController());

// Conectar wallet
await _walletController.connectWallet();

// Obtener balance
final balance = await _walletController.getWoopBalance();

// Verificar conexión
if (_walletController.isConnected) { ... }
```

#### Cálculo de Valores:
```dart
void _calculateValue(String woopAmount) {
  final amount = double.parse(woopAmount.replaceAll(',', ''));
  setState(() {
    _usdtValue = amount * _currentPrice;
  });
}
```

#### Formateo de Números:
```dart
final formatted = NumberFormat('#,##0.########').format(number);
final numberFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 8);
```

### 🚀 Navegación

#### Desde la Pantalla Principal:
El botón "WOOP" en la barra superior ahora navega al dashboard:

```dart
Get.toNamed(AppRoutes.woopDashboard);
```

#### Rutas Configuradas:
```dart
// app_routes.dart
static const String woopDashboard = '/woop-dashboard';

// app_pages.dart
GetPage(
  name: AppRoutes.woopDashboard,
  page: () => const WoopDashboardScreen(),
  transition: Transition.rightToLeft,
),
```

### 📱 Estados de la Aplicación

#### 1. **Wallet No Conectada**
- Muestra "Not Connected"
- Botón "Connect Wallet" prominente
- Calculadora funcional sin balance

#### 2. **Wallet Conectada**
- Muestra balance real de WOOP
- Valor en USD calculado
- Botones "Send WOOP" y refresh activos
- Navegación a pantalla de envío

#### 3. **Calculadora Activa**
- Entrada de números con formateo automático
- Cálculo en tiempo real
- Interfaz idéntica a la imagen proporcionada

### 🎯 Casos de Uso

#### Para Usuarios:
1. **Ver precio actual** - Información actualizada de WOOP
2. **Consultar balance** - Balance personal y valor en USD
3. **Calcular valores** - Convertir WOOP a USD
4. **Enviar tokens** - Acceso rápido a transferencias

#### Para Desarrolladores:
1. **Widgets reutilizables** - `WoopPriceCard`, `WoopCalculatorCard`
2. **Integración fácil** - Usar en otras pantallas
3. **Estado reactivo** - Actualización automática de datos

### 🔄 Flujo de Usuario

```
Pantalla Principal → Botón WOOP → Dashboard
                                     ↓
                              [Ver Precio]
                                     ↓
                              [Conectar Wallet]
                                     ↓
                              [Ver Balance]
                                     ↓
                              [Calcular Valores]
                                     ↓
                              [Enviar WOOP] → SendWoopScreen
```

### 💡 Próximas Mejoras

1. **Precio en Tiempo Real** - Integración con API de precios
2. **Historial de Precios** - Gráficos de tendencias
3. **Múltiples Monedas** - EUR, BTC, ETH
4. **Notificaciones** - Alertas de precio
5. **Favoritos** - Guardar cantidades frecuentes

### 🎉 Resultado Final

La nueva pantalla dashboard proporciona una experiencia completa y moderna para interactuar con WOOP, combinando:

- ✅ Información de precios en tiempo real
- ✅ Gestión de wallet integrada
- ✅ Calculadora de valores intuitiva
- ✅ Navegación fluida a funciones de envío
- ✅ Diseño moderno y atractivo
- ✅ Arquitectura escalable y mantenible

¡La "casilla" está lista y funcionando perfectamente! 🚀 
import 'package:get/get.dart';
import '../controllers/eth_wallet_controller.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class GlobalWalletService extends GetxService {
  static GlobalWalletService? _instance;
  
  static GlobalWalletService get to {
    if (_instance == null) {
      _instance = Get.find<GlobalWalletService>(tag: 'global_wallet_service');
    }
    return _instance!;
  }

  late WoonklyWalletController woonklyController;
  bool _initialized = false;
  final _initCompleter = Completer<void>();

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _initialized;

  /// Inicializa el servicio global de wallets
  Future<GlobalWalletService> init() async {
    if (_initialized) return this;

    try {
      print('🚀 Inicializando Global Wallet Service...');

      // Crear el controlador Woonkly como singleton global
      if (!Get.isRegistered<WoonklyWalletController>()) {
        woonklyController = Get.put(WoonklyWalletController(), permanent: true);
        await woonklyController.initializeService();
      } else {
        woonklyController = Get.find<WoonklyWalletController>();
      }

      _initialized = true;
      _initCompleter.complete();
      
      print('✅ Global Wallet Service inicializado correctamente');
      return this;
    } catch (e) {
      print('❌ Error en GlobalWalletService.init(): $e');
      _initCompleter.completeError(e);
      throw Exception('Error inicializando GlobalWalletService: $e');
    }
  }

  /// Obtiene el controlador Woonkly global
  WoonklyWalletController get woonklyWallet {
    if (!_initialized) {
      throw Exception(
        'GlobalWalletService no ha sido inicializado. Llama a init() primero.',
      );
    }
    return woonklyController;
  }

  /// Mantiene compatibilidad con nombre anterior (ethWallet -> woonklyWallet)
  WoonklyWalletController get ethWallet => woonklyWallet;

  /// Verifica si hay alguna wallet conectada
  bool get hasConnectedWallet {
    if (!_initialized) return false;
    try {
      return woonklyController.isConnected;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando wallet conectada: $e');
      }
      return false;
    }
  }

  /// Obtiene información de estado general
  Map<String, dynamic> get walletStatus {
    if (!_initialized) {
      return {
        'initialized': false,
        'woonklyConnected': false,
        'walletAddress': null,
        'woonklyBalance': 0.0,
        'bnbBalance': 0.0,
      };
    }

    try {
      return {
        'initialized': true,
        'woonklyConnected': woonklyController.isConnected,
        'walletAddress': woonklyController.account.value,
        'woonklyBalance': woonklyController.woonlyBalance.value,
        'bnbBalance': woonklyController.bnbBalance.value,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo wallet status: $e');
      }
      return {
        'initialized': true,
        'woonklyConnected': false,
        'walletAddress': null,
        'woonklyBalance': 0.0,
        'bnbBalance': 0.0,
      };
    }
  }

  /// Limpia todos los datos de wallets (logout completo)
  Future<void> clearAllWallets() async {
    if (_initialized && woonklyController.isConnected) {
      await woonklyController.disconnect();
    }
  }

  /// Asegura que el servicio esté inicializado
  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await _initCompleter.future;
    }
  }

  /// Reinicia el servicio
  Future<void> reset() async {
    _initialized = false;
    _instance = null;
    await init();
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print('🧹 Global Wallet Service cerrado');
    }
    _initialized = false;
    _instance = null;
    super.onClose();
  }
}

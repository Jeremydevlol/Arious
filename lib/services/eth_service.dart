import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';

class WoonklyService {
  // BSC Mainnet RPC endpoints
  static const _rpcUrl = 'https://bsc-dataseed1.binance.org/';
  // Backup RPC endpoints for BSC
  static const _backupRpcUrls = [
    'https://bsc-dataseed2.binance.org/',
    'https://bsc-dataseed3.binance.org/',
    'https://bsc-dataseed4.binance.org/',
    'https://bsc-dataseed1.defibit.io/',
    'https://bsc-dataseed2.defibit.io/',
  ];

  // Woonkly token contract address on BSC (dirección correcta confirmada)
  static const String _woonklyTokenAddress =
      '0xD686E8DFECFd976D80E5641489b7A18Ac16d965D';

  // Standard BEP-20 ABI for balanceOf and transfer functions
  static const String _bep20Abi = '''
  [
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [
        {"name": "_to", "type": "address"},
        {"name": "_value", "type": "uint256"}
      ],
      "name": "transfer",
      "outputs": [{"name": "", "type": "bool"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [{"name": "", "type": "uint8"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "symbol",
      "outputs": [{"name": "", "type": "string"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "name",
      "outputs": [{"name": "", "type": "string"}],
      "type": "function"
    }
  ]
  ''';

  late Web3Client _client;
  late DeployedContract _woonlyContract;
  late ContractFunction _balanceOfFunction;
  late ContractFunction _transferFunction;
  late ContractFunction _decimalsFunction;
  int _currentRpcIndex = 0;

  WoonklyService() {
    _client = Web3Client(_rpcUrl, Client());
    _initializeContract();
    if (kDebugMode) {
      print('✅ WoonklyService inicializado con BSC RPC: $_rpcUrl');
      print('📄 Woonkly Token Address: $_woonklyTokenAddress');
    }
  }

  /// Inicializa el contrato BEP-20 de Woonkly
  void _initializeContract() {
    final contract = ContractAbi.fromJson(_bep20Abi, 'WoonklyToken');
    _woonlyContract = DeployedContract(
      contract,
      EthereumAddress.fromHex(_woonklyTokenAddress),
    );

    _balanceOfFunction = _woonlyContract.function('balanceOf');
    _transferFunction = _woonlyContract.function('transfer');
    _decimalsFunction = _woonlyContract.function('decimals');
  }

  /// Cliente Web3 público
  Web3Client get client => _client;

  /// Obtiene el balance de BNB (para gas fees) de una dirección
  Future<EtherAmount> getBnbBalance(String address) async {
    try {
      if (kDebugMode) {
        print('🔍 Consultando balance BNB para dirección: $address');
      }

      // Validar que la dirección sea válida
      if (!address.startsWith('0x') || address.length != 42) {
        throw Exception('Dirección de BSC inválida: $address');
      }

      final balance = await _getBnbBalanceWithRetry(address);

      if (kDebugMode) {
        print(
          '✅ BNB Balance obtenido: ${balance.getValueInUnit(EtherUnit.ether)} BNB',
        );
      }

      return balance;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting BNB balance: $e');
      }
      rethrow;
    }
  }

  /// Obtiene el balance de tokens Woonkly de una dirección
  Future<double> getWoonklyBalance(String address) async {
    try {
      if (kDebugMode) {
        print('🔍 Consultando balance Woonkly para dirección: $address');
      }

      // Validar que la dirección sea válida
      if (!address.startsWith('0x') || address.length != 42) {
        throw Exception('Dirección de BSC inválida: $address');
      }

      final balance = await _getWoonklyBalanceWithRetry(address);

      if (kDebugMode) {
        print('✅ Woonkly Balance obtenido: $balance WOOP');
      }

      return balance;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting Woonkly balance: $e');
      }
      rethrow;
    }
  }

  /// Obtiene el balance BNB con retry logic usando múltiples RPC endpoints
  Future<EtherAmount> _getBnbBalanceWithRetry(String address) async {
    Exception? lastException;

    // Intentar con RPC principal
    try {
      final balance = await _client.getBalance(
        EthereumAddress.fromHex(address),
      );
      return balance;
    } catch (e) {
      lastException = Exception('RPC principal falló: $e');
      if (kDebugMode) {
        print('⚠️ RPC principal falló, intentando con backup RPCs...');
      }
    }

    // Intentar con RPCs de backup
    for (int i = 0; i < _backupRpcUrls.length; i++) {
      try {
        if (kDebugMode) {
          print('🔄 Intentando RPC backup: ${_backupRpcUrls[i]}');
        }

        final backupClient = Web3Client(_backupRpcUrls[i], Client());
        final balance = await backupClient.getBalance(
          EthereumAddress.fromHex(address),
        );

        if (kDebugMode) {
          print('✅ Balance BNB obtenido exitosamente con RPC backup');
        }

        backupClient.dispose();
        return balance;
      } catch (e) {
        lastException = Exception('RPC backup ${_backupRpcUrls[i]} falló: $e');
        if (kDebugMode) {
          print('⚠️ RPC backup ${_backupRpcUrls[i]} falló: $e');
        }
      }
    }

    throw lastException ?? Exception('Todos los RPCs fallaron');
  }

  /// Obtiene el balance de Woonkly tokens con retry logic
  Future<double> _getWoonklyBalanceWithRetry(String address) async {
    Exception? lastException;

    // Intentar con RPC principal
    try {
      final result = await _client.call(
        contract: _woonlyContract,
        function: _balanceOfFunction,
        params: [EthereumAddress.fromHex(address)],
      );

      final balance = result.first as BigInt;
      // Conversión segura: dividir como BigInt primero, luego convertir a double
      return _safeWeiToWoonkly(balance);
    } catch (e) {
      lastException = Exception('RPC principal falló: $e');
      if (kDebugMode) {
        print(
          '⚠️ RPC principal falló para Woonkly balance, intentando con backup RPCs...',
        );
      }
    }

    // Intentar con RPCs de backup
    for (int i = 0; i < _backupRpcUrls.length; i++) {
      try {
        if (kDebugMode) {
          print('🔄 Intentando RPC backup para Woonkly: ${_backupRpcUrls[i]}');
        }

        final backupClient = Web3Client(_backupRpcUrls[i], Client());
        final contract = ContractAbi.fromJson(_bep20Abi, 'WoonklyToken');
        final deployedContract = DeployedContract(
          contract,
          EthereumAddress.fromHex(_woonklyTokenAddress),
        );

        final result = await backupClient.call(
          contract: deployedContract,
          function: deployedContract.function('balanceOf'),
          params: [EthereumAddress.fromHex(address)],
        );

        final balance = result.first as BigInt;
        final balanceFormatted = _safeWeiToWoonkly(balance);

        if (kDebugMode) {
          print('✅ Balance Woonkly obtenido exitosamente con RPC backup');
        }

        backupClient.dispose();
        return balanceFormatted;
      } catch (e) {
        lastException = Exception('RPC backup ${_backupRpcUrls[i]} falló: $e');
        if (kDebugMode) {
          print('⚠️ RPC backup ${_backupRpcUrls[i]} falló: $e');
        }
      }
    }

    throw lastException ??
        Exception('Todos los RPCs fallaron para Woonkly balance');
  }

  /// Convierte Wei a Woonkly de forma segura manejando números grandes
  double _safeWeiToWoonkly(BigInt wei) {
    try {
      // Dividir como BigInt primero para evitar overflow en la conversión a double
      final divisor = BigInt.from(10).pow(18);
      final integerPart = wei ~/ divisor;
      final fractionalPart = wei % divisor;

      // Convertir la parte entera y fraccionaria por separado
      final integerDouble = integerPart.toDouble();
      final fractionalDouble = fractionalPart.toDouble() / divisor.toDouble();

      return integerDouble + fractionalDouble;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error en conversión segura, usando conversión simple: $e');
      }
      // Fallback: intentar conversión simple
      try {
        return wei.toDouble() / BigInt.from(10).pow(18).toDouble();
      } catch (e2) {
        if (kDebugMode) {
          print('❌ Error crítico en conversión de balance: $e2');
        }
        // En caso de error total, retornar 0
        return 0.0;
      }
    }
  }

  /// Obtiene la URL del RPC actual
  String _getCurrentRpcUrl() {
    if (_currentRpcIndex == 0) {
      return _rpcUrl;
    }
    return _backupRpcUrls[_currentRpcIndex - 1];
  }

  /// Convierte Wei a BNB (formato legible)
  double weiToBnb(BigInt wei) {
    return _safeWeiToWoonkly(wei); // Misma lógica de conversión segura
  }

  /// Convierte BNB a Wei
  BigInt bnbToWei(double bnb) {
    return BigInt.from((bnb * BigInt.from(10).pow(18).toDouble()).toInt());
  }

  /// Convierte Woonkly tokens a su representación en Wei (18 decimales)
  BigInt woonklyToWei(double woonkly) {
    return BigInt.from((woonkly * BigInt.from(10).pow(18).toDouble()).toInt());
  }

  /// Convierte Wei a Woonkly tokens
  double weiToWoonkly(BigInt wei) {
    return _safeWeiToWoonkly(wei);
  }

  /// Construye los datos para una transferencia de tokens Woonkly
  Map<String, String> buildWoonklyTransferTransaction({
    required String from,
    required String to,
    required double amount,
  }) {
    if (kDebugMode) {
      print('🔧 Construyendo transacción Woonkly:');
      print('   From: $from');
      print('   To: $to');
      print('   Amount: $amount WOOP');
    }

    final amountWei = woonklyToWei(amount);

    // Encode the transfer function call
    final transferCall = _transferFunction.encodeCall([
      EthereumAddress.fromHex(to),
      amountWei,
    ]);

    return {
      'from': from,
      'to': _woonklyTokenAddress,
      'data':
          '0x${transferCall.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}',
      'gas': '0x186A0', // 100000 gas para transferencias BEP-20
      'gasPrice': '0x12A05F200', // 5 Gwei para BSC
      'value': '0x0', // No BNB value for token transfers
    };
  }

  /// Estima el gas necesario para una transferencia de tokens
  Future<BigInt> estimateGasForTransfer({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      final amountWei = woonklyToWei(amount);

      final gasEstimate = await _client.estimateGas(
        sender: EthereumAddress.fromHex(from),
        to: EthereumAddress.fromHex(_woonklyTokenAddress),
        data: _transferFunction.encodeCall([
          EthereumAddress.fromHex(to),
          amountWei,
        ]),
      );

      if (kDebugMode) {
        print('✅ Gas estimate para transferencia Woonkly: $gasEstimate');
      }

      return gasEstimate;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error estimating gas for Woonkly transfer: $e');
      }
      // Retornar gas por defecto para transferencias BEP-20
      return BigInt.from(100000);
    }
  }

  /// Obtiene el precio actual del gas con retry logic (BSC suele ser más barato)
  Future<EtherAmount> getGasPrice() async {
    try {
      final gasPrice = await _client.getGasPrice();

      if (kDebugMode) {
        print(
          '✅ BSC Gas price: ${gasPrice.getValueInUnit(EtherUnit.gwei)} Gwei',
        );
      }

      return gasPrice;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting BSC gas price: $e');
      }
      // Retornar 5 Gwei por defecto para BSC (más barato que ETH)
      return EtherAmount.fromUnitAndValue(EtherUnit.gwei, 5);
    }
  }

  /// Obtiene información del token Woonkly (nombre, símbolo, decimales)
  Future<Map<String, dynamic>> getTokenInfo() async {
    try {
      // Get token name
      final nameResult = await _client.call(
        contract: _woonlyContract,
        function: _woonlyContract.function('name'),
        params: [],
      );

      // Get token symbol
      final symbolResult = await _client.call(
        contract: _woonlyContract,
        function: _woonlyContract.function('symbol'),
        params: [],
      );

      // Get token decimals
      final decimalsResult = await _client.call(
        contract: _woonlyContract,
        function: _decimalsFunction,
        params: [],
      );

      return {
        'name': nameResult.first as String,
        'symbol': symbolResult.first as String,
        'decimals': (decimalsResult.first as BigInt).toInt(),
        'address': _woonklyTokenAddress,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting token info: $e');
      }
      // Return default values if call fails
      return {
        'name': 'Woonkly',
        'symbol': 'WOOP',
        'decimals': 18,
        'address': _woonklyTokenAddress,
      };
    }
  }

  /// Libera recursos
  void dispose() {
    _client.dispose();
    if (kDebugMode) {
      print('🔌 WoonklyService disposed');
    }
  }
}

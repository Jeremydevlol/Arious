import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/global_wallet_service.dart';

class WalletServiceInitializer extends StatefulWidget {
  final Widget child;

  const WalletServiceInitializer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<WalletServiceInitializer> createState() => _WalletServiceInitializerState();
}

class _WalletServiceInitializerState extends State<WalletServiceInitializer> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeWalletService();
  }

  Future<void> _initializeWalletService() async {
    try {
      if (!Get.isRegistered<GlobalWalletService>(tag: 'global_wallet_service')) {
        print('🚀 Initializing Global Wallet Service...');
        final walletService = await Get.putAsync(
          () => GlobalWalletService().init(),
          permanent: true,
          tag: 'global_wallet_service',
        );
        await walletService.ensureInitialized();
        print('✅ Global Wallet Service initialized successfully');
      } else {
        final walletService = Get.find<GlobalWalletService>(tag: 'global_wallet_service');
        if (!walletService.isInitialized) {
          print('🔄 Resetting Global Wallet Service...');
          await walletService.reset();
          print('✅ Global Wallet Service reset successfully');
        } else {
          print('✅ Global Wallet Service already initialized');
        }
      }
    } catch (e) {
      print('❌ Error initializing Global Wallet Service: $e');
      // Try to recover by resetting the service
      try {
        if (Get.isRegistered<GlobalWalletService>(tag: 'global_wallet_service')) {
          final walletService = Get.find<GlobalWalletService>(tag: 'global_wallet_service');
          print('🔄 Attempting to reset Global Wallet Service...');
          await walletService.reset();
          print('✅ Global Wallet Service reset successfully');
        } else {
          print('⚠️ Global Wallet Service not registered, creating new instance...');
          final walletService = await Get.putAsync(
            () => GlobalWalletService().init(),
            permanent: true,
            tag: 'global_wallet_service',
          );
          await walletService.ensureInitialized();
          print('✅ Global Wallet Service initialized successfully');
        }
      } catch (e) {
        print('❌ Fatal error in Global Wallet Service: $e');
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error initializing wallet service\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializationFuture = _initializeWalletService();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return widget.child;
      },
    );
  }
} 
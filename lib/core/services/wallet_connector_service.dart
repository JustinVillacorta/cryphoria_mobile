import 'dart:async';

/// A stub service that simulates a WalletConnect flow.
///
/// In a real implementation this would use a WalletConnect library
/// to establish a session with the selected wallet application and
/// return the wallet address along with a signature proving ownership.
class WalletConnectorService {
  /// Initiates a WalletConnect session for the provided [walletType].
  ///
  /// The returned [Map] contains the `address` and `signature` keys.
  /// This placeholder implementation simply waits briefly and returns
  /// dummy values. Replace with real wallet connection logic.
  Future<Map<String, String>> connect(String walletType) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'address': '0x0000000000000000000000000000000000000000',
      'signature': 'dummy-signature',
    };
  }
}

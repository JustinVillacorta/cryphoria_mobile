import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

/// Service responsible for connecting to wallets via WalletConnect and
/// returning the connected address and a signed message.
class WalletConnectorService {
  late final Web3App _web3App;

  WalletConnectorService({
    required String projectId,
    String relayUrl = 'wss://relay.walletconnect.com',
  }) {
    _web3App = Web3App(
      projectId: projectId,
      relayUrl: relayUrl,
      metadata: const PairingMetadata(
        name: 'Cryphoria',
        description: 'Cryphoria Wallet Connector',
        url: 'https://cryphoria.app',
        icons: [],
      ),
    );
  }

  /// Connects to the specified [wallet] and requests a signature for [message].
  ///
  /// Returns a tuple containing the connected address and the resulting
  /// signature.
  Future<(String, String)> connectAndSign({
    required String wallet,
    required String message,
  }) async {
    final session = await _web3App.connect(
      requiredNamespaces: const {
        'eip155': RequiredNamespace(
          chains: ['eip155:1'],
          methods: ['personal_sign'],
          events: [],
        ),
      },
      onDisplayUri: (uri) async {
        final link = _buildDeepLink(wallet, uri);
        await launchUrl(Uri.parse(link),
            mode: LaunchMode.externalApplication);
      },
    );

    final account =
        session.namespaces['eip155']!.accounts.first.split(':').last;

    final signature = await _web3App.request(
      topic: session.topic,
      chainId: 'eip155:1',
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [message, account],
      ),
    );

    return (account, signature as String);
  }

  String _buildDeepLink(String wallet, String uri) {
    switch (wallet.toLowerCase()) {
      case 'metamask':
        return 'metamask://wc?uri=$uri';
      case 'coinbase':
        return 'coinbase://wc?uri=$uri';
      case 'trust':
      case 'trustwallet':
        return 'trust://wc?uri=$uri';
      default:
        return uri;
    }
  }
}

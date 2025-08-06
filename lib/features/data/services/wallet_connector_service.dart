import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

/// A dApp-side connector that spins up a headless WalletConnect v2 client
/// and exposes a single method to connect & sign a message.
class WalletConnectorService {
  final Web3App _web3App;

  WalletConnectorService._(this._web3App);

  /// Async factory—instantiates and configures the WalletConnect client.
  static Future<WalletConnectorService> create({
    required String projectId,
    String relayUrl = 'wss://relay.walletconnect.com',
  }) async {
    final web3App = await Web3App.createInstance(
      projectId: projectId,
      relayUrl: relayUrl,
      metadata: const PairingMetadata(
        name: 'Cryphoria',
        description: 'Cryphoria dApp Connector',
        url: 'https://cryphoria.app',
        icons: [],
        redirect: Redirect(
          native: 'cryphoria://',
          universal: 'https://cryphoria.app',
        ),
      ),
    );
    return WalletConnectorService._(web3App);
  }

  /// Triggers a WalletConnect pairing flow on [wallet], then issues a
  /// `personal_sign` for [message]. Returns (address, signature).
  Future<(String, String)> connectAndSign({
    required String wallet,   // e.g. 'MetaMask'
    required String message,  // the plain-text to sign
  }) async {
    // 1️⃣ Kick off the connect → this returns a pairing URI + a session Future
    Future<(String, String)> connectAndSign({
  required String wallet,
  required String message,
}) async {
  // 1) Kick off pairing & get back a URI + a session Future
  final resp = await _web3App.connect(
    optionalNamespaces: const {
      'eip155': RequiredNamespace(
        chains:  ['eip155:1'],
        methods: ['personal_sign'],
        events:  [],
      ),
    },
  ); // :contentReference[oaicite:0]{index=0}

  // 2) Deep-link your wallet app with the URI
  final uri = resp.uri;
  if (uri != null) {
    final encoded = Uri.encodeComponent(uri.toString());
    final link = _buildDeepLink(wallet, encoded);
    await launchUrl(Uri.parse(link),
        mode: LaunchMode.externalApplication);
  }

  // 3) Wait for the user to approve and establish the session
  final session = await resp.session.future;

  // 4) Pull out the account (strip off "eip155:1:")
  final account = session
      .namespaces['eip155']!
      .accounts
      .first
      .split(':')
      .last;

  // 5) Send your personal_sign request
  final signature = await _web3App.request(
    topic:   session.topic,
    chainId: 'eip155:1',
    request: SessionRequestParams(
      method: 'personal_sign',
      params: [message, account],
    ),
  );

  return (account, signature as String);
}
    final resp = await _web3App.connect(
      optionalNamespaces: const {
        'eip155': RequiredNamespace(
          chains: ['eip155:1'],
          methods: ['personal_sign'],
          events: [],
        ),
      },
    );

    // 2️⃣ Deep-link the wallet app with the pairing URI
    final uri = resp.uri;
    if (uri != null) {
      final encoded = Uri.encodeComponent(uri.toString());
      final link = _buildDeepLink(wallet, encoded);
      await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    }

    // 3️⃣ Wait for user to approve and establish the session
    final session = await resp.session.future;

    // 4️⃣ Pull out the account (strip off "eip155:1:")
    final account = session.namespaces['eip155']!
        .accounts.first.split(':').last;

    // 5️⃣ Send your personal_sign request
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

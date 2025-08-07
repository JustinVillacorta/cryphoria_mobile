# Cryphoria Mobile

## Wallet Connection Flow

The app connects to a user wallet using a simple private–key dialog. On a
successful connection the key is stored locally in encrypted storage and the
wallet balance is fetched from the backend. Callers must now specify which
wallet to connect by providing both the API endpoint and wallet name. Use the
`connect_trust_wallet/` endpoint with the name `Mobile Wallet` for Trust Wallet
or `connect_metamask/` with the name `MetaMask` for MetaMask.

### Endpoints

| Action | Endpoint |
|--------|----------|
| Connect (Trust Wallet) | `POST /api/wallets/connect_trust_wallet/` |
| Connect (MetaMask) | `POST /api/wallets/connect_metamask/` |
| Get Balance | `GET /api/wallets/get_wallet_balance/` |
| Reconnect | `POST /api/wallets/reconnect_wallet_with_private_key/` |

### Running Tests

```
flutter test
```

If Flutter or Dart are not installed the command will fail. Install the
Flutter SDK and run the tests again after fetching packages with
`flutter pub get`.


# Cryphoria Mobile

## Wallet Connection Flow

The app connects to a user wallet using a simple private–key dialog. On a
successful connection the key is stored locally in encrypted storage and the
wallet balance is fetched from the backend.

### Endpoints

| Action | Endpoint |
|--------|----------|
| Connect | `POST /api/wallets/connect_trust_wallet/` |
| Get Balance | `POST /api/wallets/get_specific_wallet_balance/` |
| Reconnect | `POST /api/wallets/reconnect_wallet_with_private_key/` |

### Running Tests

```
flutter test
```

If Flutter or Dart are not installed the command will fail. Install the
Flutter SDK and run the tests again after fetching packages with
`flutter pub get`.


# Services layer

`MockDataService` is the source of mock data most of the app still runs
on, returned as the app's real model types (`CryptoAsset` — which now
carries the platform's own `buyRateNgn`/`sellRateNgn` per asset —
`TransactionModel`, `AppNotification`, `AppUser`). Every provider in
`lib/providers/` reads from it, except `AuthProvider`, which already
talks to real Firebase Auth via `auth_repository.dart` — see the setup
steps at the top of `lib/main.dart`.

## Wiring the rest of Firebase in later

Because providers only ever see the model types (never mock-specific
shapes), swapping mock data for live data means changing the provider
constructors, not the UI:

1. Create repository classes here, e.g. `wallet_repository.dart`,
   `transaction_repository.dart`, `trade_repository.dart`,
   `notification_repository.dart`, each wrapping the relevant
   `cloud_firestore` calls and mapping Firestore documents to the
   existing models (add `fromMap`/`toMap` constructors to the models as
   you do this).
2. In each provider (`WalletProvider`, `TransactionProvider`,
   `TradeProvider`, etc.), replace the `MockDataService.instance.*` call
   with a call into the new repository, and listen to Firestore
   snapshots instead of holding a static list.
3. Suggested Firestore collections: `users`, `wallets`, `assets` (with
   `buyRateNgn`/`sellRateNgn` fields you update from an admin tool —
   there's no merchant marketplace here, so no `p2pOffers` collection),
   `tradeOrders`, `transactions`, `notifications`, `airtimeTransactions`,
   `dataTransactions`, `paymentMethods`, `kyc`, `settings`. Secure them
   with rules that scope reads/writes to `request.auth.uid` under
   `users/{uid}` and its subcollections; `assets` (the rates) should be
   publicly readable but writable only by an admin role.
4. Real-money paths (withdraw, a trade order completing, airtime/data
   payment) should move to Cloud Functions once wired up — in
   particular, `TradeOrderScreen`'s "payment verified" / "payout sent"
   transitions currently just simulate a delay client-side and should
   become a Cloud Function reacting to your bank webhook / admin action,
   not something the client marks complete on its own.

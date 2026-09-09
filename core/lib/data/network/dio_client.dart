library;

// Re-export of the application-wide Dio builder.
//
// The canonical implementation lives in `api_http_client.dart` (foundation).
// This file exists to satisfy the plan path `data/network/dio_client.dart`
// and keeps imports stable (constitution I, no ad-hoc endpoints).
export 'api_http_client.dart';

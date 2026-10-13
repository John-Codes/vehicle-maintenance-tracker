import 'dart:async';

/// Platform-agnostic byte pipe to an ELM327-compatible adapter.
/// Every scanner shares the same AT-command engine over this interface;
/// adding a scanner = adding a transport + a registry entry.
abstract class ObdTransport {
  /// True when this transport can run on the current platform.
  bool get isSupported;

  /// Scan for nearby adapters; returns (deviceId, displayName) pairs.
  Future<List<DiscoveredAdapter>> discover({Duration timeout});

  /// Open the connection to one adapter found via discover().
  Future<void> connect(String deviceId);

  /// Write one AT command (terminator added by the transport).
  Future<void> send(String command);

  /// Raw text chunks coming back from the adapter.
  Stream<String> get responses;

  Future<void> disconnect();
}

class DiscoveredAdapter {
  final String deviceId;
  final String displayName;
  final int rssi;

  const DiscoveredAdapter(this.deviceId, this.displayName, this.rssi);

  @override
  String toString() => '$displayName ($rssi dBm)';
}

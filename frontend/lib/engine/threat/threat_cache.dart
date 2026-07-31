import 'threat_models.dart';

class ThreatCache {
  static final ThreatCache _instance = ThreatCache._internal();
  factory ThreatCache() => _instance;
  ThreatCache._internal();

  final Map<String, ThreatSummary> _cache = {};
  static const Duration _ttl = Duration(hours: 24);

  void put(String url, ThreatSummary summary) {
    _cache[url] = summary;
  }

  ThreatSummary? get(String url) {
    final entry = _cache[url];
    if (entry != null) {
      if (DateTime.now().difference(entry.timestamp) < _ttl) {
        return entry;
      } else {
        _cache.remove(url);
      }
    }
    return null;
  }

  void clear() {
    _cache.clear();
  }
}

import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _defaultBaseUrl = 'https://equinosycaninos.com/api';
  static const String _wwwBaseUrl = 'https://www.equinosycaninos.com/api';
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl => baseUrlCandidates.first;

  static List<String> get baseUrlCandidates {
    final urls = <String>[];

    void addUrl(String value) {
      final clean = value.trim();
      if (clean.isEmpty) return;
      final normalized = clean.endsWith('/')
          ? clean.substring(0, clean.length - 1)
          : clean;
      if (!urls.contains(normalized)) {
        urls.add(normalized);
      }
    }

    addUrl(_envBaseUrl);

    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase().trim();
      const localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};
      if (host.isNotEmpty && !localHosts.contains(host)) {
        addUrl('${Uri.base.origin}/api');
      }
    }

    addUrl(_defaultBaseUrl);
    addUrl(_wwwBaseUrl);

    return urls;
  }

  static List<Uri> uriCandidates(String path, [Map<String, String>? query]) {
    return baseUrlCandidates
        .map((base) => Uri.parse('$base$path').replace(queryParameters: query))
        .toList();
  }

  static List<Uri> alternativeUrisFor(Uri uri) {
    final suffix = uri.path == '/api'
        ? ''
        : uri.path.startsWith('/api/')
        ? uri.path.substring(4)
        : uri.path;

    final candidates = uriCandidates(
      suffix,
      uri.queryParameters.isEmpty ? null : uri.queryParameters,
    );

    return candidates.where((candidate) => candidate != uri).toList();
  }

  static String get publicBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

  static String storageUrl(String path) {
    final clean = path.trim();
    if (clean.isEmpty) return '';
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    final normalized = clean.startsWith('/') ? clean.substring(1) : clean;
    return '$publicBaseUrl/storage/$normalized';
  }
}

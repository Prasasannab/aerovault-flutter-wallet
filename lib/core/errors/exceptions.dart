/// Core banking exceptions
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class SecurityException implements Exception {
  final String message;

  const SecurityException({required this.message});

  @override
  String toString() => 'SecurityException: $message';
}

class DeviceCompromisedException implements Exception {
  final String message;
  final List<String> reasons;

  const DeviceCompromisedException({
    required this.message,
    required this.reasons,
  });

  @override
  String toString() => 'DeviceCompromisedException: $message ($reasons)';
}

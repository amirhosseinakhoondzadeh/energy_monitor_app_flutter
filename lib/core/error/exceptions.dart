class ServerException implements Exception {
  final String? message;
  final int? code;

  const ServerException({this.message, this.code});
}

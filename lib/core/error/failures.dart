import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = ""]);

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    if (message.isEmpty) {
      return '<<< No message provided for this Failure: $runtimeType >>>';
    }
    return message;
  }
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

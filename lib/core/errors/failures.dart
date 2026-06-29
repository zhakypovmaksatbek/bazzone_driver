abstract class Failure {
  const Failure(this.message);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Sunucu hatası']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'İnternet bağlantısı yok']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Önbellek hatası']);
}

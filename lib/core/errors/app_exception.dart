sealed class AppException implements Exception {
  final String message;
  final String? detail;

  const AppException(this.message, {this.detail});

  @override
  String toString() => detail != null ? '$message\n$detail' : message;
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.detail});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.detail});
}

class PdfException extends AppException {
  const PdfException(super.message, {super.detail});
}

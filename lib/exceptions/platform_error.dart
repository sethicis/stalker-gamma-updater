class PlatformError extends Error {
}

class UnsupportedPlatformError extends PlatformError {
  final String message;

  UnsupportedPlatformError(
    this.message,
  );

  @override
  String toString() {
    return message;
  }
}

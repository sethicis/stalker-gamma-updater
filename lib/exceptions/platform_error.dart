class PlatformError extends Error {}

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

class InvalidChecksumError extends Error {
  final String fileHash;
  final String expectedHash;

  InvalidChecksumError(this.fileHash, this.expectedHash);

  @override
  String toString() {
    return "Checksum mismatch. Expected: $expectedHash, got: $fileHash";
  }
}

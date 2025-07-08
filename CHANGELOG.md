## [1.0.0] - 2025-01-08

### Added
- Initial release of RuStore Install Referrer plugin
- Support for RuStore SDK 7.0.0+
- `getInstallReferrer()` method to retrieve install referrer data from RuStore
- `ReferrerDetails` class with comprehensive referrer information:
  - `packageName` - app package name
  - `referrerId` - referrer ID from advertising link
  - `receivedTimestamp` - when referrer was received
  - `installAppTimestamp` - when app installation began
  - `versionCode` - app version code (nullable)
- `RuStoreInstallReferrerException` for proper error handling
- Support for multiple error types:
  - `REFERRER_NOT_FOUND` - referrer not available or expired
  - `RU_STORE_NOT_INSTALLED` - RuStore not installed on device
  - `RU_STORE_OUTDATED` - RuStore version too old
  - `RU_STORE_ERROR` - general RuStore SDK error
  - `UNKNOWN_ERROR` - unexpected errors
- `getErrorDescription()` method for human-readable error messages
- Comprehensive documentation and examples
- Android platform support (minimum SDK 23)
- MIT License
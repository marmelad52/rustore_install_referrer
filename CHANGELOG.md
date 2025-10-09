## [2.0.1] - 2025-10-09

### Fixed
- Shortened `pubspec.yaml` description to meet pub.dev 180 character limit
- Fixed code formatting to comply with Dart style guide
- Achieved perfect 160/160 pub points score on pub.dev

---

## [2.0.0] - 2025-10-09

### Changed
- **Breaking**: Updated RuStore Install Referrer SDK from 7.0.0 to 10.0.0
- InstallReferrerClient now initialized once and reused

### Added
- `sendAuthEvent()` method for VK Ads Full Stream Attribution
- Support for sending user phone number to VK Ads attribution system
- New error codes: `MISSING_PHONE_NUMBER`, `MISSING_AUTH_TOKEN`, `INVALID_PHONE_NUMBER`, `CLIENT_NOT_INITIALIZED`
- Error descriptions for new error codes

### Notes
- All existing API (`getInstallReferrer()`) works without changes
- New functionality is optional
- No migration required for existing code

---

## [1.0.0] - 2025-01-08

### Added
- Initial release
- Support for RuStore SDK 7.0.0+
- `getInstallReferrer()` method
- `ReferrerDetails` class with install information
- `RuStoreInstallReferrerException` for error handling
- Error codes: `REFERRER_NOT_FOUND`, `RU_STORE_NOT_INSTALLED`, `RU_STORE_OUTDATED`, `RU_STORE_ERROR`, `UNKNOWN_ERROR`
- `getErrorDescription()` method
- Android platform support (minimum SDK 23)
- MIT License
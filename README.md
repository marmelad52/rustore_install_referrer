# RuStore Install Referrer

**Language / Язык:** [🇺🇸 English](#english) | [🇷🇺 Русский](#russian)

---

## English

A Flutter plugin for getting install referrer information from RuStore (Russian app store). This plugin allows you to track app installations that came from advertising links and measure the effectiveness of your marketing campaigns.

### Features

- 🎯 Get install referrer information from RuStore
- 📊 Track advertising campaign effectiveness
- 🔒 Secure referrer retrieval with proper error handling
- ⚡ Multiple API methods for different use cases
- 🛡️ Safe methods that don't throw exceptions
- ⏱️ Timeout support for network requests
- 🔄 Automatic availability checking
- 📱 Supports RuStore SDK 7.0.0+

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  rustore_install_referrer: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Android Setup

#### 1. Add RuStore repository

**For build.gradle:**
```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://artifactory-external.vkpartner.ru/artifactory/maven")
        }
    }
}
```

**For build.gradle.kts:**
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://artifactory-external.vkpartner.ru/artifactory/maven")
        }
    }
}
```

#### 2. Add dependency

**For build.gradle:**
```gradle
dependencies {
    implementation("ru.rustore.sdk:installreferrer:7.0.0")
}
```

**For build.gradle.kts:**
```kotlin
dependencies {
    implementation("ru.rustore.sdk:installreferrer:7.0.0")
}
```

#### 3. Minimum SDK version

**For build.gradle.kts:**
```kotlin
android {
    defaultConfig {
        minSdk = 23
        // ...
    }
}
```

### Usage

#### Basic Usage

```dart
import 'package:rustore_install_referrer/rustore_install_referrer.dart';

try {
  final details = await RustoreInstallReferrer.getInstallReferrer();
  print('Install Referrer: ${details.installReferrer}');
  print('Click Time: ${details.referrerClickTime}');
  print('Install Time: ${details.installBeginTime}');
  print('Has Referrer: ${details.hasReferrer}');
} on RuStoreInstallReferrerException catch (e) {
  print('Error: ${e.code} - ${e.message}');
}
```

#### Safe Usage (No Exceptions)

```dart
final result = await RustoreInstallReferrer.getInstallReferrerSafe();
if (result.isSuccess) {
  print('Referrer: ${result.referrerDetails!.installReferrer}');
} else {
  print('Error: ${result.error!.message}');
}
```

#### Get Only Referrer String

```dart
final referrer = await RustoreInstallReferrer.getInstallReferrerString();
print('Referrer: $referrer'); // Empty string if not available
```

#### Check RuStore Availability

```dart
final isAvailable = await RustoreInstallReferrer.isRuStoreAvailable();
if (isAvailable) {
  // RuStore is installed and supports Install Referrer API
} else {
  // RuStore is not available
}
```

#### With Timeout

```dart
try {
  final details = await RustoreInstallReferrer.getInstallReferrerWithTimeout(
    timeout: Duration(seconds: 5),
  );
  print('Referrer: ${details.installReferrer}');
} on RuStoreInstallReferrerException catch (e) {
  if (e.code == 'TIMEOUT') {
    print('Request timed out');
  }
}
```

### API Reference

#### ReferrerDetails

| Property | Type | Description |
|----------|------|-------------|
| `installReferrer` | `String` | The referrer value from the advertising link |
| `referrerClickTimestampSeconds` | `int` | When the user clicked the referrer link (device time) |
| `installBeginTimestampSeconds` | `int` | When the app installation began (device time) |
| `referrerClickTimestampServerSeconds` | `int` | When the user clicked the referrer link (server time) |
| `installBeginTimestampServerSeconds` | `int` | When the app installation began (server time) |
| `installVersion` | `String?` | App version when referrer was obtained |

#### Available Methods

| Method | Description |
|--------|-------------|
| `getInstallReferrer()` | Main method, throws exceptions on error |
| `getInstallReferrerSafe()` | Safe method, returns result object |
| `getInstallReferrerString()` | Returns only referrer string |
| `getInstallReferrerWithTimeout()` | With custom timeout |
| `isRuStoreAvailable()` | Check if RuStore is available |
| `isReferrerAlreadyConsumed()` | Check if referrer was already retrieved |
| `getErrorDescription()` | Get human-readable error description |

### Error Handling

#### Exception Types

The plugin throws `RuStoreInstallReferrerException` with the following error codes:

| Error Code | Description |
|------------|-------------|
| `REFERRER_NOT_FOUND` | Referrer not found (already consumed, no referrer, or expired) |
| `RU_STORE_NOT_INSTALLED` | RuStore is not installed on the device |
| `RU_STORE_OUTDATED` | RuStore version is too old |
| `RU_STORE_ERROR` | General RuStore SDK error |
| `TIMEOUT` | Request timed out |
| `UNKNOWN_ERROR` | Unknown error occurred |

#### Example Error Handling

```dart
try {
  final details = await RustoreInstallReferrer.getInstallReferrer();
  // Handle success
} on RuStoreInstallReferrerException catch (e) {
  switch (e.code) {
    case 'REFERRER_NOT_FOUND':
      print('No referrer available');
      break;
    case 'RU_STORE_NOT_INSTALLED':
      print('Please install RuStore');
      break;
    case 'RU_STORE_OUTDATED':
      print('Please update RuStore');
      break;
    default:
      print('Error: ${e.message}');
  }
}
```

### How RuStore Install Referrer Works

1. **Advertising Link**: User clicks on a RuStore advertising link like:
   ```
   https://www.rustore.ru/catalog/app/com.yourapp?referrerId=campaign123
   ```

2. **Installation**: When user installs the app, RuStore stores the `referrerId` value

3. **Retrieval**: Your app can retrieve this referrer value using this plugin

4. **One-time Use**: The referrer can only be retrieved once, then it's deleted

5. **Expiration**: If not retrieved within 10 days, the referrer expires

### Important Notes

- ⚠️ **One-time use**: Install referrer can only be retrieved once
- ⏰ **Expiration**: Referrer data expires after 10 days
- 📱 **RuStore required**: Requires RuStore to be installed on the device
- 🔒 **Security**: Uses secure RuStore SDK for data retrieval

### Platform Support

| Platform | Support |
|----------|---------|
| Android | ✅ |
| iOS | ❌ (RuStore is Android-only) |

---

## Russian

Flutter плагин для получения информации о Install Referrer из RuStore (российский магазин приложений). Этот плагин позволяет отслеживать установки приложений, которые пришли из рекламных ссылок, и измерять эффективность ваших маркетинговых кампаний.

### Возможности

- 🎯 Получение информации о Install Referrer из RuStore
- 📊 Отслеживание эффективности рекламных кампаний
- 🔒 Безопасное получение referrer с корректной обработкой ошибок
- ⚡ Несколько методов API для разных случаев использования
- 🛡️ Безопасные методы, которые не выбрасывают исключения
- ⏱️ Поддержка таймаутов для сетевых запросов
- 🔄 Автоматическая проверка доступности
- 📱 Поддержка RuStore SDK 7.0.0+

### Установка

Добавьте это в файл `pubspec.yaml` вашего проекта:

```yaml
dependencies:
  rustore_install_referrer: ^1.0.0
```

Затем выполните:

```bash
flutter pub get
```

### Настройка Android

#### 1. Добавьте репозиторий RuStore

**Для build.gradle:**
```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://artifactory-external.vkpartner.ru/artifactory/maven")
        }
    }
}
```

**Для build.gradle.kts:**
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://artifactory-external.vkpartner.ru/artifactory/maven")
        }
    }
}
```

#### 2. Добавьте зависимость

**Для build.gradle:**
```gradle
dependencies {
    implementation("ru.rustore.sdk:installreferrer:7.0.0")
}
```

**Для build.gradle.kts:**
```kotlin
dependencies {
    implementation("ru.rustore.sdk:installreferrer:7.0.0")
}
```

#### 3. Минимальная версия SDK

**Для build.gradle.kts:**
```kotlin
android {
    defaultConfig {
        minSdk = 23
        // ...
    }
}
```

### Использование

#### Базовое использование

```dart
import 'package:rustore_install_referrer/rustore_install_referrer.dart';

try {
  final details = await RustoreInstallReferrer.getInstallReferrer();
  print('Install Referrer: ${details.installReferrer}');
  print('Время клика: ${details.referrerClickTime}');
  print('Время установки: ${details.installBeginTime}');
  print('Есть Referrer: ${details.hasReferrer}');
} on RuStoreInstallReferrerException catch (e) {
  print('Ошибка: ${e.code} - ${e.message}');
}
```

#### Безопасное использование (без исключений)

```dart
final result = await RustoreInstallReferrer.getInstallReferrerSafe();
if (result.isSuccess) {
  print('Referrer: ${result.referrerDetails!.installReferrer}');
} else {
  print('Ошибка: ${result.error!.message}');
}
```

#### Получить только строку Referrer

```dart
final referrer = await RustoreInstallReferrer.getInstallReferrerString();
print('Referrer: $referrer'); // Пустая строка если недоступен
```

#### Проверка доступности RuStore

```dart
final isAvailable = await RustoreInstallReferrer.isRuStoreAvailable();
if (isAvailable) {
  // RuStore установлен и поддерживает Install Referrer API
} else {
  // RuStore недоступен
}
```

#### С таймаутом

```dart
try {
  final details = await RustoreInstallReferrer.getInstallReferrerWithTimeout(
    timeout: Duration(seconds: 5),
  );
  print('Referrer: ${details.installReferrer}');
} on RuStoreInstallReferrerException catch (e) {
  if (e.code == 'TIMEOUT') {
    print('Истекло время ожидания');
  }
}
```

### Справочник API

#### ReferrerDetails

| Свойство | Тип | Описание |
|----------|-----|----------|
| `installReferrer` | `String` | Значение referrer из рекламной ссылки |
| `referrerClickTimestampSeconds` | `int` | Когда пользователь нажал на referrer ссылку (время устройства) |
| `installBeginTimestampSeconds` | `int` | Когда началась установка приложения (время устройства) |
| `referrerClickTimestampServerSeconds` | `int` | Когда пользователь нажал на referrer ссылку (время сервера) |
| `installBeginTimestampServerSeconds` | `int` | Когда началась установка приложения (время сервера) |
| `installVersion` | `String?` | Версия приложения при получении referrer |

#### Доступные методы

| Метод | Описание |
|-------|----------|
| `getInstallReferrer()` | Основной метод, выбрасывает исключения при ошибке |
| `getInstallReferrerSafe()` | Безопасный метод, возвращает объект результата |
| `getInstallReferrerString()` | Возвращает только строку referrer |
| `getInstallReferrerWithTimeout()` | С пользовательским таймаутом |
| `isRuStoreAvailable()` | Проверить доступность RuStore |
| `isReferrerAlreadyConsumed()` | Проверить, был ли referrer уже получен |
| `getErrorDescription()` | Получить читаемое описание ошибки |

### Обработка ошибок

#### Типы исключений

Плагин выбрасывает `RuStoreInstallReferrerException` со следующими кодами ошибок:

| Код ошибки | Описание |
|------------|----------|
| `REFERRER_NOT_FOUND` | Referrer не найден (уже использован, нет referrer или истек) |
| `RU_STORE_NOT_INSTALLED` | RuStore не установлен на устройстве |
| `RU_STORE_OUTDATED` | Версия RuStore устарела |
| `RU_STORE_ERROR` | Общая ошибка RuStore SDK |
| `TIMEOUT` | Истекло время ожидания |
| `UNKNOWN_ERROR` | Произошла неизвестная ошибка |

#### Пример обработки ошибок

```dart
try {
  final details = await RustoreInstallReferrer.getInstallReferrer();
  // Обработка успеха
} on RuStoreInstallReferrerException catch (e) {
  switch (e.code) {
    case 'REFERRER_NOT_FOUND':
      print('Referrer недоступен');
      break;
    case 'RU_STORE_NOT_INSTALLED':
      print('Пожалуйста, установите RuStore');
      break;
    case 'RU_STORE_OUTDATED':
      print('Пожалуйста, обновите RuStore');
      break;
    default:
      print('Ошибка: ${e.message}');
  }
}
```

### Как работает RuStore Install Referrer

1. **Рекламная ссылка**: Пользователь нажимает на рекламную ссылку RuStore вида:
   ```
   https://www.rustore.ru/catalog/app/com.yourapp?referrerId=campaign123
   ```

2. **Установка**: Когда пользователь устанавливает приложение, RuStore сохраняет значение `referrerId`

3. **Получение**: Ваше приложение может получить это значение referrer с помощью данного плагина

4. **Однократное использование**: Referrer можно получить только один раз, затем он удаляется

5. **Истечение**: Если не получить в течение 10 дней, referrer истекает

### Важные замечания

- ⚠️ **Однократное использование**: Install referrer можно получить только один раз
- ⏰ **Истечение**: Данные referrer истекают через 10 дней
- 📱 **Требуется RuStore**: Необходим установленный RuStore на устройстве
- 🔒 **Безопасность**: Использует безопасный RuStore SDK для получения данных

### Поддержка платформ

| Платформа | Поддержка |
|-----------|-----------|
| Android | ✅ |
| iOS | ❌ (RuStore только для Android) |
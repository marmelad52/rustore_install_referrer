# RuStore Install Referrer

**Language:** [English](#english) | [Русский](#russian)

---

## English

Flutter plugin for RuStore Install Referrer SDK (version 10.0.0). Track app installations from advertising links and measure marketing campaign effectiveness.

### Features

- Get install referrer information from RuStore
- Track advertising campaign sources
- VK Ads Full Stream Attribution support (v10.0.0+)
- Comprehensive error handling
- Supports RuStore SDK 10.0.0

### Installation

```yaml
dependencies:
  rustore_install_referrer: ^2.0.0
```

### Android Setup

**Add RuStore repository** in `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://artifactory-external.vkpartner.ru/artifactory/maven"
        }
    }
}
```

**Requirements:**
- Android SDK minimum 21
- Kotlin 1.8+

### Usage

#### Get Install Referrer

```dart
import 'package:rustore_install_referrer/rustore_install_referrer.dart';

try {
  final details = await RuStoreInstallReferrer.getInstallReferrer();
  
  print('Referrer ID: ${details.referrerId}');
  print('Package: ${details.packageName}');
  print('Received: ${details.receivedTime}');
  print('Installed: ${details.installAppTime}');
  
} on RuStoreInstallReferrerException catch (e) {
  print('Error: ${e.code} - ${e.message}');
}
```

#### Send Auth Event (VK Ads)

New in v10.0.0 - send user phone number to VK Ads for attribution:

```dart
try {
  await RuStoreInstallReferrer.sendAuthEvent(
    phoneNumber: '1234567890',
    authToken: 'your_vk_ads_token',
  );
} on RuStoreInstallReferrerException catch (e) {
  print('Error: ${e.code}');
}
```

**Note:** Auth token must be obtained from your VK Ads manager.

### API Reference

#### RuStoreReferrerDetails

| Property | Type | Description |
|----------|------|-------------|
| `packageName` | `String` | App package name |
| `referrerId` | `String` | Referrer ID from advertising link |
| `receivedTimestamp` | `int` | When referrer was received (ms) |
| `installAppTimestamp` | `int` | When installation began (ms) |
| `versionCode` | `int?` | App version code |

#### Methods

| Method | Description |
|--------|-------------|
| `getInstallReferrer()` | Get referrer details |
| `sendAuthEvent()` | Send auth event to VK Ads |
| `getErrorDescription(code)` | Get error description |

### Error Codes

| Code | Description |
|------|-------------|
| `REFERRER_NOT_FOUND` | Referrer not found or expired |
| `RU_STORE_NOT_INSTALLED` | RuStore not installed |
| `RU_STORE_OUTDATED` | RuStore version outdated |
| `RU_STORE_ERROR` | General RuStore SDK error |
| `MISSING_PHONE_NUMBER` | Phone number missing |
| `MISSING_AUTH_TOKEN` | Auth token missing |
| `INVALID_PHONE_NUMBER` | Invalid phone format |

### How It Works

1. User clicks advertising link: `https://www.rustore.ru/catalog/app/com.example?referrerId=campaign123`
2. RuStore stores the `referrerId` during installation
3. Your app retrieves the referrer using this plugin
4. Referrer can only be retrieved once
5. Referrer expires after 10 days if not retrieved

### Important Notes

- Referrer can only be obtained once
- Expires after 10 days
- Requires RuStore installed on device
- Full Stream Attribution requires auth token from VK Ads

### Platform Support

- Android: Yes
- iOS: No (RuStore is Android-only)

---

## Russian

Flutter плагин для RuStore Install Referrer SDK (версия 10.0.0). Отслеживайте установки из рекламных ссылок и измеряйте эффективность маркетинговых кампаний.

### Возможности

- Получение информации о Install Referrer из RuStore
- Отслеживание источников рекламных кампаний
- Поддержка VK Реклама Full Stream Attribution (v10.0.0+)
- Полная обработка ошибок
- Поддержка RuStore SDK 10.0.0

### Установка

```yaml
dependencies:
  rustore_install_referrer: ^2.0.0
```

### Настройка Android

**Добавьте репозиторий RuStore** в `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://artifactory-external.vkpartner.ru/artifactory/maven"
        }
    }
}
```

**Требования:**
- Android SDK минимум 21
- Kotlin 1.8+

### Использование

#### Получение Install Referrer

```dart
import 'package:rustore_install_referrer/rustore_install_referrer.dart';

try {
  final details = await RuStoreInstallReferrer.getInstallReferrer();
  
  print('Referrer ID: ${details.referrerId}');
  print('Пакет: ${details.packageName}');
  print('Получено: ${details.receivedTime}');
  print('Установлено: ${details.installAppTime}');
  
} on RuStoreInstallReferrerException catch (e) {
  print('Ошибка: ${e.code} - ${e.message}');
}
```

#### Отправка Auth Event (VK Реклама)

Новое в v10.0.0 - отправка номера телефона в VK Рекламу для атрибуции:

```dart
try {
  await RuStoreInstallReferrer.sendAuthEvent(
    phoneNumber: '1234567890',
    authToken: 'ваш_токен_vk_ads',
  );
} on RuStoreInstallReferrerException catch (e) {
  print('Ошибка: ${e.code}');
}
```

**Важно:** Токен авторизации необходимо получить у менеджера VK Рекламы.

### Справочник API

#### RuStoreReferrerDetails

| Свойство | Тип | Описание |
|----------|-----|----------|
| `packageName` | `String` | Имя пакета приложения |
| `referrerId` | `String` | ID реферера из рекламной ссылки |
| `receivedTimestamp` | `int` | Время получения referrer (мс) |
| `installAppTimestamp` | `int` | Время начала установки (мс) |
| `versionCode` | `int?` | Версия приложения |

#### Методы

| Метод | Описание |
|-------|----------|
| `getInstallReferrer()` | Получить данные referrer |
| `sendAuthEvent()` | Отправить auth событие в VK Рекламу |
| `getErrorDescription(code)` | Получить описание ошибки |

### Коды ошибок

| Код | Описание |
|-----|----------|
| `REFERRER_NOT_FOUND` | Referrer не найден или истек |
| `RU_STORE_NOT_INSTALLED` | RuStore не установлен |
| `RU_STORE_OUTDATED` | Версия RuStore устарела |
| `RU_STORE_ERROR` | Общая ошибка RuStore SDK |
| `MISSING_PHONE_NUMBER` | Не указан номер телефона |
| `MISSING_AUTH_TOKEN` | Не указан токен авторизации |
| `INVALID_PHONE_NUMBER` | Неверный формат номера |

### Как это работает

1. Пользователь нажимает рекламную ссылку: `https://www.rustore.ru/catalog/app/com.example?referrerId=campaign123`
2. RuStore сохраняет `referrerId` при установке
3. Ваше приложение получает referrer через этот плагин
4. Referrer можно получить только один раз
5. Referrer истекает через 10 дней, если не получен

### Важные замечания

- Referrer можно получить только один раз
- Истекает через 10 дней
- Требуется установленный RuStore на устройстве
- Full Stream Attribution требует токен от VK Рекламы

### Поддержка платформ

- Android: Да
- iOS: Нет (RuStore только для Android)

---

## License

MIT License

## Links

- [RuStore Documentation](https://www.rustore.ru/help/sdk/install-referrer)
- [VK Ads](https://vk.com/ads)
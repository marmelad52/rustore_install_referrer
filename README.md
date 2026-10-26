# RuStore Install Referrer

**Language:** [English](#english) | [Русский](#russian)

---

## English

Flutter plugin for RuStore Install Referrer SDK (version 10.6.1). Track app installations from advertising links and measure marketing campaign effectiveness.

### Features

- Get install referrer information from RuStore (`getInstallReferrer()` and `getInstallReferrerV2()`)
- UTM parameters of the advertising link
- Track advertising campaign sources
- VK Ads Full Stream Attribution events (`sendFsaEvent()`)
- Referrer service availability check and debug info
- Comprehensive error handling
- Supports RuStore SDK 10.6.1

### Installation

```yaml
dependencies:
  rustore_install_referrer: ^2.1.0
```

### Android Setup

**Add RuStore repository** in `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://nexus-external.rustore.ru/repository/maven-rustore-exposed"
        }
    }
}
```

or, if you use Kotlin DSL (`android/build.gradle.kts`):

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://nexus-external.rustore.ru/repository/maven-rustore-exposed")
        }
    }
}
```

> The old `artifactory-external.vkpartner.ru` repository no longer serves the SDK.
> If you used it, replace it with the URL above.

**Requirements:**
- Android SDK minimum 23
- Kotlin 1.8+
- RuStore installed on the user's device

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
  print('UTM source: ${details.utmSource}');
  
} on RuStoreInstallReferrerException catch (e) {
  print('Error: ${e.code} - ${e.message}');
}
```

#### Get Install Referrer (V2)

`getInstallReferrerV2()` is the method used in the RuStore documentation. It returns timestamps in seconds (device and server clocks) and the `isFromRuStore` flag:

```dart
try {
  final details = await RuStoreInstallReferrer.getInstallReferrerV2();

  print('Referrer: ${details.installReferrer}');
  print('Click: ${details.referrerClickTime}');
  print('Install begin: ${details.installBeginTime}');
  print('From RuStore: ${details.isFromRuStore}');
} on RuStoreInstallReferrerException catch (e) {
  print('Error: ${e.code} - ${e.message}');
}
```

#### Check Availability and Debug Info

```dart
final isAvailable = await RuStoreInstallReferrer.isReferrerServiceAvailable();
final debugInfo = await RuStoreInstallReferrer.getDebugInfo();
```

#### Send FSA Event (VK Ads)

Send user phone number to VK Ads Full Stream Attribution. The `install` event is sent by default; `viewOffer`, `addToCart`, `purchase` and `addToWishlist` require a `productId`:

```dart
try {
  await RuStoreInstallReferrer.sendFsaEvent(
    phoneNumber: '1234567890',
    authToken: 'your_vk_ads_token',
  );

  await RuStoreInstallReferrer.sendFsaEvent(
    phoneNumber: '1234567890',
    authToken: 'your_vk_ads_token',
    eventType: RuStoreFsaEventType.purchase,
    productId: 'product_id',
  );
} on RuStoreInstallReferrerException catch (e) {
  print('Error: ${e.code}');
}
```

**Note:** Auth token must be obtained from your VK Ads manager.

### Migration from 2.0.x

- Replace the RuStore Maven repository URL in your Android project (see [Android Setup](#android-setup)).
- Raise `minSdk` to 23 if it is lower.
- `sendAuthEvent()` is deprecated: SDK 10.6.1 removed the auth event in favour of typed FSA events. It still works and now sends an `install` FSA event. Use `sendFsaEvent()` instead.

### API Reference

#### RuStoreReferrerDetails

| Property | Type | Description |
|----------|------|-------------|
| `packageName` | `String` | App package name |
| `referrerId` | `String` | Referrer ID from advertising link |
| `receivedTimestamp` | `int` | When referrer was received (ms) |
| `installAppTimestamp` | `int` | When installation began (ms) |
| `versionCode` | `int?` | App version code |
| `utmSource`, `utmMedium`, `utmCampaign`, `utmGroup`, `utmBanner`, `utmContent`, `utmTerm` | `String?` | UTM parameters of the link |

#### RuStoreReferrerDetailsV2

| Property | Type | Description |
|----------|------|-------------|
| `installReferrer` | `String` | Referrer string from the link |
| `referrerClickTimestampSeconds` | `int` | Click time (s) |
| `installBeginTimestampSeconds` | `int` | Installation start time (s) |
| `referrerClickTimestampServerSeconds` | `int` | Server click time (s) |
| `installBeginTimestampServerSeconds` | `int` | Server installation start time (s) |
| `googlePlayInstant` | `bool` | Always `false` for RuStore |
| `isFromRuStore` | `bool` | `true` if data comes from RuStore |

#### Methods

| Method | Description |
|--------|-------------|
| `getInstallReferrer()` | Get referrer details |
| `getInstallReferrerV2()` | Get referrer details (V2 model) |
| `isReferrerServiceAvailable()` | Check that the referrer service is available |
| `getDebugInfo()` | Get diagnostic string for support requests |
| `sendFsaEvent()` | Send FSA event to VK Ads |
| `sendAuthEvent()` | Deprecated, use `sendFsaEvent()` |
| `getErrorDescription(code)` | Get error description |

### Error Codes

| Code | Description |
|------|-------------|
| `REFERRER_NOT_FOUND` | Referrer not found, expired or already consumed |
| `RU_STORE_NOT_INSTALLED` | RuStore not installed |
| `RU_STORE_OUTDATED` | RuStore version outdated |
| `RU_STORE_ERROR` | General RuStore SDK error |
| `CLIENT_NOT_CREATED` | Install Referrer client could not be created |
| `MISSING_PHONE_NUMBER` | Phone number missing |
| `MISSING_AUTH_TOKEN` | Auth token missing |
| `MISSING_PRODUCT_ID` | Product ID missing for the FSA event type |
| `INVALID_PHONE_NUMBER` | Invalid phone format |
| `INVALID_EVENT_TYPE` | Unknown FSA event type |

### How It Works

1. User clicks advertising link: `https://www.rustore.ru/catalog/app/com.example?referrerId=campaign123` or `...?referrer=campaign123` (if both are present, `referrer` is used)
2. RuStore stores the referrer during installation
3. Your app retrieves the referrer using this plugin

### Important Notes

- According to the RuStore documentation, newer RuStore versions keep the referrer for 90 days after the click and do not delete it after the first read, so the app and an MMP SDK can request it independently. Older versions deliver it once and keep it for 10 days.
- `null` result (`REFERRER_NOT_FOUND`) means the app was installed without a referrer or the retention period has passed
- Requires RuStore installed on device
- Full Stream Attribution requires auth token from VK Ads

### Platform Support

- Android: Yes
- iOS: No (RuStore is Android-only)

---

## Russian

Flutter плагин для RuStore Install Referrer SDK (версия 10.6.1). Отслеживайте установки из рекламных ссылок и измеряйте эффективность маркетинговых кампаний.

### Возможности

- Получение информации о Install Referrer из RuStore (`getInstallReferrer()` и `getInstallReferrerV2()`)
- UTM-параметры рекламной ссылки
- Отслеживание источников рекламных кампаний
- События VK Реклама Full Stream Attribution (`sendFsaEvent()`)
- Проверка доступности сервиса referrer и диагностическая информация
- Полная обработка ошибок
- Поддержка RuStore SDK 10.6.1

### Установка

```yaml
dependencies:
  rustore_install_referrer: ^2.1.0
```

### Настройка Android

**Добавьте репозиторий RuStore** в `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://nexus-external.rustore.ru/repository/maven-rustore-exposed"
        }
    }
}
```

или, если используете Kotlin DSL (`android/build.gradle.kts`):

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://nexus-external.rustore.ru/repository/maven-rustore-exposed")
        }
    }
}
```

> Старый репозиторий `artifactory-external.vkpartner.ru` больше не отдаёт SDK.
> Если вы его использовали, замените его на URL выше.

**Требования:**
- Android SDK минимум 23
- Kotlin 1.8+
- На устройстве пользователя установлен RuStore

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
  print('UTM source: ${details.utmSource}');
  
} on RuStoreInstallReferrerException catch (e) {
  print('Ошибка: ${e.code} - ${e.message}');
}
```

#### Получение Install Referrer (V2)

`getInstallReferrerV2()` — метод, который используется в документации RuStore. Возвращает время в секундах (по часам устройства и сервера) и флаг `isFromRuStore`:

```dart
try {
  final details = await RuStoreInstallReferrer.getInstallReferrerV2();

  print('Referrer: ${details.installReferrer}');
  print('Клик: ${details.referrerClickTime}');
  print('Начало установки: ${details.installBeginTime}');
  print('Из RuStore: ${details.isFromRuStore}');
} on RuStoreInstallReferrerException catch (e) {
  print('Ошибка: ${e.code} - ${e.message}');
}
```

#### Проверка доступности и отладочная информация

```dart
final isAvailable = await RuStoreInstallReferrer.isReferrerServiceAvailable();
final debugInfo = await RuStoreInstallReferrer.getDebugInfo();
```

#### Отправка FSA-события (VK Реклама)

Отправка номера телефона в VK Реклама Full Stream Attribution. По умолчанию отправляется событие `install`; для `viewOffer`, `addToCart`, `purchase` и `addToWishlist` нужен `productId`:

```dart
try {
  await RuStoreInstallReferrer.sendFsaEvent(
    phoneNumber: '1234567890',
    authToken: 'ваш_токен_vk_ads',
  );

  await RuStoreInstallReferrer.sendFsaEvent(
    phoneNumber: '1234567890',
    authToken: 'ваш_токен_vk_ads',
    eventType: RuStoreFsaEventType.purchase,
    productId: 'product_id',
  );
} on RuStoreInstallReferrerException catch (e) {
  print('Ошибка: ${e.code}');
}
```

**Важно:** Токен авторизации необходимо получить у менеджера VK Рекламы.

### Миграция с 2.0.x

- Замените URL Maven-репозитория RuStore в Android-проекте (см. [Настройка Android](#настройка-android)).
- Поднимите `minSdk` до 23, если он ниже.
- `sendAuthEvent()` помечен как устаревший: SDK 10.6.1 убрал auth-событие в пользу типизированных FSA-событий. Метод продолжает работать и теперь отправляет FSA-событие `install`. Используйте `sendFsaEvent()`.

### Справочник API

#### RuStoreReferrerDetails

| Свойство | Тип | Описание |
|----------|-----|----------|
| `packageName` | `String` | Имя пакета приложения |
| `referrerId` | `String` | ID реферера из рекламной ссылки |
| `receivedTimestamp` | `int` | Время получения referrer (мс) |
| `installAppTimestamp` | `int` | Время начала установки (мс) |
| `versionCode` | `int?` | Версия приложения |
| `utmSource`, `utmMedium`, `utmCampaign`, `utmGroup`, `utmBanner`, `utmContent`, `utmTerm` | `String?` | UTM-параметры ссылки |

#### RuStoreReferrerDetailsV2

| Свойство | Тип | Описание |
|----------|-----|----------|
| `installReferrer` | `String` | Строка referrer из ссылки |
| `referrerClickTimestampSeconds` | `int` | Время клика (с) |
| `installBeginTimestampSeconds` | `int` | Время начала установки (с) |
| `referrerClickTimestampServerSeconds` | `int` | Серверное время клика (с) |
| `installBeginTimestampServerSeconds` | `int` | Серверное время начала установки (с) |
| `googlePlayInstant` | `bool` | Для RuStore всегда `false` |
| `isFromRuStore` | `bool` | `true`, если данные получены от RuStore |

#### Методы

| Метод | Описание |
|-------|----------|
| `getInstallReferrer()` | Получить данные referrer |
| `getInstallReferrerV2()` | Получить данные referrer (модель V2) |
| `isReferrerServiceAvailable()` | Проверить доступность сервиса referrer |
| `getDebugInfo()` | Получить диагностическую строку для обращения в поддержку |
| `sendFsaEvent()` | Отправить FSA-событие в VK Рекламу |
| `sendAuthEvent()` | Устарел, используйте `sendFsaEvent()` |
| `getErrorDescription(code)` | Получить описание ошибки |

### Коды ошибок

| Код | Описание |
|-----|----------|
| `REFERRER_NOT_FOUND` | Referrer не найден, истек или уже получен |
| `RU_STORE_NOT_INSTALLED` | RuStore не установлен |
| `RU_STORE_OUTDATED` | Версия RuStore устарела |
| `RU_STORE_ERROR` | Общая ошибка RuStore SDK |
| `CLIENT_NOT_CREATED` | Не удалось создать клиент Install Referrer |
| `MISSING_PHONE_NUMBER` | Не указан номер телефона |
| `MISSING_AUTH_TOKEN` | Не указан токен авторизации |
| `MISSING_PRODUCT_ID` | Не указан ID продукта для типа FSA-события |
| `INVALID_PHONE_NUMBER` | Неверный формат номера |
| `INVALID_EVENT_TYPE` | Неизвестный тип FSA-события |

### Как это работает

1. Пользователь нажимает рекламную ссылку: `https://www.rustore.ru/catalog/app/com.example?referrerId=campaign123` или `...?referrer=campaign123` (если переданы оба параметра, используется `referrer`)
2. RuStore сохраняет referrer при установке
3. Ваше приложение получает referrer через этот плагин

### Важные замечания

- Согласно документации RuStore, новые версии RuStore хранят referrer 90 дней с момента клика и не удаляют его после первого чтения, поэтому приложение и MMP SDK могут запрашивать его независимо. Старые версии отдают его один раз и хранят 10 дней.
- Результат `null` (`REFERRER_NOT_FOUND`) означает, что приложение установлено без referrer или срок хранения истёк
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

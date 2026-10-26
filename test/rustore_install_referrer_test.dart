import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rustore_install_referrer/rustore_install_referrer.dart';
import 'package:rustore_install_referrer/rustore_install_referrer_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('rustore_install_referrer');
  final calls = <MethodCall>[];

  void mockChannel(Future<Object?> Function(MethodCall call) handler) {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          calls.add(call);
          return handler(call);
        });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<RuStoreInstallReferrerException> catchError(
    Future<Object?> Function() action,
  ) async {
    try {
      await action();
    } on RuStoreInstallReferrerException catch (e) {
      return e;
    }
    fail('Expected RuStoreInstallReferrerException');
  }

  group('getInstallReferrer', () {
    test('parses referrer details including UTM fields', () async {
      mockChannel(
        (_) async => {
          'packageName': 'com.example.app',
          'referrerId': 'campaign123',
          'receivedTimestamp': 1000,
          'installAppTimestamp': 2000,
          'versionCode': 7,
          'utmSource': 'vk',
          'utmCampaign': 'spring',
        },
      );

      final details = await RuStoreInstallReferrer.getInstallReferrer();

      expect(details.packageName, 'com.example.app');
      expect(details.referrerId, 'campaign123');
      expect(details.receivedTimestamp, 1000);
      expect(details.installAppTimestamp, 2000);
      expect(details.versionCode, 7);
      expect(details.utmSource, 'vk');
      expect(details.utmCampaign, 'spring');
      expect(details.utmMedium, isNull);
    });

    test('throws REFERRER_NOT_FOUND when native returns null', () async {
      mockChannel((_) async => null);

      final error = await catchError(RuStoreInstallReferrer.getInstallReferrer);

      expect(error.code, 'REFERRER_NOT_FOUND');
    });

    test('maps SDK exception class names to error codes', () async {
      const expected = {
        'RuStoreNotInstalledException': 'RU_STORE_NOT_INSTALLED',
        'RuStoreOutdatedException': 'RU_STORE_OUTDATED',
        'RuStoreException': 'RU_STORE_ERROR',
        'ClientNotCreated': 'CLIENT_NOT_CREATED',
        'InvalidPhoneNumberException': 'INVALID_PHONE_NUMBER',
      };

      for (final entry in expected.entries) {
        mockChannel((_) async => throw PlatformException(code: entry.key));

        final error = await catchError(
          RuStoreInstallReferrer.getInstallReferrer,
        );

        expect(error.code, entry.value, reason: entry.key);
      }
    });
  });

  group('getInstallReferrerV2', () {
    test('parses V2 details', () async {
      mockChannel(
        (_) async => {
          'installReferrer': 'campaign123',
          'referrerClickTimestampSeconds': 100,
          'installBeginTimestampSeconds': 200,
          'referrerClickTimestampServerSeconds': 101,
          'installBeginTimestampServerSeconds': 201,
          'googlePlayInstant': false,
          'isFromRuStore': true,
        },
      );

      final details = await RuStoreInstallReferrer.getInstallReferrerV2();

      expect(calls.single.method, 'getInstallReferrerV2');
      expect(details.installReferrer, 'campaign123');
      expect(details.hasReferrer, isTrue);
      expect(details.referrerClickTime.millisecondsSinceEpoch, 100 * 1000);
      expect(details.installBeginServerTime.millisecondsSinceEpoch, 201 * 1000);
      expect(details.googlePlayInstant, isFalse);
      expect(details.isFromRuStore, isTrue);
    });

    test('throws REFERRER_NOT_FOUND when native returns null', () async {
      mockChannel((_) async => null);

      final error = await catchError(
        RuStoreInstallReferrer.getInstallReferrerV2,
      );

      expect(error.code, 'REFERRER_NOT_FOUND');
    });
  });

  group('service info', () {
    test('isReferrerServiceAvailable returns native value', () async {
      mockChannel((_) async => true);

      expect(await RuStoreInstallReferrer.isReferrerServiceAvailable(), isTrue);
      expect(calls.single.method, 'isReferrerServiceAvailable');
    });

    test('getDebugInfo returns native value', () async {
      mockChannel((_) async => 'debug');

      expect(await RuStoreInstallReferrer.getDebugInfo(), 'debug');
      expect(calls.single.method, 'getDebugInfo');
    });
  });

  group('FSA events', () {
    test('sendFsaEvent defaults to install event', () async {
      mockChannel((_) async => true);

      final sent = await RuStoreInstallReferrer.sendFsaEvent(
        phoneNumber: '1234567890',
        authToken: 'token',
      );

      expect(sent, isTrue);
      expect(calls.single.method, 'sendFsaEvent');
      expect(calls.single.arguments, {
        'phoneNumber': '1234567890',
        'authToken': 'token',
        'eventType': 'install',
        'productId': null,
      });
    });

    test('sendFsaEvent passes event type and product id', () async {
      mockChannel((_) async => true);

      await RuStoreInstallReferrer.sendFsaEvent(
        phoneNumber: '1234567890',
        authToken: 'token',
        eventType: RuStoreFsaEventType.purchase,
        productId: 'product',
      );

      final arguments = calls.single.arguments as Map;
      expect(arguments['eventType'], 'purchase');
      expect(arguments['productId'], 'product');
    });

    test('sendFsaEvent maps native errors', () async {
      mockChannel(
        (_) async => throw PlatformException(code: 'MISSING_PRODUCT_ID'),
      );

      final error = await catchError(
        () => RuStoreInstallReferrer.sendFsaEvent(
          phoneNumber: '1234567890',
          authToken: 'token',
          eventType: RuStoreFsaEventType.purchase,
        ),
      );

      expect(error.code, 'MISSING_PRODUCT_ID');
    });

    test('deprecated sendAuthEvent still works', () async {
      mockChannel((_) async => true);

      // ignore: deprecated_member_use_from_same_package
      final sent = await RuStoreInstallReferrer.sendAuthEvent(
        phoneNumber: '1234567890',
        authToken: 'token',
      );

      expect(sent, isTrue);
      expect(calls.single.method, 'sendAuthEvent');
    });

    test('only install event does not require a product id', () {
      final withoutProduct = RuStoreFsaEventType.values.where(
        (type) => !type.requiresProductId,
      );

      expect(withoutProduct, [RuStoreFsaEventType.install]);
    });
  });
}

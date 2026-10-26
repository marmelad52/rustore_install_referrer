import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rustore_install_referrer/rustore_install_referrer.dart';
import 'package:rustore_install_referrer/rustore_install_referrer_exception.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _referrerResult = 'Press button to get install referrer';
  String _referrerV2Result = 'Press button to get install referrer (V2)';
  String _authResult = 'Press button to send FSA event';
  bool _isLoadingReferrer = false;
  bool _isLoadingReferrerV2 = false;
  bool _isLoadingAuth = false;
  RuStoreFsaEventType _eventType = RuStoreFsaEventType.install;

  final _phoneController = TextEditingController(text: '1234567890');
  final _tokenController = TextEditingController(text: 'your_auth_token');
  final _productIdController = TextEditingController(text: 'product_id');

  @override
  void dispose() {
    _phoneController.dispose();
    _tokenController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  Future<void> _getInstallReferrer() async {
    setState(() {
      _isLoadingReferrer = true;
      _referrerResult = 'Loading...';
    });

    try {
      final details = await RuStoreInstallReferrer.getInstallReferrer();
      setState(() {
        _referrerResult =
            'Success!\n\n'
            'Package Name: ${details.packageName}\n'
            'Referrer ID: ${details.referrerId}\n'
            'Received Time: ${details.receivedTime}\n'
            'Install Time: ${details.installAppTime}\n'
            'Version Code: ${details.versionCode ?? 'N/A'}\n'
            'UTM Source: ${details.utmSource ?? 'N/A'}\n'
            'UTM Medium: ${details.utmMedium ?? 'N/A'}\n'
            'UTM Campaign: ${details.utmCampaign ?? 'N/A'}\n'
            'Has Referrer: ${details.hasReferrer}';
      });
    } on RuStoreInstallReferrerException catch (e) {
      setState(() {
        _referrerResult =
            'Error: ${e.code}\n\n'
            '${e.message}\n\n'
            '${RuStoreInstallReferrer.getErrorDescription(e.code)}';
      });
    } catch (e) {
      setState(() {
        _referrerResult = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isLoadingReferrer = false;
      });
    }
  }

  Future<void> _getInstallReferrerV2() async {
    setState(() {
      _isLoadingReferrerV2 = true;
      _referrerV2Result = 'Loading...';
    });

    try {
      final details = await RuStoreInstallReferrer.getInstallReferrerV2();
      setState(() {
        _referrerV2Result =
            'Success!\n\n'
            'Install Referrer: ${details.installReferrer}\n'
            'Click Time: ${details.referrerClickTime}\n'
            'Install Begin Time: ${details.installBeginTime}\n'
            'Is From RuStore: ${details.isFromRuStore}\n'
            'Has Referrer: ${details.hasReferrer}';
      });
    } on RuStoreInstallReferrerException catch (e) {
      setState(() {
        _referrerV2Result =
            'Error: ${e.code}\n\n'
            '${e.message}\n\n'
            '${RuStoreInstallReferrer.getErrorDescription(e.code)}';
      });
    } catch (e) {
      setState(() {
        _referrerV2Result = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isLoadingReferrerV2 = false;
      });
    }
  }

  Future<void> _sendFsaEvent() async {
    setState(() {
      _isLoadingAuth = true;
      _authResult = 'Sending...';
    });

    try {
      await RuStoreInstallReferrer.sendFsaEvent(
        phoneNumber: _phoneController.text.trim(),
        authToken: _tokenController.text.trim(),
        eventType: _eventType,
        productId: _eventType.requiresProductId
            ? _productIdController.text.trim()
            : null,
      );
      setState(() {
        _authResult = 'Success! ${_eventType.value} event sent to VK Ads';
      });
    } on RuStoreInstallReferrerException catch (e) {
      setState(() {
        _authResult =
            'Error: ${e.code}\n\n'
            '${e.message}\n\n'
            '${RuStoreInstallReferrer.getErrorDescription(e.code)}';
      });
    } catch (e) {
      setState(() {
        _authResult = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isLoadingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuStore Install Referrer Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('RuStore Install Referrer v10.6.1'),
          backgroundColor: Colors.blue.shade100,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Install Referrer Section
              const Text(
                '1. Get Install Referrer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoadingReferrer ? null : _getInstallReferrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoadingReferrer
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Get Install Referrer'),
              ),
              const SizedBox(height: 12),
              _buildResultBox(_referrerResult),
              const SizedBox(height: 32),

              // Install Referrer V2 Section
              const Text(
                '2. Get Install Referrer (V2)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoadingReferrerV2 ? null : _getInstallReferrerV2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoadingReferrerV2
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Get Install Referrer V2'),
              ),
              const SizedBox(height: 12),
              _buildResultBox(_referrerV2Result),
              const SizedBox(height: 32),

              // Full Stream Attribution Section
              const Text(
                '3. Full Stream Attribution (VK Ads)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  hintText: '1234567890',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'Auth Token (from VK Ads manager)',
                  border: OutlineInputBorder(),
                  hintText: 'your_auth_token',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RuStoreFsaEventType>(
                initialValue: _eventType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final type in RuStoreFsaEventType.values)
                    DropdownMenuItem(value: type, child: Text(type.value)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _eventType = value);
                },
              ),
              if (_eventType.requiresProductId) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _productIdController,
                  decoration: const InputDecoration(
                    labelText: 'Product ID',
                    border: OutlineInputBorder(),
                    hintText: 'product_id',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoadingAuth ? null : _sendFsaEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoadingAuth
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Send FSA Event'),
              ),
              const SizedBox(height: 12),
              _buildResultBox(_authResult),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
      ),
    );
  }
}

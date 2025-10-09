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
  String _authResult = 'Press button to send auth event';
  bool _isLoadingReferrer = false;
  bool _isLoadingAuth = false;

  final _phoneController = TextEditingController(text: '1234567890');
  final _tokenController = TextEditingController(text: 'your_auth_token');

  @override
  void dispose() {
    _phoneController.dispose();
    _tokenController.dispose();
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

  Future<void> _sendAuthEvent() async {
    setState(() {
      _isLoadingAuth = true;
      _authResult = 'Sending...';
    });

    try {
      await RuStoreInstallReferrer.sendAuthEvent(
        phoneNumber: _phoneController.text.trim(),
        authToken: _tokenController.text.trim(),
      );
      setState(() {
        _authResult = 'Success! Auth event sent to VK Ads';
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
          title: const Text('RuStore Install Referrer v10.0.0'),
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

              // Full Stream Attribution Section
              const Text(
                '2. Full Stream Attribution (VK Ads)',
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
              ElevatedButton(
                onPressed: _isLoadingAuth ? null : _sendAuthEvent,
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
                    : const Text('Send Auth Event'),
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

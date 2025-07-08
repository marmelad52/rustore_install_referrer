// example/lib/main.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rustore_install_referrer/rustore_install_referrer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'Press button to get install referrer';
  bool _isLoading = false;

  Future<void> _getInstallReferrer() async {
    setState(() {
      _isLoading = true;
      _result = 'Loading...';
    });

    try {
      final details = await RustoreInstallReferrer.getInstallReferrer();
      setState(() {
        _result = 'Success!\n\n'
            'Package Name: ${details.packageName}\n'
            'Referrer ID: ${details.referrerId}\n'
            'Received Time: ${details.receivedTime}\n'
            'Install Time: ${details.installAppTime}\n'
            'Version Code: ${details.versionCode ?? 'N/A'}\n'
            'Has Referrer: ${details.hasReferrer}';
      });
    } on RuStoreInstallReferrerException catch (e) {
      setState(() {
        _result = 'Error: ${e.code}\n\n'
            '${e.message}\n\n'
            '${RustoreInstallReferrer.getErrorDescription(e.code)}';
      });
    } catch (e) {
      setState(() {
        _result = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuStore Install Referrer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('RuStore Install Referrer'),
          backgroundColor: Colors.blue.shade100,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _getInstallReferrer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Get Install Referrer',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ℹ️ About Install Referrer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Referrer can only be obtained once\n'
                        '• Referrer expires after 10 days\n'
                        '• Requires RuStore to be installed\n'
                        '• Use try-catch to handle errors',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
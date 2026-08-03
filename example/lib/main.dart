import 'package:flutter/material.dart';
import 'package:flutter_marketing_kit/flutter_marketing_kit.dart';

void main() {
  runApp(const MarketingKitExampleApp());
}

/// Example Flutter application showcasing route automation for marketing screenshots.
class MarketingKitExampleApp extends StatelessWidget {
  /// Creates a [MarketingKitExampleApp].
  const MarketingKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense AI Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5E5CE6)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/premium': (context) => const PremiumScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

/// Home screen widget.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense AI Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 80, color: Color(0xFF5E5CE6)),
            const SizedBox(height: 16),
            const Text(
              'Smart Expense Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/premium'),
              child: const Text('View Premium Features'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium features screen widget.
class PremiumScreen extends StatelessWidget {
  /// Creates a [PremiumScreen].
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Plan')),
      body: const Center(
        child: Text(
          'Unlock Unlimited Analytics & Multi-Currency',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// Settings screen widget.
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Customization & Privacy Controls'),
      ),
    );
  }
}

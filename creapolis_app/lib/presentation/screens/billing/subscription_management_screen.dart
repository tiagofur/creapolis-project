import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/billing_service.dart';
import '../../../domain/entities/plan.dart';
import '../../../injection.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  final int workspaceId;
  const SubscriptionManagementScreen({super.key, required this.workspaceId});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  final BillingService _billingService = getIt<BillingService>();

  // Dummy data for the current plan
  final Plan _currentPlan = const Plan(
    name: 'Pro',
    description: 'For growing teams',
    price: '€10',
    features: [
      'Unlimited projects',
      'Up to 50 members',
      '100GB storage',
      'Advanced analytics'
    ],
    isPopular: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentPlan.name,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _currentPlan.description,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _currentPlan.price,
                          style: theme.textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (_currentPlan.price != 'Contact us' &&
                            _currentPlan.name != 'Free')
                          Text('/ month', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final portalUrl = await _billingService
                      .createCustomerPortalSession(widget.workspaceId);
                  if (portalUrl != null) {
                    final uri = Uri.parse(portalUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Manage Subscription',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../data/services/billing_service.dart';
import '../../../domain/entities/plan.dart';
import '../../../injection.dart';
import 'checkout_screen.dart';

class PlansScreen extends StatefulWidget {
  final int workspaceId;
  const PlansScreen({super.key, required this.workspaceId});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final BillingService _billingService = getIt<BillingService>();

  static const List<Plan> _plans = [
    Plan(
      name: 'Free',
      description: 'For individuals and small teams',
      price: '€0',
      features: ['Up to 10 projects', 'Up to 5 members', '2GB storage'],
    ),
    Plan(
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
    ),
    Plan(
      name: 'Enterprise',
      description: 'For large organizations',
      price: 'Contact us',
      features: [
        'Unlimited everything',
        'Dedicated support',
        'SSO integration',
        'On-premise option'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          return PlanCard(
            plan: _plans[index],
            onChoosePlan: (plan) async {
              if (plan.name == 'Enterprise') {
                // Handle contact us
                return;
              }
              final checkoutUrl = await _billingService.createCheckoutSession(plan.name.toLowerCase(), widget.workspaceId);
              if (checkoutUrl != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      checkoutUrl: checkoutUrl,
                      successUrl: 'http://localhost:5173/billing/success',
                      cancelUrl: 'http://localhost:5173/billing/cancel',
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final Plan plan;
  final ValueChanged<Plan> onChoosePlan;

  const PlanCard({super.key, required this.plan, required this.onChoosePlan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPopular = plan.isPopular;

    return Card(
      elevation: isPopular ? 8.0 : 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: isPopular
            ? BorderSide(color: theme.colorScheme.secondary, width: 2.0)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'POPULAR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Text(
              plan.name,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              plan.description,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.price,
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (plan.price != 'Contact us' && plan.name != 'Free')
                  Text('/ month', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 24.0),
            ...plan.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 20.0, color: theme.colorScheme.secondary),
                    const SizedBox(width: 12.0),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onChoosePlan(plan),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  plan.name == 'Enterprise' ? 'Contact Us' : 'Choose Plan',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
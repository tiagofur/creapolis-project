import 'package:flutter/material.dart';
import '../../../domain/entities/subscription.dart';

class SubscriptionProvider extends ChangeNotifier {
  Subscription? _subscription;

  Subscription? get subscription => _subscription;

  void setSubscription(Subscription? subscription) {
    _subscription = subscription;
    notifyListeners();
  }

  bool canCreateProject() {
    if (_subscription == null) {
      return false;
    }
    // In a real app, you would check the project count against the plan limits
    return true;
  }
}

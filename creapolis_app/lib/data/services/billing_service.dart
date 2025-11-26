import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/api_service.dart';
import '../../../domain/entities/plan.dart';

@injectable
class BillingService {
  final ApiService _apiService;

  BillingService(this._apiService);

  Future<List<Plan>> getPlans() async {
    // In a real app, you would fetch the plans from the backend
    // For now, we are using dummy data in the plans_screen.dart
    return [];
  }

  Future<String?> createCheckoutSession(String planSlug, int workspaceId) async {
    try {
      final response = await _apiService.post(
        '/billing/create-checkout-session',
        data: {
          'planSlug': planSlug,
          'workspaceId': workspaceId,
          'successUrl': '${kDebugMode ? "http://localhost:5173" : "https://app.creapolis.com"}/billing/success',
          'cancelUrl': '${kDebugMode ? "http://localhost:5173" : "https://app.creapolis.com"}/billing/cancel',
        },
      );
      return response.data['url'];
    } on DioError catch (e) {
      // Handle error
      return null;
    }
  }
  Future<String?> createCustomerPortalSession(int workspaceId) async {
    try {
      final response = await _apiService.post(
        '/billing/create-customer-portal-session',
        data: {
          'workspaceId': workspaceId,
          'returnUrl': '${kDebugMode ? "http://localhost:5173" : "https://app.creapolis.com"}/billing',
        },
      );
      return response.data['url'];
    } on DioError catch (e) {
      // Handle error
      return null;
    }
  }
}

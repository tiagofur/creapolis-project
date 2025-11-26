import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final String planName;
  final String status;
  final DateTime currentPeriodEnd;

  const Subscription({
    required this.planName,
    required this.status,
    required this.currentPeriodEnd,
  });

  @override
  List<Object?> get props => [planName, status, currentPeriodEnd];
}

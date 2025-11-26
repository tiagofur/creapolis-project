import 'package:equatable/equatable.dart';

class Plan extends Equatable {
  final String name;
  final String description;
  final String price;
  final List<String> features;
  final bool isPopular;

  const Plan({
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    this.isPopular = false,
  });

  @override
  List<Object?> get props => [name, description, price, features, isPopular];
}

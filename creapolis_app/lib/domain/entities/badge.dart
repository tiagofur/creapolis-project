import 'package:equatable/equatable.dart';

class Badge extends Equatable {
  final int id;
  final String name;
  final String description;
  final String? icon;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, icon];
}

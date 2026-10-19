import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  const Branch({required this.id, required this.name});
  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

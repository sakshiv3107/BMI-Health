import 'package:hive/hive.dart';

part 'weight_entry.g.dart';

@HiveType(typeId: 1)
class WeightEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String profileId;

  @HiveField(2)
  final double weightKg;

  @HiveField(3)
  final DateTime date;

  WeightEntry({
    required this.id,
    required this.profileId,
    required this.weightKg,
    required this.date,
  });
}

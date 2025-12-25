import 'package:hive/hive.dart';
part 'scanmodel.g.dart'; // Ye file build_runner generate karega
@HiveType(typeId: 0)
class ScanItem extends HiveObject {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final DateTime time;

  ScanItem({required this.code, required this.time});
}

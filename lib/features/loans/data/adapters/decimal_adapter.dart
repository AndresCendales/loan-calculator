import 'package:hive/hive.dart';
import 'package:decimal/decimal.dart';

class DecimalAdapter extends TypeAdapter<Decimal> {
  @override
  final int typeId = 10;

  @override
  Decimal read(BinaryReader reader) {
    return Decimal.parse(reader.readString());
  }

  @override
  void write(BinaryWriter writer, Decimal obj) {
    writer.writeString(obj.toString());
  }
}

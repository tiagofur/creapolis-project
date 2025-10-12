// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_operation_queue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveOperationQueueAdapter extends TypeAdapter<HiveOperationQueue> {
  @override
  final int typeId = 10;

  @override
  HiveOperationQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveOperationQueue(
      id: fields[0] as String,
      type: fields[1] as String,
      data: fields[2] as String,
      timestamp: fields[3] as DateTime,
      retries: fields[4] as int,
      error: fields[5] as String?,
      isCompleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveOperationQueue obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.retries)
      ..writeByte(5)
      ..write(obj.error)
      ..writeByte(6)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveOperationQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

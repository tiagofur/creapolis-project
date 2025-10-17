// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveTaskAdapter extends TypeAdapter<HiveTask> {
  @override
  final int typeId = 2;

  @override
  HiveTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveTask(
      id: fields[0] as int,
      projectId: fields[1] as int,
      title: fields[2] as String,
      description: fields[3] as String,
      status: fields[4] as String,
      priority: fields[5] as String,
      estimatedHours: fields[6] as double,
      actualHours: fields[7] as double,
      assigneeId: fields[8] as int?,
      assigneeName: fields[9] as String?,
      assigneeEmail: fields[17] as String?,
      assigneeRole: fields[18] as String?,
      startDate: fields[10] as DateTime,
      endDate: fields[11] as DateTime,
      dependencyIds: (fields[12] as List).cast<int>(),
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      lastSyncedAt: fields[15] as DateTime?,
      isPendingSync: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveTask obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.estimatedHours)
      ..writeByte(7)
      ..write(obj.actualHours)
      ..writeByte(8)
      ..write(obj.assigneeId)
      ..writeByte(9)
      ..write(obj.assigneeName)
      ..writeByte(17)
      ..write(obj.assigneeEmail)
      ..writeByte(18)
      ..write(obj.assigneeRole)
      ..writeByte(10)
      ..write(obj.startDate)
      ..writeByte(11)
      ..write(obj.endDate)
      ..writeByte(12)
      ..write(obj.dependencyIds)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.lastSyncedAt)
      ..writeByte(16)
      ..write(obj.isPendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

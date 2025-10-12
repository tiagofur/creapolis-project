// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_workspace.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveWorkspaceAdapter extends TypeAdapter<HiveWorkspace> {
  @override
  final int typeId = 0;

  @override
  HiveWorkspace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveWorkspace(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String?,
      avatarUrl: fields[3] as String?,
      type: fields[4] as String,
      ownerId: fields[5] as int,
      userRole: fields[6] as String,
      memberCount: fields[7] as int,
      projectCount: fields[8] as int,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      lastSyncedAt: fields[11] as DateTime?,
      isPendingSync: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveWorkspace obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.ownerId)
      ..writeByte(6)
      ..write(obj.userRole)
      ..writeByte(7)
      ..write(obj.memberCount)
      ..writeByte(8)
      ..write(obj.projectCount)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.lastSyncedAt)
      ..writeByte(12)
      ..write(obj.isPendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveWorkspaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

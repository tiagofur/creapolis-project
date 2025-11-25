// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_sync_conflict.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSyncConflictAdapter extends TypeAdapter<HiveSyncConflict> {
  @override
  final int typeId = 11;

  @override
  HiveSyncConflict read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSyncConflict(
      id: fields[0] as String,
      type: fields[1] as String,
      resourceType: fields[2] as String,
      resourceId: fields[3] as int,
      workspaceId: fields[4] as int?,
      projectId: fields[5] as int?,
      clientVersionJson: fields[6] as String,
      serverVersionJson: fields[7] as String,
      baseVersionJson: fields[8] as String?,
      clientModifiedAt: fields[9] as DateTime,
      serverModifiedAt: fields[10] as DateTime,
      serverModifiedBy: fields[11] as int?,
      serverModifiedByName: fields[12] as String?,
      conflictingFieldsJson: fields[13] as String,
      resolution: fields[14] as String?,
      resolvedDataJson: fields[15] as String?,
      detectedAt: fields[16] as DateTime,
      resolvedAt: fields[17] as DateTime?,
      errorMessage: fields[18] as String?,
      operationId: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSyncConflict obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.resourceType)
      ..writeByte(3)
      ..write(obj.resourceId)
      ..writeByte(4)
      ..write(obj.workspaceId)
      ..writeByte(5)
      ..write(obj.projectId)
      ..writeByte(6)
      ..write(obj.clientVersionJson)
      ..writeByte(7)
      ..write(obj.serverVersionJson)
      ..writeByte(8)
      ..write(obj.baseVersionJson)
      ..writeByte(9)
      ..write(obj.clientModifiedAt)
      ..writeByte(10)
      ..write(obj.serverModifiedAt)
      ..writeByte(11)
      ..write(obj.serverModifiedBy)
      ..writeByte(12)
      ..write(obj.serverModifiedByName)
      ..writeByte(13)
      ..write(obj.conflictingFieldsJson)
      ..writeByte(14)
      ..write(obj.resolution)
      ..writeByte(15)
      ..write(obj.resolvedDataJson)
      ..writeByte(16)
      ..write(obj.detectedAt)
      ..writeByte(17)
      ..write(obj.resolvedAt)
      ..writeByte(18)
      ..write(obj.errorMessage)
      ..writeByte(19)
      ..write(obj.operationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSyncConflictAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

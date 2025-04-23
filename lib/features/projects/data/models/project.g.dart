// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      clientName: fields[1] as String,
      hourlyRate: fields[2] as double,
      timeEntries: (fields[3] as List).cast<TimeEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientName)
      ..writeByte(2)
      ..write(obj.hourlyRate)
      ..writeByte(3)
      ..write(obj.timeEntries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeEntryAdapter extends TypeAdapter<TimeEntry> {
  @override
  final int typeId = 1;

  @override
  TimeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeEntry(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime?,
      description: fields.containsKey(2) ? fields[2] as String? : null,
    );
  }

  @override
  void write(BinaryWriter writer, TimeEntry obj) {
    writer
      ..writeByte(obj.description != null ? 3 : 2)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime);

    if (obj.description != null) {
      writer
        ..writeByte(2)
        ..write(obj.description);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

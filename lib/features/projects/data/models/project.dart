import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String clientName;
  @HiveField(2)
  final double hourlyRate;
  @HiveField(3)
  final List<TimeEntry> timeEntries;

  Project({
    required this.id,
    required this.clientName,
    required this.hourlyRate,
    required this.timeEntries,
  });

  // Create a copy of this Project with modified fields
  Project copyWith({
    String? id,
    String? clientName,
    double? hourlyRate,
    List<TimeEntry>? timeEntries,
  }) {
    return Project(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      timeEntries: timeEntries ?? List.from(this.timeEntries),
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, clientName: $clientName, hourlyRate: $hourlyRate, timeEntries: ${timeEntries.length})';
  }
}

@HiveType(typeId: 1)
class TimeEntry {
  @HiveField(0)
  final DateTime startTime;
  @HiveField(1)
  final DateTime? endTime;
  @HiveField(2)
  final String? description;

  TimeEntry({
    required this.startTime,
    this.endTime,
    this.description,
  });

  // Create a copy of this TimeEntry with modified fields
  TimeEntry copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? description,
  }) {
    return TimeEntry(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'TimeEntry(startTime: $startTime, endTime: $endTime, description: $description)';
  }
}

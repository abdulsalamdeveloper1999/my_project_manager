import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../projects/data/models/project.dart';

class TimerRepository {
  final Box<Project> _projectBox;

  TimerRepository(this._projectBox);

  void addTimeEntry(String projectId, TimeEntry entry) {
    try {
      final project = _projectBox.get(projectId);
      if (project == null) {
        throw Exception('Project not found with ID: $projectId');
      }

      // Create a new list with the existing entries plus the new one
      final updatedEntries = List<TimeEntry>.from(project.timeEntries)
        ..add(entry);

      // Create a new project with the updated entries
      final updatedProject = project.copyWith(timeEntries: updatedEntries);

      // Save the updated project
      _projectBox.put(projectId, updatedProject);

      debugPrint('✅ Added time entry to project $projectId');
    } catch (e) {
      debugPrint('❌ Error adding time entry: $e');
      rethrow; // Rethrow the exception so it can be caught by caller
    }
  }

  void updateTimeEntry(String projectId, int entryIndex, TimeEntry entry) {
    try {
      final project = _projectBox.get(projectId);
      if (project == null) {
        throw Exception('Project not found with ID: $projectId');
      }

      if (entryIndex < 0 || entryIndex >= project.timeEntries.length) {
        throw RangeError('Entry index out of range: $entryIndex');
      }

      // Create a new list with the updated entry
      final updatedEntries = List<TimeEntry>.from(project.timeEntries);
      updatedEntries[entryIndex] = entry;

      // Create a new project with the updated entries
      final updatedProject = project.copyWith(timeEntries: updatedEntries);

      // Save the updated project
      _projectBox.put(projectId, updatedProject);

      debugPrint(
          '✅ Updated time entry at index $entryIndex for project $projectId');
    } catch (e) {
      debugPrint('❌ Error updating time entry: $e');
      rethrow;
    }
  }

  void deleteTimeEntry(String projectId, int entryIndex) {
    try {
      final project = _projectBox.get(projectId);
      if (project == null) {
        throw Exception('Project not found with ID: $projectId');
      }

      if (entryIndex < 0 || entryIndex >= project.timeEntries.length) {
        throw RangeError('Entry index out of range: $entryIndex');
      }

      // Create a new list without the deleted entry
      final updatedEntries = List<TimeEntry>.from(project.timeEntries);
      updatedEntries.removeAt(entryIndex);

      // Create a new project with the updated entries
      final updatedProject = project.copyWith(timeEntries: updatedEntries);

      // Save the updated project
      _projectBox.put(projectId, updatedProject);

      debugPrint(
          '✅ Deleted time entry at index $entryIndex for project $projectId');
    } catch (e) {
      debugPrint('❌ Error deleting time entry: $e');
      rethrow;
    }
  }
}

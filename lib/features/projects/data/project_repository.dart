import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'models/project.dart';

class ProjectRepository {
  final Box<Project> _projectBox;

  ProjectRepository(this._projectBox);

  List<Project> getAllProjects() => _projectBox.values.toList();

  void addProject(Project project) {
    try {
      _projectBox.put(project.id, project);
      debugPrint('✅ Project added: ${project.clientName}');
    } catch (e) {
      debugPrint('❌ Error adding project: $e');
      rethrow;
    }
  }

  void updateProject(Project project) {
    try {
      if (!_projectBox.containsKey(project.id)) {
        throw Exception('Project not found with ID: ${project.id}');
      }
      _projectBox.put(project.id, project);
      debugPrint('✅ Project updated: ${project.clientName}');
    } catch (e) {
      debugPrint('❌ Error updating project: $e');
      rethrow;
    }
  }

  void deleteProject(String id) {
    try {
      if (!_projectBox.containsKey(id)) {
        throw Exception('Project not found with ID: $id');
      }
      _projectBox.delete(id);
      debugPrint('✅ Project deleted with ID: $id');
    } catch (e) {
      debugPrint('❌ Error deleting project: $e');
      rethrow;
    }
  }
}

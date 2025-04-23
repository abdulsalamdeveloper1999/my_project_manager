import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'project_repository.dart';
import '../../timer/data/timer_repository.dart';
import 'models/project.dart';

// Create a projects notifier to manage state
class ProjectsNotifier extends StateNotifier<List<Project>> {
  final ProjectRepository _repository;

  ProjectsNotifier(this._repository) : super([]) {
    _loadProjects();
  }

  void _loadProjects() {
    state = _repository.getAllProjects();
  }

  void addProject(Project project) {
    _repository.addProject(project);
    _loadProjects(); // Reload projects after adding
  }

  void updateProject(Project project) {
    _repository.updateProject(project);
    _loadProjects(); // Reload projects after updating
  }

  void deleteProject(String id) {
    _repository.deleteProject(id);
    _loadProjects(); // Reload projects after deleting
  }

  // New methods for time entries
  void addTimeEntry(String projectId, TimeEntry entry) {
    final timerRepository = TimerRepository(Hive.box<Project>('projects'));
    timerRepository.addTimeEntry(projectId, entry);
    _loadProjects(); // Reload projects to refresh UI everywhere
  }

  void updateTimeEntry(String projectId, int entryIndex, TimeEntry entry) {
    final timerRepository = TimerRepository(Hive.box<Project>('projects'));
    timerRepository.updateTimeEntry(projectId, entryIndex, entry);
    _loadProjects(); // Reload projects to refresh UI everywhere
  }

  void deleteTimeEntry(String projectId, int entryIndex) {
    final timerRepository = TimerRepository(Hive.box<Project>('projects'));
    timerRepository.deleteTimeEntry(projectId, entryIndex);
    _loadProjects(); // Reload projects to refresh UI everywhere
  }
}

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final projectBox = Hive.box<Project>('projects');
  return ProjectRepository(projectBox);
});

// Create a state notifier provider for projects
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectsNotifier(repository);
});

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  final projectBox = Hive.box<Project>('projects');
  return TimerRepository(projectBox);
});

final activeTimerProvider =
    StateNotifierProvider<TimerController, TimeEntry?>((ref) {
  return TimerController();
});

class TimerController extends StateNotifier<TimeEntry?> {
  TimerController() : super(null);

  void startTimer(DateTime startTime, {String? description}) {
    state = TimeEntry(startTime: startTime, description: description);
  }

  void stopTimer(DateTime endTime) {
    if (state != null) {
      state = TimeEntry(
          startTime: state!.startTime,
          endTime: endTime,
          description: state!.description);
    }
  }
}

part of 'projects_cubit.dart';

enum ProjectsStatus { initial, loading, success, error }

class ProjectsState {
  final ProjectsStatus status;
  final List<ProjectEntity> projects;
  final String? errorMessage;
  final String? selectedProjectId;

  const ProjectsState({
    this.status = ProjectsStatus.initial,
    this.projects = const [],
    this.errorMessage,
    this.selectedProjectId,
  });

  ProjectsState copyWith({
    ProjectsStatus? status,
    List<ProjectEntity>? projects,
    String? errorMessage,
    String? selectedProjectId,
  }) {
    return ProjectsState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
    );
  }
}

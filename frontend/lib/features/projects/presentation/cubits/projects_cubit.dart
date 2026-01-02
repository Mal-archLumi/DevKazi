// presentation/cubits/projects_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/projects/domain/repositories/project_repository.dart';

part 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectRepository _repository;

  ProjectsCubit(this._repository) : super(const ProjectsState());

  Future<void> loadProjects(String teamId) async {
    if (state.status == ProjectsStatus.loading) return;

    emit(state.copyWith(status: ProjectsStatus.loading));

    try {
      final projects = await _repository.getProjectsByTeam(teamId);
      emit(
        state.copyWith(
          status: ProjectsStatus.success,
          projects: projects,
          errorMessage: null,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProjectsStatus.error,
          errorMessage: 'Failed to load projects: $e',
        ),
      );
    }
  }

  Future<void> createProject({
    required String teamId,
    required String name,
    required String? description,
    required List<ProjectAssignment> assignments,
    required List<TimelinePhase> timeline,
  }) async {
    try {
      final project = await _repository.createProject(
        teamId: teamId,
        name: name,
        description: description,
        assignments: assignments,
        timeline: timeline,
      );

      final updatedProjects = List<ProjectEntity>.from(state.projects)
        ..add(project);

      emit(
        state.copyWith(
          projects: updatedProjects,
          status: ProjectsStatus.success,
          errorMessage: null,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
      rethrow;
    } catch (e) {
      final failure = ServerFailure('Failed to create project: $e');
      emit(
        state.copyWith(
          status: ProjectsStatus.error,
          errorMessage: failure.message,
        ),
      );
      throw failure;
    }
  }

  Future<void> updateProject({
    required String projectId,
    required String name,
    required String? description,
    required List<ProjectAssignment> assignments,
    required List<TimelinePhase> timeline,
  }) async {
    try {
      final updatedProject = await _repository.updateProject(
        projectId: projectId,
        name: name,
        description: description,
        assignments: assignments,
        timeline: timeline,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId);

      final updatedProjects = state.projects
          .where((project) => project.id != projectId)
          .toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
      rethrow;
    }
  }

  Future<void> pinLink({
    required String projectId,
    required String title,
    required String url,
  }) async {
    try {
      final updatedProject = await _repository.pinLink(
        projectId: projectId,
        title: title,
        url: url,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    }
  }

  Future<void> addIdea({
    required String projectId,
    required String title,
    required String description,
  }) async {
    try {
      final updatedProject = await _repository.addIdea(
        projectId: projectId,
        title: title,
        description: description,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    }
  }

  // Uncomment and fix the implementation of these methods

  Future<void> assignTeamMember({
    required String projectId,
    required String assignmentId,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      final updatedProject = await _repository.assignTeamMember(
        projectId: projectId,
        assignmentId: assignmentId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    }
  }

  Future<void> updateTimelinePhase({
    required String projectId,
    required String phaseId,
    String? phase,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      final updatedProject = await _repository.updateTimelinePhase(
        projectId: projectId,
        phaseId: phaseId,
        phase: phase,
        description: description,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    }
  }

  Future<void> deletePinnedLink({
    required String projectId,
    required String linkId,
  }) async {
    try {
      final updatedProject = await _repository.deletePinnedLink(
        projectId: projectId,
        linkId: linkId,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    }
  }

  Future<void> updateIdeaStatus({
    required String projectId,
    required String ideaId,
    required String status,
  }) async {
    try {
      final updatedProject = await _repository.updateIdeaStatus(
        projectId: projectId,
        ideaId: ideaId,
        status: status,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    }
  }

  Future<void> deleteIdea({
    required String projectId,
    required String ideaId,
  }) async {
    try {
      final updatedProject = await _repository.deleteIdea(
        projectId: projectId,
        ideaId: ideaId,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    }
  }

  Future<void> updateProjectProgress({
    required String projectId,
    required double progress,
  }) async {
    try {
      final updatedProject = await _repository.updateProjectProgress(
        projectId: projectId,
        progress: progress,
      );

      final updatedProjects = state.projects.map((project) {
        return project.id == projectId ? updatedProject : project;
      }).toList();

      emit(state.copyWith(projects: updatedProjects));
    } on Failure catch (e) {
      emit(
        state.copyWith(status: ProjectsStatus.error, errorMessage: e.message),
      );
    }
  }
}

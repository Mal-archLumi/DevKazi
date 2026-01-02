// data/repositories/project_repository_impl.dart (FIXED VERSION)
import 'package:dio/dio.dart';
import 'package:frontend/core/errors/exceptions.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/network/network_info.dart';
import 'package:frontend/features/projects/data/data_sources/project_remote_data_source.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<ProjectEntity>> getProjectsByTeam(String teamId) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final projects = await remoteDataSource.getProjectsByTeam(teamId);
      return projects;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to fetch projects');
    }
  }

  @override
  Future<ProjectEntity> createProject({
    required String teamId,
    required String name,
    required String? description,
    required List<ProjectAssignment> assignments,
    required List<TimelinePhase> timeline,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.createProject(
        teamId: teamId,
        name: name,
        description: description,
        assignments: assignments,
        timeline: timeline,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on DioException catch (e) {
      throw ConnectionFailure('Network error: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to create project: $e');
    }
  }

  @override
  Future<ProjectEntity> updateProject({
    required String projectId,
    required String name,
    required String? description,
    required List<ProjectAssignment> assignments,
    required List<TimelinePhase> timeline,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.updateProject(
        projectId: projectId,
        name: name,
        description: description,
        assignments: assignments,
        timeline: timeline,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to update project');
    }
  }

  @override
  Future<ProjectEntity> pinLink({
    required String projectId,
    required String title,
    required String url,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.pinLink(
        projectId: projectId,
        title: title,
        url: url,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to pin link');
    }
  }

  @override
  Future<ProjectEntity> addIdea({
    required String projectId,
    required String title,
    required String description,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.addIdea(
        projectId: projectId,
        title: title,
        description: description,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to add idea');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      await remoteDataSource.deleteProject(projectId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to delete project');
    }
  }

  @override
  Future<ProjectEntity> deletePinnedLink({
    required String projectId,
    required String linkId,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.deletePinnedLink(
        projectId: projectId,
        linkId: linkId,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to delete pinned link');
    }
  }

  @override
  Future<ProjectEntity> updateIdeaStatus({
    required String projectId,
    required String ideaId,
    required String status,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.updateIdeaStatus(
        projectId: projectId,
        ideaId: ideaId,
        status: status,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to update idea status');
    }
  }

  @override
  Future<ProjectEntity> deleteIdea({
    required String projectId,
    required String ideaId,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.deleteIdea(
        projectId: projectId,
        ideaId: ideaId,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to delete idea');
    }
  }

  @override
  Future<ProjectEntity> updateProjectProgress({
    required String projectId,
    required double progress,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.updateProjectProgress(
        projectId: projectId,
        progress: progress,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to update project progress');
    }
  }

  @override
  Future<ProjectEntity> updateTimelinePhase({
    required String projectId,
    required String phaseId,
    String? phase,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ConnectionFailure('No internet connection');
    }

    try {
      final project = await remoteDataSource.updateTimelinePhase(
        projectId: projectId,
        phaseId: phaseId,
        phase: phase,
        description: description,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      return project;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to update timeline phase');
    }
  }

  // REMOVE THIS METHOD - It's not in the ProjectRemoteDataSource anymore
  // OR if you need to keep it for interface compatibility, implement it differently:
  @override
  Future<ProjectEntity> assignTeamMember({
    required String projectId,
    required String assignmentId,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    // This method should update the entire project instead
    // Since we removed the dedicated endpoint, we need to handle this differently
    throw ServerFailure(
      'Team member assignment should be done through project update API',
    );

    // Alternative: If you want to implement it, you could:
    // 1. First fetch the current project
    // 2. Update the assignments array
    // 3. Call updateProject with the modified data
    // But this requires having access to the full project data
  }
}

// domain/repositories/project_repository.dart
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjectsByTeam(String teamId);
  Future<ProjectEntity> createProject({
    required String teamId,
    required String name,
    required String? description,
    required List<ProjectAssignment> assignments,
    required List<TimelinePhase> timeline,
  });
  Future<ProjectEntity> updateProject({
    required String projectId,
    required String name,
    required String? description,
    required List<ProjectAssignment> assignments,
    required List<TimelinePhase> timeline,
  });
  Future<ProjectEntity> pinLink({
    required String projectId,
    required String title,
    required String url,
  });
  Future<ProjectEntity> addIdea({
    required String projectId,
    required String title,
    required String description,
  });
  Future<void> deleteProject(String projectId);

  // New methods with proper return types
  Future<ProjectEntity> assignTeamMember({
    required String projectId,
    required String assignmentId,
    required String userId,
    required String userName,
    required String userEmail,
  });

  Future<ProjectEntity> updateTimelinePhase({
    required String projectId,
    required String phaseId,
    String? phase,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });

  Future<ProjectEntity> deletePinnedLink({
    required String projectId,
    required String linkId,
  });

  Future<ProjectEntity> updateIdeaStatus({
    required String projectId,
    required String ideaId,
    required String status,
  });

  Future<ProjectEntity> deleteIdea({
    required String projectId,
    required String ideaId,
  });

  Future<ProjectEntity> updateProjectProgress({
    required String projectId,
    required double progress,
  });
}

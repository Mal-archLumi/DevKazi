// project_remote_data_source.dart (FIXED VERSION)
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontend/core/errors/exceptions.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';

abstract class ProjectRemoteDataSource {
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

  // Updated method signatures
  Future<ProjectEntity> deletePinnedLink({
    required String projectId,
    required String linkId,
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

  // REMOVE THIS - Backend doesn't have this endpoint
  // Future<ProjectEntity> assignTeamMember({
  //   required String projectId,
  //   required String assignmentId,
  //   required String userId,
  //   required String userName,
  //   required String userEmail,
  // });
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient client;

  ProjectRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProjectEntity>> getProjectsByTeam(String teamId) async {
    try {
      print('🟡 ProjectRemoteDataSource: Fetching projects for team $teamId');

      if (teamId.isEmpty) {
        print('🔴 ProjectRemoteDataSource: Team ID is empty');
        throw ServerException('Team ID is required');
      }

      final response = await client.get(
        '/projects/team/$teamId',
        requiresAuth: true,
      );

      print(
        '🟡 ProjectRemoteDataSource: Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 && response.data != null) {
        print('🟢 ProjectRemoteDataSource: Successfully fetched projects');

        final List<dynamic> projectsData = response.data is List
            ? response.data
            : [response.data];

        final projects = projectsData
            .map(
              (projectJson) =>
                  ProjectEntity.fromJson(projectJson as Map<String, dynamic>),
            )
            .toList();

        print('🟢 ProjectRemoteDataSource: Parsed ${projects.length} projects');
        return projects;
      } else {
        print(
          '🔴 ProjectRemoteDataSource: Failed with status ${response.statusCode}',
        );
        throw ServerException('Failed to fetch projects');
      }
    } on DioException catch (e) {
      print('🔴 ProjectRemoteDataSource: DioException: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e, stackTrace) {
      print('🔴 ProjectRemoteDataSource: Unexpected error: $e');
      print('🔴 Stack trace: $stackTrace');
      throw ServerException('Failed to fetch projects: $e');
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
    try {
      // FIX: Only include userId if it's NOT null and NOT empty
      final fixedAssignments = assignments.map((a) {
        final assignmentData = <String, dynamic>{
          'role': a.role,
          'tasks': a.tasks,
          'assignedTo': a.assignedTo ?? '', // FIX: Always include assignedTo
        };

        // Only add userId if it exists and is not empty
        if (a.userId != null && a.userId!.isNotEmpty) {
          assignmentData['userId'] = a.userId!;
        }

        return assignmentData;
      }).toList();

      // FIX: Ensure timeline dates are formatted correctly
      final fixedTimeline = timeline.map((t) {
        return {
          'phase': t.phase,
          'description': t.description ?? '',
          'startDate': t.startDate.toIso8601String(),
          'endDate': t.endDate.toIso8601String(),
          'status': t.status,
        };
      }).toList();

      final requestData = {
        'teamId': teamId,
        'name': name,
        'description': description ?? '',
        'assignments': fixedAssignments,
        'timeline': fixedTimeline,
      };

      // DETAILED LOGGING
      print('🟡 Creating project with data:');
      print('   Team ID: $teamId');
      print('   Name: $name');
      print('   Description: $description');
      print('   Full request body: ${jsonEncode(requestData)}');

      final response = await client.post(
        '/projects',
        data: requestData,
        requiresAuth: true,
      );

      print('🟢 Project created successfully: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to create project');
      }
    } on DioException catch (e) {
      print('🔴 DioException creating project:');
      print('   Status: ${e.response?.statusCode}');
      print('   Error data: ${jsonEncode(e.response?.data)}');
      print('   Error message: ${e.message}');

      throw ServerException(
        e.response?.data?['message'] ??
            e.response?.data?['errors']?.join(', ') ??
            'Network error occurred',
      );
    } catch (e) {
      print('🔴 Unexpected error creating project: $e');
      throw ServerException('Failed to create project: $e');
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
    try {
      // FIX: Use the same data structure as create
      final fixedAssignments = assignments.map((a) {
        final assignmentData = <String, dynamic>{
          'role': a.role,
          'tasks': a.tasks,
          'assignedTo': a.assignedTo ?? '', // FIX: Always include assignedTo
        };

        // Only add userId if it exists and is not empty
        if (a.userId != null && a.userId!.isNotEmpty) {
          assignmentData['userId'] = a.userId!;
        }

        return assignmentData;
      }).toList();

      final fixedTimeline = timeline.map((t) {
        return {
          'phase': t.phase,
          'description': t.description ?? '',
          'startDate': t.startDate.toIso8601String(),
          'endDate': t.endDate.toIso8601String(),
          'status': t.status ?? 'planned',
        };
      }).toList();

      final requestData = {
        'name': name,
        'description': description ?? '',
        'assignments': fixedAssignments,
        'timeline': fixedTimeline,
      };

      print(
        '🟡 Updating project $projectId with data: ${jsonEncode(requestData)}',
      );

      final response = await client.put(
        '/projects/$projectId',
        data: requestData,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        print('🟢 Project updated successfully');
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to update project');
      }
    } on DioException catch (e) {
      print('🔴 DioException updating project: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      print('🔴 Unexpected error updating project: $e');
      throw ServerException('Failed to update project');
    }
  }

  @override
  Future<ProjectEntity> pinLink({
    required String projectId,
    required String title,
    required String url,
  }) async {
    try {
      final response = await client.post(
        '/projects/$projectId/pin-link',
        data: {'title': title, 'url': url},
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to pin link');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException('Failed to pin link');
    }
  }

  @override
  Future<ProjectEntity> addIdea({
    required String projectId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await client.post(
        '/projects/$projectId/ideas',
        data: {'title': title, 'description': description},
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to add idea');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException('Failed to add idea');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      final response = await client.delete(
        '/projects/$projectId',
        requiresAuth: true,
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to delete project');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException('Failed to delete project');
    }
  }

  // REMOVE THIS METHOD - Backend doesn't support it
  // @override
  // Future<ProjectEntity> assignTeamMember({
  //   required String projectId,
  //   required String assignmentId,
  //   required String userId,
  //   required String userName,
  //   required String userEmail,
  // }) async {
  //   throw ServerException('This feature is not implemented in backend');
  // }

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
    try {
      print('🟡 Updating timeline phase $phaseId for project $projectId');

      final requestData = <String, dynamic>{};
      if (phase != null) requestData['phase'] = phase;
      if (description != null) requestData['description'] = description;
      if (startDate != null) {
        requestData['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) requestData['endDate'] = endDate.toIso8601String();
      if (status != null) requestData['status'] = status;

      final response = await client.put(
        '/projects/$projectId/timeline/$phaseId',
        data: requestData,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        print('🟢 Successfully updated timeline phase');
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to update timeline phase');
      }
    } on DioException catch (e) {
      print('🔴 DioException updating timeline phase: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      print('🔴 Unexpected error updating timeline phase: $e');
      throw ServerException('Failed to update timeline phase: $e');
    }
  }

  @override
  Future<ProjectEntity> deletePinnedLink({
    required String projectId,
    required String linkId,
  }) async {
    try {
      print('🟡 Deleting pinned link $linkId from project $projectId');

      final response = await client.delete(
        '/projects/$projectId/pin-link/$linkId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        print('🟢 Successfully deleted pinned link');
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to delete pinned link');
      }
    } on DioException catch (e) {
      print('🔴 DioException deleting pinned link: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      print('🔴 Unexpected error deleting pinned link: $e');
      throw ServerException('Failed to delete pinned link: $e');
    }
  }

  @override
  Future<ProjectEntity> updateIdeaStatus({
    required String projectId,
    required String ideaId,
    required String status,
  }) async {
    try {
      print(
        '🟡 Updating idea status: $ideaId to $status for project $projectId',
      );

      final response = await client.put(
        '/projects/$projectId/ideas/$ideaId/status',
        data: {'status': status},
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        print('🟢 Successfully updated idea status');
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to update idea status');
      }
    } on DioException catch (e) {
      print('🔴 DioException updating idea status: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      print('🔴 Unexpected error updating idea status: $e');
      throw ServerException('Failed to update idea status: $e');
    }
  }

  @override
  Future<ProjectEntity> deleteIdea({
    required String projectId,
    required String ideaId,
  }) async {
    try {
      print('🟡 Deleting idea $ideaId from project $projectId');

      final response = await client.delete(
        '/projects/$projectId/ideas/$ideaId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        print('🟢 Successfully deleted idea');
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to delete idea');
      }
    } on DioException catch (e) {
      print('🔴 DioException deleting idea: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      print('🔴 Unexpected error deleting idea: $e');
      throw ServerException('Failed to delete idea: $e');
    }
  }

  @override
  Future<ProjectEntity> updateProjectProgress({
    required String projectId,
    required double progress,
  }) async {
    try {
      print(
        '🟡 Updating project progress: $projectId to ${(progress * 100).toStringAsFixed(1)}%',
      );

      final response = await client.put(
        '/projects/$projectId/progress',
        data: {'progress': progress},
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        print('🟢 Successfully updated project progress');
        return ProjectEntity.fromJson(response.data);
      } else {
        throw ServerException('Failed to update project progress');
      }
    } on DioException catch (e) {
      print('🔴 DioException updating project progress: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      print('🔴 Unexpected error updating project progress: $e');
      throw ServerException('Failed to update project progress: $e');
    }
  }
}

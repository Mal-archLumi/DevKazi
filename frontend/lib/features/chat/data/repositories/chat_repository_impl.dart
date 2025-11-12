import 'dart:async';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/network/network_info.dart';
import 'package:frontend/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Logger _logger = Logger();
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<MessageEntity> get messageStream =>
      remoteDataSource.messageStream.map((model) => model.toEntity());

  @override
  Stream<void> get onConnected => remoteDataSource.onConnected;

  @override
  Stream<void> get onAuthenticated => remoteDataSource.onConnected;

  @override
  Future<Either<Failure, void>> connect(String teamId, String token) async {
    try {
      _logger.i('🔄 Connecting to socket for team: $teamId');
      _logger.i('🔑 Token length: ${token.length}');

      await remoteDataSource.connect(teamId, token);

      _logger.i('✅ Connection completed successfully');
      return const Right(null);
    } catch (e) {
      _logger.e('⛔ Connection error: $e');
      return Left(ServerFailure('Connection failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    try {
      await remoteDataSource.disconnect();
      return const Right(null);
    } catch (e) {
      _logger.e('❌ Error disconnecting: $e');
      return Left(ServerFailure('Failed to disconnect: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(
    String teamId,
    String content,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      _logger.i('📤 Sending message to team $teamId');
      _logger.i(
        '🔍 Remote data source connected: ${remoteDataSource.isConnected}',
      );

      await remoteDataSource.sendMessage(teamId, content);

      _logger.i('✅ Message sent successfully');
      return const Right(null);
    } catch (e) {
      _logger.e('❌ Error sending message: $e');
      return Left(ServerFailure('Failed to send message: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getTeamMessages(
    String teamId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final messages = await remoteDataSource.getTeamMessages(teamId);
      final messageEntities = messages
          .map((model) => model.toEntity())
          .toList();
      _logger.i('✅ Loaded ${messageEntities.length} messages for team $teamId');
      return Right(messageEntities);
    } catch (e) {
      _logger.e('❌ Error getting team messages: $e');
      return Left(ServerFailure('Failed to get team messages: $e'));
    }
  }

  @override
  bool get isConnected => remoteDataSource.isConnected;
}

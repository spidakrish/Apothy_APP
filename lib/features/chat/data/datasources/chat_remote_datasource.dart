import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/message.dart';

/// Abstract interface for remote chat operations
abstract class ChatRemoteDatasource {
  /// Sends a message to the backend and returns a streaming response
  Future<Either<ChatFailure, Stream<String>>> sendMessageAndStream({
    required String chatId,
    required String message,
  });
}

/// Implementation of ChatRemoteDatasource
class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final Dio _dio;

  ChatRemoteDatasourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<Either<ChatFailure, Stream<String>>> sendMessageAndStream({
    required String chatId,
    required String message,
  }) async {
    try {
      final endpoint = '${ApiConstants.mobileChatsEndpoint}/$chatId';

      final response = await _dio.post(
        endpoint,
        data: {'message': message},
        options: Options(
          responseType: ResponseType.stream,
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == null || response.statusCode! >= 400) {
        return Left(
          ChatFailure.unknown('Failed to send message: ${response.statusCode}'),
        );
      }

      // Cast response.data to Stream and convert bytes to string
      final responseStream = response.data as Stream<dynamic>;

      final stream = responseStream
          .map((event) => String.fromCharCodes(event as List<int>))
          .handleError((error) {
            throw ChatFailure.unknown('Stream error: $error');
          });

      return Right(stream);
    } on DioException catch (e) {
      return Left(ChatFailure.unknown('Network error: ${e.message}'));
    } catch (e) {
      return Left(ChatFailure.unknown('Unexpected error: $e'));
    }
  }
}

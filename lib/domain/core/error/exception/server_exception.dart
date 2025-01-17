import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

enum ServerExceptionType {
  requestCancelled,
  badCertificate,
  unauthorisedRequest,
  connectionError,
  badRequest,
  notFound,
  requestTimeout,
  sendTimeout,
  receiveTimeout,
  conflict,
  internalServerError,
  notImplemented,
  serviceUnavailable,
  socketException,
  formatException,
  unableToProcess,
  defaultError,
  unexpectedError,
}

class ServerException extends Equatable implements Exception {
  final String name, message;
  final int? statusCode;
  final ServerExceptionType exceptionType;

  ServerException._({
    required this.message,
    this.exceptionType = ServerExceptionType.unexpectedError,
    int? statusCode,
  })  : statusCode = statusCode ?? 500,
        name = exceptionType.name;

  factory ServerException(dynamic error) {
    late ServerException serverException;
    try {
      if (error is DioException) {
        switch (error.type) {
          case DioExceptionType.cancel:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.requestCancelled,
                statusCode: error.response?.statusCode,
                message: 'Request to the server has been canceled');
            break;

          case DioExceptionType.connectionTimeout:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.requestTimeout,
                statusCode: error.response?.statusCode,
                message: 'Connection timeout');
            break;

          case DioExceptionType.receiveTimeout:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.receiveTimeout,
                statusCode: error.response?.statusCode,
                message: 'Receive timeout');
            break;

          case DioExceptionType.sendTimeout:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.sendTimeout,
                statusCode: error.response?.statusCode,
                message: 'Send timeout');
            break;

          case DioExceptionType.connectionError:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.connectionError,
                message: 'Connection error');
            break;
          case DioExceptionType.badCertificate:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.badCertificate,
                message: 'Bad certificate');
            break;
          case DioExceptionType.unknown:
            if (error.error
                .toString()
                .contains(ServerExceptionType.socketException.name)) {
              serverException = ServerException._(
                  statusCode: error.response?.statusCode,
                  message: 'Verify your internet connection');
            } else {
              serverException = ServerException._(
                  exceptionType: ServerExceptionType.unexpectedError,
                  statusCode: error.response?.statusCode,
                  message: 'Unexpected error');
            }
            break;

          case DioExceptionType.badResponse:
            switch (error.response?.statusCode) {
              case 400:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.badRequest,
                    message: 'Bad request.');
                break;
              case 401:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unauthorisedRequest,
                    message: 'Authentication failure');
                break;
              case 403:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unauthorisedRequest,
                    message: 'User is not authorized to access API');
                break;
              case 404:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.notFound,
                    message: 'Request resource does not exist');
                break;
              case 405:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unauthorisedRequest,
                    message: 'Operation not allowed');
                break;
              case 415:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.notImplemented,
                    message: 'Media type unsupported');
                break;
              case 422:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unableToProcess,
                    message: 'validation data failure');
                break;
              case 429:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.conflict,
                    message: 'too much requests');
                break;
              case 500:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.internalServerError,
                    message: 'Internal server error');
                break;
              case 503:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.serviceUnavailable,
                    message: 'Service unavailable');
                break;
              default:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unexpectedError,
                    message: 'Unexpected error-1');
            }
            break;
        }
      } else if (error is Response) {
        String message;
        String code;
        if (error.data['message'] != null) {
          message = error.data['message'];
        } else if (error.data['error'] != null) {
          List<dynamic> errorList = error.data['error'];
          List<String> errorValues = [];
          for (var item in errorList) {
            if (item is Map) {
              List<String> values =
                  item.values.map((value) => value.toString()).toList();
              errorValues.addAll(values);
            }
          }
          message = errorValues.join(" & ");
        } else {
          message = "Unknown error";
        }

        if (error.data['code'] != null) {
          code = error.data['code'];
        } else {
          code = 'Error';
        }
        serverException = ServerException._(message: '$code - $message');
      } else {
        serverException = ServerException._(
            exceptionType: ServerExceptionType.unexpectedError,
            message: 'Unexpected error-2');
      }
    } on FormatException catch (e) {
      serverException = ServerException._(
          exceptionType: ServerExceptionType.formatException,
          message: e.message);
    } on Exception catch (_) {
      serverException = ServerException._(
          exceptionType: ServerExceptionType.unexpectedError,
          message: 'Unexpected error-3');
    }

    return serverException;
  }

  @override
  List<Object?> get props => [name, statusCode, exceptionType];
}

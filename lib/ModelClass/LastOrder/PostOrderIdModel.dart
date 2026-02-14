import 'dart:convert';

import '../../Bloc/Response/errorResponse.dart';


PostOrderIdModel postOrderIdModelFromJson(String str) => PostOrderIdModel.fromJson(json.decode(str));
String postOrderIdModelToJson(PostOrderIdModel data) => json.encode(data.toJson());

class PostOrderIdModel {
  PostOrderIdModel({
    bool? success,
    String? message,
    this.errorResponse,
  }) {
    _success = success;
    _message = message;
  }

  PostOrderIdModel.fromJson(dynamic json) {
    // --- Error Message Implementation ---
    // Checks if success is false or if the errors object is present
    if (json['success'] == false || json['errors'] != null) {
      if (json['errors'] != null) {
        errorResponse = ErrorResponse.fromJson(json['errors']);
      } else if (json['message'] != null) {
        errorResponse = ErrorResponse(
          message: json['message'].toString(),
          statusCode: json['status'] ?? 400,
        );
      }
    }

    _success = json['success'];
    _message = json['message'];
  }

  bool? _success;
  String? _message;
  ErrorResponse? errorResponse; // Public error field

  PostOrderIdModel copyWith({
    bool? success,
    String? message,
    ErrorResponse? errorResponse,
  }) => PostOrderIdModel(
    success: success ?? _success,
    message: message ?? _message,
    errorResponse: errorResponse ?? this.errorResponse,
  );

  bool? get success => _success;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    map['message'] = _message;
    if (errorResponse != null) {
      map['errors'] = errorResponse?.toJson();
    }
    return map;
  }
}
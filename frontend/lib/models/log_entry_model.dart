import 'package:flutter/material.dart';

class LogEntry {
  final String id;
  final String level;
  final String loggerName;
  final String message;
  final String? module;
  final String? function;
  final int? lineNumber;
  final String? requestMethod;
  final String? requestPath;
  final String? requestUserId;
  final String? requestUserName;
  final int? responseStatus;
  final double? responseTimeMs;
  final String? exceptionType;
  final String? exceptionMessage;
  final String? traceback;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? extraData;
  final DateTime createdAt;
  final bool isError;
  final String shortMessage;

  LogEntry({
    required this.id,
    required this.level,
    required this.loggerName,
    required this.message,
    this.module,
    this.function,
    this.lineNumber,
    this.requestMethod,
    this.requestPath,
    this.requestUserId,
    this.requestUserName,
    this.responseStatus,
    this.responseTimeMs,
    this.exceptionType,
    this.exceptionMessage,
    this.traceback,
    this.ipAddress,
    this.userAgent,
    this.extraData,
    required this.createdAt,
    required this.isError,
    required this.shortMessage,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    final message = json['message']?.toString() ?? '';
    return LogEntry(
      id: json['id']?.toString() ?? '',
      level: json['level']?.toString() ?? 'INFO',
      loggerName: json['logger_name']?.toString() ?? '',
      message: message,
      module: json['module']?.toString(),
      function: json['function']?.toString(),
      lineNumber: json['line_number'],
      requestMethod: json['request_method']?.toString(),
      requestPath: json['request_path']?.toString(),
      requestUserId: json['request_user']?.toString(),
      requestUserName: json['request_user_name']?.toString(),
      responseStatus: json['response_status'],
      responseTimeMs: json['response_time_ms']?.toDouble(),
      exceptionType: json['exception_type']?.toString(),
      exceptionMessage: json['exception_message']?.toString(),
      traceback: json['traceback']?.toString(),
      ipAddress: json['ip_address']?.toString(),
      userAgent: json['user_agent']?.toString(),
      extraData: json['extra_data'] is Map ? Map<String, dynamic>.from(json['extra_data']) : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isError: json['is_error'] ?? false,
      shortMessage: json['short_message']?.toString() ?? message,
    );
  }

  Color get levelColor {
    switch (level) {
      case 'DEBUG':
        return Colors.grey;
      case 'INFO':
        return Colors.blue;
      case 'WARNING':
        return Colors.orange;
      case 'ERROR':
        return Colors.red;
      case 'CRITICAL':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }
}


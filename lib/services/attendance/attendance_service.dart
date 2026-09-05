import 'dart:math';

import 'package:gep/models/attendance/qr_code_data.dart';
import 'package:gep/models/paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<QrCodeData> generateQrCode(String shiftId, DateTime date) async {
    final token = _generateToken();
    final expiresAt = DateTime.now().add(const Duration(hours: 12));

    await _supabase.from('attendance_qr_codes').upsert({
      'shift_id': shiftId,
      'date': date.toIso8601String().split('T').first,
      'qr_token': token,
      'expires_at': expiresAt.toIso8601String(),
    });

    return QrCodeData(shiftId: shiftId, date: date, token: token);
  }

  Future<QrCodeData?> getQrCodeForShiftAndDate(
    String shiftId,
    DateTime date,
  ) async {
    final data = await _supabase
        .from('attendance_qr_codes')
        .select()
        .eq('shift_id', shiftId)
        .eq('date', date.toIso8601String().split('T').first)
        .maybeSingle();

    if (data == null) return null;
    return QrCodeData.fromMap(data);
  }

  Future<bool> validateQrToken(String token) async {
    final data = await _supabase
        .from('attendance_qr_codes')
        .select()
        .eq('qr_token', token)
        .maybeSingle();

    if (data == null) return false;
    final expiresAt = DateTime.tryParse(data['expires_at'] ?? '');
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt);
  }

  Future<QrCodeData?> getQrDataByToken(String token) async {
    final data = await _supabase
        .from('attendance_qr_codes')
        .select()
        .eq('qr_token', token)
        .maybeSingle();

    if (data == null) return null;
    return QrCodeData.fromMap(data);
  }

  Future<bool> isAlreadyMarked(String shiftId, String studentId, DateTime date) async {
    final data = await _supabase
        .from('attendance')
        .select()
        .eq('shift_id', shiftId)
        .eq('student_id', studentId)
        .eq('date', date.toIso8601String().split('T').first)
        .maybeSingle();
    return data != null;
  }

  Future<void> markAttendance({
    required String shiftId,
    required String studentId,
    required DateTime date,
    String markedBy = 'qr_scan',
  }) async {
    await _supabase.from('attendance').upsert({
      'shift_id': shiftId,
      'student_id': studentId,
      'date': date.toIso8601String().split('T').first,
      'marked_by': markedBy,
    });
  }

  Future<PaginatedResult<Map<String, dynamic>>> getAttendanceRecordsPaginated({
    required int page,
    required int pageSize,
    String? shiftId,
    DateTime? date,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize;

    var builder = _supabase
        .from('attendance')
        .select('id, date, marked_at, marked_by, shifts(name), enrolled_students(name)');

    if (shiftId != null && shiftId.isNotEmpty) {
      builder = builder.eq('shift_id', shiftId);
    }
    if (date != null) {
      builder = builder.eq('date', date.toIso8601String().split('T').first);
    }

    final data = await builder
        .order('date', ascending: false)
        .range(from, to);
    final hasMore = data.length > pageSize;
    final items = data.take(pageSize).toList();

    return PaginatedResult(items: items, hasMore: hasMore);
  }

  Future<Map<String, dynamic>> getStudentAttendanceSummary(
    String studentId,
    int year,
    int month,
  ) async {
    final data = await _supabase.rpc('get_student_attendance_monthly', params: {
      'p_student_id': studentId,
      'p_year': year,
      'p_month': month,
    });
    return (data as List<dynamic>).firstOrNull as Map<String, dynamic>? ?? {};
  }

  Future<List<Map<String, dynamic>>> getStudentAttendanceRange(
    String studentId,
    DateTime start,
    DateTime end,
  ) async {
    final data = await _supabase.rpc('get_student_attendance_range', params: {
      'p_student_id': studentId,
      'p_start_date': start.toIso8601String().split('T').first,
      'p_end_date': end.toIso8601String().split('T').first,
    });
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getStudentMonthlyAttendance(
    String studentId,
    int year,
    int month,
  ) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return getStudentAttendanceRange(studentId, start, end);
  }
}

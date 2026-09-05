import 'package:gep/core/constants/constants.dart';
import 'package:gep/services/attendance/attendance_service.dart';
import 'package:gep/services/auth/auth_service.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanAttendanceScreen extends StatefulWidget {
  const ScanAttendanceScreen({super.key});

  @override
  State<ScanAttendanceScreen> createState() => _ScanAttendanceScreenState();
}

class _ScanAttendanceScreenState extends State<ScanAttendanceScreen> {
  bool _isProcessing = false;
  bool _success = false;
  String _message = 'Scan the attendance QR code';
  MobileScannerController? _scannerController;

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getStudentRecord() async {
    final user = AuthService().getCurrentUser();
    if (user?.email == null) return null;
    try {
      final data = await Supabase.instance.client
          .from('enrolled_students')
          .select('id, shift_id')
          .eq('email', user!.email!)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onDetect(String rawValue) async {
    if (_isProcessing || _success) return;
    setState(() {
      _isProcessing = true;
      _message = 'Validating…';
    });

    try {
      final service = AttendanceService();
      final isValid = await service.validateQrToken(rawValue);
      if (!isValid) {
        setState(() {
          _isProcessing = false;
          _message = 'Invalid or expired QR code';
        });
        return;
      }

      final qrData = await service.getQrDataByToken(rawValue);
      if (qrData == null) {
        setState(() {
          _isProcessing = false;
          _message = 'QR data not found';
        });
        return;
      }

      final studentRecord = await _getStudentRecord();
      if (studentRecord == null) {
        setState(() {
          _isProcessing = false;
          _message = 'Student record not found. Contact admin.';
        });
        return;
      }

      final studentId = studentRecord['id']?.toString();
      final studentShiftId = studentRecord['shift_id']?.toString();

      if (studentId == null || studentId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _message = 'Student record not found. Contact admin.';
        });
        return;
      }

      // Validate that the student has a shift assigned
      if (studentShiftId == null || studentShiftId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _message = 'No shift assigned. Contact admin.';
        });
        return;
      }

      // Validate that the scanned QR matches the student's assigned shift
      if (studentShiftId != qrData.shiftId) {
        setState(() {
          _isProcessing = false;
          _message = 'This QR is not for your assigned shift.';
        });
        return;
      }

      final alreadyMarked = await service.isAlreadyMarked(
        qrData.shiftId,
        studentId,
        qrData.date,
      );
      if (alreadyMarked) {
        setState(() {
          _isProcessing = false;
          _success = true;
          _message = 'Attendance already marked for today!';
        });
        return;
      }

      await service.markAttendance(
        shiftId: qrData.shiftId,
        studentId: studentId,
        date: qrData.date,
      );

      setState(() {
        _isProcessing = false;
        _success = true;
        _message = 'Attendance marked successfully!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _message = 'Error: $e';
      });
    }
  }

  void _reset() {
    setState(() {
      _isProcessing = false;
      _success = false;
      _message = 'Scan the attendance QR code';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return AppScaffold(
      title: 'Mark Attendance',
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                    facing: CameraFacing.back,
                    torchEnabled: false,
                  ),
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull;
                    if (barcode?.rawValue != null) {
                      _onDetect(barcode!.rawValue!);
                    }
                  },
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(AppConstants.defaultPadding),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _success
                  ? AppColors.success.withValues(alpha: 0.1)
                  : cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _success ? AppColors.success : borderColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _success
                      ? Icons.check_circle_rounded
                      : _isProcessing
                          ? Icons.hourglass_top_rounded
                          : Icons.info_outline_rounded,
                  color: _success
                      ? AppColors.success
                      : _isProcessing
                          ? AppColors.accent
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _success ? AppColors.success : null,
                    ),
                  ),
                ),
                if (_success || _message.contains('Error'))
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Scan Again'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

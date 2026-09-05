import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/models/shift/shift.dart';
import 'package:gep/services/shifts/shifts_service.dart';
import 'package:gep/view/widgets/app_scaffold.dart';

class StudentDetailsScreen extends StatefulWidget {
  final EnrolledStudent student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  Shift? _shift;

  @override
  void initState() {
    super.initState();
    _loadShift();
  }

  Future<void> _loadShift() async {
    if (widget.student.shiftId == null || widget.student.shiftId!.isEmpty) {
      return;
    }
    try {
      final shift = await ShiftsService().getShift(widget.student.shiftId!);
      if (mounted) {
        setState(() => _shift = shift);
      }
    } catch (e) {
      debugPrint('Failed to load shift: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Student Details',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.student.name,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Email', widget.student.email),
                      _buildDetailRow('Level', widget.student.level),
                      _buildDetailRow(
                          'Date of Birth', _formatDate(widget.student.dateOfBirth)),
                      _buildDetailRow('Gender', widget.student.gender),
                      _buildDetailRow('Address', widget.student.address),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Contact Number', widget.student.contactNumber),
                      _buildDetailRow('Father\'s Name', widget.student.fatherName),
                      _buildDetailRow(
                          'Father\'s Contact', widget.student.fatherContactNumber),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enrollment Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Enrollment Date',
                          _formatDate(widget.student.enrollmentDate)),
                      _buildDetailRow(
                        'Assigned Shift',
                        _shift?.name ?? 'None',
                      ),
                      if (_shift != null)
                        _buildDetailRow(
                          'Shift Time',
                          _shift!.timeRange,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}

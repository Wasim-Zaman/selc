// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/admission_announcement.dart';
import 'package:selc/utils/snackbars.dart';

class AdminAdmissionsScreen extends StatelessWidget {
  const AdminAdmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminCubit = context.read<AdminCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Admissions', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(context, adminCubit),
          ),
        ],
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminSuccess) {
            TopSnackbar.success(context, state.message);
          } else if (state is AdminFailure) {
            TopSnackbar.error(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<AdmissionAnnouncement>>(
            stream: adminCubit.getAdmissionAnnouncementsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No announcements available'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return AnnouncementCard(
                    announcement: snapshot.data![index],
                    onEdit: () => _showAddEditDialog(
                      context,
                      adminCubit,
                      announcement: snapshot.data![index],
                    ),
                    onDelete: () => _deleteAnnouncement(
                      context,
                      adminCubit,
                      snapshot.data![index].id,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, AdminCubit adminCubit,
      {AdmissionAnnouncement? announcement}) {
    showDialog(
      context: context,
      builder: (context) => AddEditAnnouncementDialog(
        adminCubit: adminCubit,
        announcement: announcement,
      ),
    );
  }

  void _deleteAnnouncement(
      BuildContext context, AdminCubit adminCubit, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content:
            const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              adminCubit.deleteAdmissionAnnouncement(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final AdmissionAnnouncement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        title: Text(announcement.title),
        subtitle: Text(
            '${_formatDate(announcement.startDate)} - ${_formatDate(announcement.endDate)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AddEditAnnouncementDialog extends StatefulWidget {
  final AdminCubit adminCubit;
  final AdmissionAnnouncement? announcement;

  const AddEditAnnouncementDialog({
    super.key,
    required this.adminCubit,
    this.announcement,
  });

  @override
  _AddEditAnnouncementDialogState createState() =>
      _AddEditAnnouncementDialogState();
}

class _AddEditAnnouncementDialogState extends State<AddEditAnnouncementDialog> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title);
    _detailsController =
        TextEditingController(text: widget.announcement?.details);
    _startDate = widget.announcement?.startDate ?? DateTime.now();
    _endDate = widget.announcement?.endDate ??
        DateTime.now().add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.announcement == null
          ? 'Add Announcement'
          : 'Edit Announcement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, isStartDate: true),
                    child: Text('Start Date: ${_formatDate(_startDate)}'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, isStartDate: false),
                    child: Text('End Date: ${_formatDate(_endDate)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveAnnouncement,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveAnnouncement() {
    final announcement = AdmissionAnnouncement(
      id: widget.announcement?.id ?? '',
      title: _titleController.text,
      details: _detailsController.text,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (widget.announcement == null) {
      widget.adminCubit.addAdmissionAnnouncement(announcement);
    } else {
      widget.adminCubit.updateAdmissionAnnouncement(announcement);
    }

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
}

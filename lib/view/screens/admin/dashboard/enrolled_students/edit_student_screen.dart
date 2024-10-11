import 'package:flutter/material.dart';
import 'package:selc/models/enrolled_students.dart';
import 'package:selc/services/enrolled_students/enrolled_students_services.dart';
import 'package:intl/intl.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/view/widgets/text_field_widget.dart';
import 'package:selc/utils/snackbars.dart';

class EditStudentScreen extends StatefulWidget {
  final EnrolledStudent student;
  final EnrolledStudentsServices enrolledStudentsServices;

  const EditStudentScreen({
    super.key,
    required this.student,
    required this.enrolledStudentsServices,
  });

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _fatherNameController;
  late TextEditingController _levelController;
  late TextEditingController _contactNumberController;
  late TextEditingController _fatherContactNumberController;
  late TextEditingController _addressController;
  late DateTime _dateOfBirth;
  late String _gender;
  late DateTime _enrollmentDate;

  // Add these FocusNode declarations
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _fatherNameFocus = FocusNode();
  final _levelFocus = FocusNode();
  final _contactNumberFocus = FocusNode();
  final _fatherContactNumberFocus = FocusNode();
  final _addressFocus = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _emailController = TextEditingController(text: widget.student.email);
    _fatherNameController =
        TextEditingController(text: widget.student.fatherName);
    _levelController = TextEditingController(text: widget.student.level);
    _contactNumberController =
        TextEditingController(text: widget.student.contactNumber);
    _fatherContactNumberController =
        TextEditingController(text: widget.student.fatherContactNumber);
    _addressController = TextEditingController(text: widget.student.address);
    _dateOfBirth = widget.student.dateOfBirth;
    _gender = widget.student.gender;
    _enrollmentDate = widget.student.enrollmentDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.error),
            onPressed: _deleteStudent,
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFieldWidget(
                    controller: _nameController,
                    labelText: 'Name',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                    focusNode: _nameFocus,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_emailFocus),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _emailController,
                    labelText: 'Email',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter an email' : null,
                    focusNode: _emailFocus,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_fatherNameFocus),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _fatherNameController,
                    labelText: 'Father\'s Name',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter father\'s name' : null,
                    focusNode: _fatherNameFocus,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_levelFocus),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _levelController,
                    labelText: 'Level',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a level' : null,
                    focusNode: _levelFocus,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_contactNumberFocus),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _contactNumberController,
                    labelText: 'Contact Number',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a contact number' : null,
                    focusNode: _contactNumberFocus,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_fatherContactNumberFocus),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _fatherContactNumberController,
                    labelText: 'Father\'s Contact Number',
                    validator: (value) => value!.isEmpty
                        ? 'Please enter father\'s contact number'
                        : null,
                    focusNode: _fatherContactNumberFocus,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_addressFocus),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _addressController,
                    labelText: 'Address',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter an address' : null,
                    focusNode: _addressFocus,
                    onFieldSubmitted: (_) => _updateStudent(),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ListTile(
                    title: const Text('Date of Birth'),
                    subtitle:
                        Text(DateFormat('yyyy-MM-dd').format(_dateOfBirth)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _dateOfBirth,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _dateOfBirth = picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _gender = value!);
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ListTile(
                    title: const Text('Enrollment Date'),
                    subtitle:
                        Text(DateFormat('yyyy-MM-dd').format(_enrollmentDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _enrollmentDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _enrollmentDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding * 2),
                  ElevatedButton(
                    onPressed: _updateStudent,
                    child: const Text('Update Student'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _updateStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final updatedStudent = EnrolledStudent(
        id: widget.student.id,
        name: _nameController.text,
        email: _emailController.text,
        fatherName: _fatherNameController.text,
        level: _levelController.text,
        contactNumber: _contactNumberController.text,
        fatherContactNumber: _fatherContactNumberController.text,
        address: _addressController.text,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        enrollmentDate: _enrollmentDate,
      );

      try {
        await widget.enrolledStudentsServices.updateStudent(
          widget.student.id,
          updatedStudent,
        );
        TopSnackbar.success(context, "Student updated successfully");
        Navigator.pop(context, true);
      } catch (e) {
        TopSnackbar.error(context, "Failed to update student: ${e.toString()}");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      TopSnackbar.error(context, "Please fill all fields");
    }
  }

  void _deleteStudent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.enrolledStudentsServices.deleteStudent(widget.student.id);
        TopSnackbar.success(context, "Student deleted successfully");
        Navigator.of(context).pop(true); // Return true to indicate deletion
      } catch (e) {
        TopSnackbar.error(context, "Failed to delete student: ${e.toString()}");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _fatherNameController.dispose();
    _levelController.dispose();
    _contactNumberController.dispose();
    _fatherContactNumberController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _fatherNameFocus.dispose();
    _levelFocus.dispose();
    _contactNumberFocus.dispose();
    _fatherContactNumberFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }
}

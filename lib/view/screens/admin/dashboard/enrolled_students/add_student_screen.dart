// ignore_for_file: library_private_types_in_public_api, unused_local_variable, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selc/models/enrolled_students.dart';
import 'package:selc/services/enrolled_students/enrolled_students_services.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/widgets/placeholder_widget.dart';
import 'package:selc/view/widgets/text_field_widget.dart';

class AddStudentScreen extends StatefulWidget {
  final EnrolledStudentsServices enrolledStudentsServices;

  const AddStudentScreen({super.key, required this.enrolledStudentsServices});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _levelController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _fatherContactNumberController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime _dateOfBirth = DateTime.now();
  String _gender = 'Male';
  DateTime _enrollmentDate = DateTime.now();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Student')),
      body: _isLoading
          ? PlaceholderWidgets.addStudentScreenPlaceholder()
          : Form(
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
                      labelText: 'Email (Optional)',
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
                      labelText: 'Contact Number (Optional)',
                      focusNode: _contactNumberFocus,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_fatherContactNumberFocus),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    TextFieldWidget(
                      controller: _fatherContactNumberController,
                      labelText: 'Father\'s Contact Number (Optional)',
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
                      onFieldSubmitted: (_) => _addStudent(),
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
                      subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(_enrollmentDate)),
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
                      onPressed: _addStudent,
                      child: const Text('Add Student'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _addStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newStudent = EnrolledStudent(
        id: '',
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
        await widget.enrolledStudentsServices.addStudent(newStudent);
        TopSnackbar.success(context, "Student added successfully");
        Navigator.pop(context, true);
      } catch (e) {
        print('Error adding student: $e');
        TopSnackbar.error(context, "Failed to add student: ${e.toString()}");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      TopSnackbar.error(context, "Please fill all fields");
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

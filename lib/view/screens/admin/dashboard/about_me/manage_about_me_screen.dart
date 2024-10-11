import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/about_me.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/widgets/text_field_widget.dart';

class ManageAboutMeScreen extends StatefulWidget {
  const ManageAboutMeScreen({super.key});

  @override
  State<ManageAboutMeScreen> createState() => _ManageAboutMeScreenState();
}

class _ManageAboutMeScreenState extends State<ManageAboutMeScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImageFile;
  File? _resumeFile;
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _youtubeChannelController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage About Me',
            style: Theme.of(context).textTheme.headlineSmall),
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
          return StreamBuilder<AboutMe>(
            stream: context.read<AdminCubit>().getAboutMeStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final aboutMe = snapshot.data ?? AboutMe();
              _latitudeController.text = aboutMe.latitude.toString();
              _longitudeController.text = aboutMe.longitude.toString();
              _youtubeChannelController.text = aboutMe.youtubeChannelLink;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileImageSection(aboutMe),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: _latitudeController,
                        labelText: 'Latitude',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: _longitudeController,
                        labelText: 'Longitude',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: _youtubeChannelController,
                        labelText: 'YouTube Channel Link',
                      ),
                      const SizedBox(height: 16),
                      _buildResumeSection(aboutMe),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _saveAboutMe(context),
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileImageSection(AboutMe aboutMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile Picture', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_profileImageFile != null || aboutMe.profileImageUrl != null)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _profileImageFile != null
                    ? FileImage(_profileImageFile!) as ImageProvider
                    : NetworkImage(aboutMe.profileImageUrl!),
              ),
            ),
          ),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Pick Image'),
        ),
      ],
    );
  }

  Widget _buildResumeSection(AboutMe aboutMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resume', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_resumeFile != null || aboutMe.resumeUrl != null)
          Text(_resumeFile != null ? 'New resume selected' : 'Resume uploaded'),
        ElevatedButton(
          onPressed: _pickResume,
          child: const Text('Pick Resume'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
      });
    }
  }

  void _saveAboutMe(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final aboutMe = AboutMe(
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        youtubeChannelLink: _youtubeChannelController.text,
      );
      context.read<AdminCubit>().updateAboutMe(
            aboutMe,
            profileImage: _profileImageFile,
            resume: _resumeFile,
          );
    }
  }
}

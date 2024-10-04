import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/screens/admin/dashboard/notes/add_notes_screen.dart';
import 'package:selc/view/widgets/placeholder_widget.dart';
import 'package:selc/view/widgets/text_field_widget.dart';

class AdminNotesCategoriesScreen extends StatelessWidget {
  AdminNotesCategoriesScreen({super.key});

  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Note Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFieldWidget(
                    controller: _categoryController,
                    labelText: 'Enter new category',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_categoryController.text.isNotEmpty) {
                      context
                          .read<AdminCubit>()
                          .addCategory(_categoryController.text);
                      _categoryController.clear();
                    } else {
                      TopSnackbar.info(context, 'Please enter a category name');
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: context.read<AdminCubit>().getCategoriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return PlaceholderWidgets.listPlaceholder();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => context
                            .read<AdminCubit>()
                            .deleteCategory(snapshot.data![index]),
                      ),
                      onTap: () => Navigations.push(
                        context,
                        AddNotesScreen(category: snapshot.data![index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

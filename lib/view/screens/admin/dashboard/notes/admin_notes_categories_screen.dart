import 'package:flutter/material.dart';
import 'package:selc/services/notes/notes_service.dart';

class AdminNotesCategoriesScreen extends StatefulWidget {
  const AdminNotesCategoriesScreen({super.key});

  @override
  State<AdminNotesCategoriesScreen> createState() =>
      _AdminNotesCategoriesScreenState();
}

class _AdminNotesCategoriesScreenState
    extends State<AdminNotesCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final NotesService _notesService = NotesService();

  void _addCategory() async {
    if (_categoryController.text.isNotEmpty) {
      await _notesService.addCategory(_categoryController.text);
      _categoryController.clear();
    }
  }

  void _deleteCategory(String category) async {
    await _notesService.deleteCategory(category);
  }

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
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      hintText: 'Enter new category',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _notesService.getCategoriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                        onPressed: () => _deleteCategory(snapshot.data![index]),
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

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}

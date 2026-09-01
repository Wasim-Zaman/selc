import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:gep/models/updates.dart';
import 'package:gep/services/updates/updates_services.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/app_scaffold.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'English Course Updates',
      body: StreamBuilder<List<Updates>>(
        stream: UpdatesServices().getUpdatesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PlaceholderWidgets.listPlaceholder(itemCount: 5);
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No updates available'));
          }

          final updates = snapshot.data!;

          return ListView.builder(
            itemCount: updates.length,
            itemBuilder: (context, index) {
              final update = updates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: Text(update.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(update.description),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(update.date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

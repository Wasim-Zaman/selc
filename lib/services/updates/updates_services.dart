import 'package:gep/models/updates.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatesServices {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'updates';

  Stream<List<Updates>> getUpdatesStream() {
    return _supabase.from(_table).stream(primaryKey: ['id']).map((rows) {
      final updates = rows
          .map((row) => Updates.fromMap(row, row['id'] as String))
          .toList();
      updates.sort((a, b) => b.date.compareTo(a.date));
      return updates;
    });
  }

  Future<void> addUpdate(Updates update) async {
    await _supabase.from(_table).insert(update.toMap());
  }

  Future<void> updateUpdate(String updateId, Updates update) async {
    await _supabase.from(_table).update(update.toMap()).eq('id', updateId);
  }

  Future<void> deleteUpdate(String updateId) async {
    await _supabase.from(_table).delete().eq('id', updateId);
  }
}

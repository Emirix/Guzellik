import '../models/notification_model.dart';
import '../services/supabase_service.dart';

class NotificationRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<NotificationModel>> getNotifications() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> markAllAsRead() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> deleteNotification(String id) async {
    await _supabase.from('notifications').delete().eq('id', id);
  }

  Stream<List<NotificationModel>> getNotificationsStream() {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map(
          (data) =>
              data.map((json) => NotificationModel.fromJson(json)).toList(),
        );
  }
}

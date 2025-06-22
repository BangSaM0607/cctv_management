import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> insertLog(String action, String cctvId, String message) async {
  await Supabase.instance.client.from('logs').insert({
    'action': action,
    'cctv_id': cctvId,
    'message': message,
    'user_id': Supabase.instance.client.auth.currentUser?.id,
  });
}

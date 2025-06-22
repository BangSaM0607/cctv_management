import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> insertLog({
  required String action,
  required String message,
  required String timestamp,
}) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  await supabase.from('logs').insert({
    'user_id': user?.id,
    'user_email': user?.email,
    'action': action,
    'message': message,
  });
}

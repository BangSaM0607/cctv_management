import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> insertLog({
  required String action,
  required String message,
}) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  final email = user?.email ?? '';

  await supabase.from('logs').insert({
    'action': action,
    'message': message,
    'user_email': email,
  });
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> logs = [];

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    final response = await supabase
        .from('logs')
        .select('id, action, message, inserted_at')
        .order('inserted_at', ascending: false);

    setState(() {
      logs = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Log')),
      body:
          logs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final action = log['action'] ?? '';
                  final message = log['message'] ?? '';
                  final insertedAt =
                      log['inserted_at']?.toString().substring(0, 19) ?? '';

                  IconData icon = Icons.info;
                  Color color = Colors.grey;

                  if (action == 'insert') {
                    icon = Icons.add_circle;
                    color = Colors.green;
                  } else if (action == 'update') {
                    icon = Icons.edit;
                    color = Colors.blue;
                  } else if (action == 'delete') {
                    icon = Icons.delete;
                    color = Colors.red;
                  }

                  return ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(message),
                    subtitle: Text('Waktu: $insertedAt'),
                  );
                },
              ),
    );
  }
}

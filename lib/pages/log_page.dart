// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> logList = [];

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    final response = await supabase
        .from('logs')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    setState(() {
      logList = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Log')),
      body:
          logList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: logList.length,
                itemBuilder: (context, index) {
                  final log = logList[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('${log['action']} - ${log['message']}'),
                    subtitle: Text(
                      'User: ${log['user_email'] ?? '-'}\n${log['created_at'] ?? ''}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
    );
  }
}

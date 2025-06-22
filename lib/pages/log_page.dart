import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/drawer_menu.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    setState(() {
      isLoading = true;
    });

    final response = await supabase
        .from('logs')
        .select()
        .order('created_at', ascending: false)
        .limit(100);

    setState(() {
      logs = response;
      isLoading = false;
    });
  }

  String formatDateTime(String dateTimeStr) {
    final dt = DateTime.parse(dateTimeStr).toLocal();
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Log'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchLogs),
        ],
      ),
      drawer: const DrawerMenu(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : logs.isEmpty
              ? const Center(child: Text('Belum ada log'))
              : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final userEmail = log['user_email'] ?? '-';
                  final action = log['action'] ?? '';
                  final message = log['message'] ?? '';
                  final createdAt = formatDateTime(log['created_at']);

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        action == 'add'
                            ? Icons.add
                            : action == 'edit'
                            ? Icons.edit
                            : action == 'delete'
                            ? Icons.delete
                            : Icons.info,
                        color:
                            action == 'delete'
                                ? Colors.red
                                : action == 'edit'
                                ? Colors.orange
                                : Colors.green,
                      ),
                      title: Text('$action • $createdAt'),
                      subtitle: Text('$message\n$userEmail'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
    );
  }
}

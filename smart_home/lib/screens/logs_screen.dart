import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_home/services/api_service.dart';
import 'package:animate_do/animate_do.dart'; // این پکیج را import کنید

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final logs = await ApiService.getLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _fetchLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          // هر آیتم را با انیمیشن نمایش می‌دهیم
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(log['message']),
                subtitle: Text(
                    '${DateTime.fromMillisecondsSinceEpoch(
                        log['timestamp'] * 1000)}'),
                trailing: _getLogLevelIcon(log['level']),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _getLogLevelIcon(String level) {
    switch (level) {
      case 'INFO':
        return const Icon(Iconsax.info_circle, color: Colors.blue);
      case 'WARNING':
        return const Icon(Iconsax.warning_2, color: Colors.orange);
      case 'ERROR':
        return const Icon(Iconsax.danger, color: Colors.red);
      default:
        return const Icon(Iconsax.message_question);
    }
  }
}
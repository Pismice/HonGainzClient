import 'package:flutter/material.dart';
import 'session_list.dart';
import 'new_session_page.dart';

class SessionManagementPage extends StatefulWidget {
  const SessionManagementPage({super.key});

  @override
  State<SessionManagementPage> createState() => _SessionManagementPageState();
}

class _SessionManagementPageState extends State<SessionManagementPage> {
  final GlobalKey<SessionListState> _sessionListKey = GlobalKey();

  void _navigateToNewSessionPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewSessionPage(),
      ),
    );

    if (result == true) {
      // Refresh the SessionList when a new session is created
      _sessionListKey.currentState?.refreshSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage sessions"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SessionList(key: _sessionListKey), // Pass the key
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 100, // Increase the width of the button
        height: 100, // Increase the height of the button
        child: FloatingActionButton(
          onPressed: _navigateToNewSessionPage,
          backgroundColor: Colors.green, // Make the button green
          child: const Icon(
            Icons.add,
            size: 50, // Adjust the icon size
          ),
        ),
      ),
    );
  }
}

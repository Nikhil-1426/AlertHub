import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAlertsPage extends StatefulWidget {
  @override
  _AdminAlertsPageState createState() => _AdminAlertsPageState();
}

class _AdminAlertsPageState extends State<AdminAlertsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _alertTitleController = TextEditingController();
  final TextEditingController _alertDescriptionController = TextEditingController();

  Future<void> _sendAlert() async {
    String title = _alertTitleController.text.trim();
    String description = _alertDescriptionController.text.trim();
    if (title.isNotEmpty && description.isNotEmpty) {
      await _firestore.collection('alerts').add({
        'title': title,
        'description': description,
        'timestamp': Timestamp.now(),
      });
      _alertTitleController.clear();
      _alertDescriptionController.clear();
    }
  }

  Stream<QuerySnapshot> _getAlerts() {
    return _firestore.collection('alerts').orderBy('timestamp').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send an Alert'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _alertTitleController,
              decoration: InputDecoration(labelText: 'Alert Title'),
            ),
            TextField(
              controller: _alertDescriptionController,
              decoration: InputDecoration(labelText: 'Alert Description'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendAlert,
              child: Text('Send Alert'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getAlerts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var items = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var data = items[index].data() as Map<String, dynamic>;
                      String title = data['title'] ?? 'No Title';
                      String description = data['description'] ?? 'No Description';

                      return ListTile(
                        title: Text(title),
                        subtitle: Text(description),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

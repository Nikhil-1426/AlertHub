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
        title: Text('Send an Alert', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent, // Ensure consistency with other pages
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _alertTitleController,
              decoration: InputDecoration(
                labelText: 'Alert Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners to match the other page
                ),
                filled: true,
                fillColor: Colors.grey[200], // Light grey background for consistency
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _alertDescriptionController,
              decoration: InputDecoration(
                labelText: 'Alert Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners to match
                ),
                filled: true,
                fillColor: Colors.grey[200], // Light grey background for consistency
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button color to match
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners for consistency
                ),
              ),
              child: Text('Send Alert', style: TextStyle(color: Colors.white)),
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
                    padding: EdgeInsets.all(16.0), // Consistent padding
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var data = items[index].data() as Map<String, dynamic>;
                      String title = data['title'] ?? 'No Title';
                      String description = data['description'] ?? 'No Description';

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          tileColor: Colors.blue[50], // Light blue background for consistency
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 73, 145, 167), // Text color consistent with other page
                            ),
                          ),
                          subtitle: Text(description),
                        ),
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

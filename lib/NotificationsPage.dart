import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getAlerts() {
    return _firestore.collection('alerts').orderBy('timestamp').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getAlerts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var alerts = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0), // Consistent padding
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              var alertData = alerts[index].data() as Map<String, dynamic>;
              String title = alertData['title'] ?? 'No Title';
              String description = alertData['description'] ?? 'No Description';

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  tileColor: Colors.blue[50], // Light blue background for notifications
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 73, 145, 167), // Consistent blue text color
                    ),
                  ),
                  subtitle: Text(description),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

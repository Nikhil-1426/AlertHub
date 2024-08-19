import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHelpRequestsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getHelpRequests() {
    return _firestore.collection('help_requests').orderBy('timestamp').snapshots();
  }

  Future<Map<String, String>> _getUserDetails(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      String email = userDoc['email'] ?? 'Unknown email';
      String name = userDoc['name'] ?? 'Unknown name';
      return {'email': email, 'name': name};
    } else {
      return {'email': 'Unknown email', 'name': 'Unknown name'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help Requests',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent, // Consistent color with AdminAlertsPage
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Consistent padding with AdminAlertsPage
        child: StreamBuilder<QuerySnapshot>(
          stream: _getHelpRequests(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var requests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var requestData = requests[index];
                String userId = requestData['userId'];
                String description = requestData['description'];

                return FutureBuilder<Map<String, String>>(
                  future: _getUserDetails(userId),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[50], // Consistent background with AdminAlertsPage
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            'Loading...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 73, 145, 167), // Consistent text color
                            ),
                          ),
                          subtitle: Text('Loading...'),
                        ),
                      );
                    }

                    String email = userSnapshot.data!['email']!;
                    String name = userSnapshot.data!['name']!;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50], // Consistent background with AdminAlertsPage
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0), // Consistent padding
                        title: Text(
                          '$name ($email)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 73, 145, 167), // Consistent text color
                          ),
                        ),
                        subtitle: Text(description),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

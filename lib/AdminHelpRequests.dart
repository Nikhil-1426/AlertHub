import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHelpRequestsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getHelpRequests() {
    return _firestore.collection('help_requests').orderBy('timestamp').snapshots();
  }

  Future<String> _getUserEmail(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc['email'] ?? 'Unknown sender';
    } else {
      return 'Unknown sender';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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

              return FutureBuilder<String>(
                future: _getUserEmail(userId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text('Loading...'),
                    );
                  }

                  return ListTile(
                    title: Text(userSnapshot.data!),
                    subtitle: Text(description),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelpRequestPage extends StatefulWidget {
  @override
  _HelpRequestPageState createState() => _HelpRequestPageState();
}

class _HelpRequestPageState extends State<HelpRequestPage> {
  final TextEditingController _helpDescriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _sendHelpRequest() async {
    String description = _helpDescriptionController.text.trim();
    if (description.isNotEmpty) {
      await _firestore.collection('help_requests').add({
        'userId': _user!.uid,
        'description': description,
        'timestamp': Timestamp.now(),
      });
      _helpDescriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Request', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _helpDescriptionController,
              decoration: InputDecoration(
                hintText: 'Enter help request description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 4, // Adjust the height of the text field
            ),
            SizedBox(height: 18.0),
            ElevatedButton(
              onPressed: _sendHelpRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text('Submit Help Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserName;

  void initState() {
    super.initState();
    _getCurrentUserName();
  }

  Future<void> _getCurrentUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _currentUserName = userDoc['name'];
      });
    }
  }

  Stream<QuerySnapshot> _getMessages() {
    return _firestore.collection('chats').orderBy('timestamp').snapshots();
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('chats').add({
        'message': _messageController.text,
        'senderId': _currentUserName, // Replace with the actual sender's ID
        'timestamp': Timestamp.now(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.blueAccent, // Blue themed AppBar
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var items = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // To show the latest messages at the bottom
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var data = items[index].data() as Map<String, dynamic>;
                    String message = data['message'] ?? 'No Message';
                    String senderId = data['senderId'] ?? 'Unknown Sender';

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      tileColor: Colors.blue[50], // Light blue background for messages
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      title: Text(
                        senderId,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 130, 196, 216)), // Blue text
                      ),
                      subtitle: Text(message),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), // Rounded corners
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Blue button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    ),
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

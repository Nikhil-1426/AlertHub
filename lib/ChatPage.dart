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

  @override
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

  List<String> _fragmentMessage(String message, int packetSize) {
    if (message.length <= packetSize) {
      return [message];
    }
    List<String> packets = [];
    for (int i = 0; i < message.length; i += packetSize) {
      packets.add(message.substring(i, (i + packetSize < message.length) ? i + packetSize : message.length));
    }
    return packets;
  }

  String _reassembleMessage(List<String> packets) {
    return packets.join('');
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      List<String> packets = _fragmentMessage(_messageController.text, 50); // Fragment message into packets
      String messageId = DateTime.now().millisecondsSinceEpoch.toString(); // Unique message ID based on timestamp

      for (int i = 0; i < packets.length; i++) {
        await _firestore.collection('chats').add({
          'message': packets[i],
          'senderId': _currentUserName,
          'timestamp': Timestamp.now(),
          'packetIndex': i,
          'totalPackets': packets.length,
          'messageId': messageId, // Unique message ID
        });
      }
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
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

                // Group packets by message and sender
                Map<String, Map<String, List<String>>> messages = {};
                for (var item in items) {
                  var data = item.data() as Map<String, dynamic>;
                  String message = data['message'] ?? 'No Message';
                  String senderId = data['senderId'] ?? 'Unknown Sender';
                  int packetIndex = data['packetIndex'] ?? 0;
                  int totalPackets = data['totalPackets'] ?? 1;
                  String messageId = data['messageId'] ?? '';

                  if (!messages.containsKey(messageId)) {
                    messages[messageId] = {};
                  }

                  if (!messages[messageId]!.containsKey(senderId)) {
                    messages[messageId]![senderId] = List<String>.filled(totalPackets, '', growable: false);
                  }
                  
                  messages[messageId]![senderId]![packetIndex] = message;

                  // Reassemble message if all packets are received
                  if (messages[messageId]![senderId]!.where((packet) => packet.isNotEmpty).length == totalPackets) {
                    messages[messageId]![senderId] = [ _reassembleMessage(messages[messageId]![senderId]!) ];
                  }
                }

                List<Widget> messageWidgets = [];
                messages.forEach((messageId, senders) {
                  senders.forEach((senderId, messages) {
                    messageWidgets.addAll(messages.map((message) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        tileColor: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        title: Text(
                          senderId,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 73, 145, 167)),
                        ),
                        subtitle: Text(message),
                      );
                    }).toList());
                  });
                });

                return ListView(
                  reverse: true,
                  children: messageWidgets,
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
                        borderRadius: BorderRadius.circular(30.0),
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
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
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

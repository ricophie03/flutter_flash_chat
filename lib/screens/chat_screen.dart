import 'package:flutter/material.dart';
import 'package:flutter_flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
User? loggedInUser;
int _idNum = 0;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageFieldController = TextEditingController();
  String messageText = '';

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessagesStream() async {
    var stream = await _firestore.collection('messages').snapshots();
    await for (var snapshot in stream) {
      for (var messages in snapshot.docs) {
        print(messages.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          // Log out (x) button
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    // TextField : Send Messages
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: messageFieldController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      final send = _firestore.collection('messages');
                      send.doc('chat$_idNum').set({
                        'message_text': messageText,
                        'sender': loggedInUser!.email,
                        'time': DateTime.now(),
                        'id': 'chat$_idNum',
                      });
                      setState(() {
                        messageText = '';
                      });
                      _idNum += 1;
                      messageFieldController.clear();
                      // messages + sender name
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// cara mengambil dan menampilkan data firebase secara realtime
class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .orderBy('time', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final messageText =
              (message.data() as Map<String, dynamic>)['message_text'];
          final messageSender =
              (message.data() as Map<String, dynamic>)['sender'];
          final messageTime = (message.data() as Map<String, dynamic>)['time'];
          final messageID = (message.data() as Map<String, dynamic>)['id'];

          final currentUser = loggedInUser!.email;
          final messageBubbles = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser == messageSender,
            timestamp: messageTime!,
            id: messageID,
          );
          messageWidgets.add(messageBubbles);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            children: messageWidgets,
            reverse: true,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? sender;
  final String? text;
  final Timestamp? timestamp;
  final bool? isMe;
  final String? id;

  MessageBubble({this.text, this.sender, this.isMe, this.timestamp, this.id});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        final collection = _firestore.collection('messages');
        collection
            .doc('$id')
            .delete() // <-- Delete
            .catchError((error) => print('Delete failed: $error'));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment:
              isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender ?? '',
              style: TextStyle(fontSize: 12.0, color: Colors.black54),
            ),
            Material(
              borderRadius: BorderRadius.only(
                  topLeft: isMe == true ? Radius.circular(20.0) : Radius.zero,
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                  topRight: isMe == true ? Radius.zero : Radius.circular(20.0)),
              elevation: 5.0,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      '$text',
                      style: TextStyle(
                          fontSize: 15.0,
                          color: isMe == true ? Colors.white : Colors.black54),
                    ),
                    Text(
                      '${timestamp!.toDate().hour.toString().padLeft(2, '0')}:${timestamp!.toDate().minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: isMe == true ? Colors.white : Colors.black54),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
              color: isMe == true ? Colors.lightBlueAccent : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

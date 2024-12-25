import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _messageController= TextEditingController();

  void dispose(){
    _messageController.dispose();
    super.dispose();
  }

  void _sumbitMessage() async {
    
    
    final enteredmessage= _messageController.text;

    if(enteredmessage.trim().isEmpty){
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();
    // send toFirebase
    final user =FirebaseAuth.instance.currentUser!;
    final userData =await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'text':enteredmessage,
      'timestamp':Timestamp.now(),
      'userid':user.uid,
      'username': userData.data()!['username'] ,
      'userimage': userData.data()!['image_url'],

    });
    

  }
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(
      left: 15, right: 1,bottom: 15,
    ),
    child: Row(
      children: [
        Expanded(child: 
        TextField(
          controller: _messageController,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          enableSuggestions: true,
          decoration: const InputDecoration(labelText: 'Send a message....'),
        ),
        ),
        IconButton(onPressed: _sumbitMessage, icon: Icon(Icons.send),
        color: Theme.of(context).colorScheme.primary,),
      ],
    ),
    );
  }
}
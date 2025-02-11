import 'package:chatapp/widegets/chat_msg.dart';
import 'package:chatapp/widegets/new_msg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter chat'),
        actions: [
          IconButton(
            onPressed: (){
            FirebaseAuth.instance.signOut();
            }, 
          icon: Icon(Icons.exit_to_app,color: Theme.of(context).colorScheme.primary,))
        ],
      ),
      body: const Column(
        children: [
          Expanded(child:ChatMessages() )
          ,
          NewMessages(),
        ],
      ),
    );
  }
}
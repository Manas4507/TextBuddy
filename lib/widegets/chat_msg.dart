import 'package:chatapp/widegets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {

    final authenticatedUser =FirebaseAuth.instance.currentUser!;
    return StreamBuilder(stream: FirebaseFirestore.instance.collection('chat').
    orderBy(
      'timestamp',
      descending: true,
    ).snapshots(), 
    builder: (ctx,chatSnapshots){
      if(chatSnapshots.connectionState== ConnectionState.waiting){
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
        if(!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty){
          return const Center(child: Text('No messages found'),);

        }
      if(chatSnapshots.hasError){
        return const Center(child: Text('Something went wrong'),);
      }
      final loadedMeassages =chatSnapshots.data!.docs;
      return ListView.builder(
        padding: const  EdgeInsets.only(
          bottom: 40,left: 13,right: 13
        ),
        reverse: true,itemCount: loadedMeassages.length,itemBuilder: (ctx,index){
          final ChatMessage =loadedMeassages[index].data();
          final nextChatMessage = index+1 <loadedMeassages.length ? loadedMeassages[index+1].data():null;

          final currentMessagUsernameId =ChatMessage['userid'];
          final nextMessageUsernameId =nextChatMessage != null? nextChatMessage['userid'] : null; 

          final nextUserIsSame = nextMessageUsernameId== currentMessagUsernameId;

          if(nextUserIsSame){
            return MessageBubble.next(message: ChatMessage['text'], isMe: authenticatedUser.uid ==currentMessagUsernameId);
          }else{
            return MessageBubble.first(
              userImage: ChatMessage['userimage'],
               username: ChatMessage['username'],
                message: ChatMessage['text'],
                 isMe: authenticatedUser.uid == currentMessagUsernameId);
          }
        }
    );
    },
    );
    
    
  }
}
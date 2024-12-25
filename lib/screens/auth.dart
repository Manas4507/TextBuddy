import 'package:chatapp/widegets/user_img_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
final _firebase=FirebaseAuth.instance;
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  var _enteredEmail='';
  var _enteredPassword='';
  var _enteredUsername='';
  File? _selectedImage;
  final _formkey=GlobalKey<FormState>();
  var _isLogin = true;
  var _isAuthenticating=false;
  

  void _sumbit()async{
    final isValid =_formkey.currentState!.validate();

    if(!isValid){
      return;
    }

    if(!_isLogin && _selectedImage== null){
      return;
    }
      _formkey.currentState!.save();
      
     try{
      setState(() {
        _isAuthenticating=true;
      });
      if(_isLogin){
        //login
        final userCredentials=await _firebase.signInWithEmailAndPassword(email: _enteredEmail , password: _enteredPassword);
         
      }else{        
        final userCredentials=await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
          
         final  storageRef = FirebaseStorage.instance.ref().child('user_images').child('${userCredentials.user!.uid}.jpg');
         await storageRef.putFile(_selectedImage!);
         final imageUrl = await storageRef.getDownloadURL();
        //  print(imageUrl);
       await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).
        set({
          'username':_enteredUsername,
           'email':_enteredEmail,
          //  'password':_enteredPassword,
          'image_url':imageUrl,
          }
          );

      }
      }on FirebaseAuthException catch (error){
        if (error.code == 'email-already-in-use'){
          //..
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Authentication fail')));
        setState(() {
          _isAuthenticating=false;
        });
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assests/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(30),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(!_isLogin) UserImagePicker(onPickImage: (pickedImage) {
                            _selectedImage=pickedImage;
                          },),

                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',

                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if( value == null || value.trim().isEmpty || !value.contains('@') ){
                                return 'Abe laude sahi daal';
                              }
                              return null;
                            } ,onSaved: (value){
                              _enteredEmail=value!;
                            },
                          ),
                          if(!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Username'),
                              validator: (value){
                                if(value == null||
                                value.isEmpty||
                                value.trim().length<4){
                                  return 'Enter at least 4 charcater';
                                }
                                return null;
                              },
                              onSaved: (value){
                                _enteredUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',

                            ),
                              obscureText: true,

                            validator: (value) {
                              if( value == null || value.trim().length <6  ){
                                return '6 character se bada bana';
                              }
                              return null;
                            },
                            onSaved: (value){
                              _enteredPassword=value!;
                            },
                          ),
                          const SizedBox(height: 12,),
                          // if(!_isAuthenticating)
                          // const CircularProgressIndicator(),
                          // if(!_isAuthenticating)
                          ElevatedButton(onPressed: _sumbit, child: Text(_isLogin?'Login':'Signup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          ),
                          // if(!_isAuthenticating)                          
                          TextButton(
                          onPressed: (){
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          }, 
                          child: Text(_isLogin ?'Create an account':'I already have an account')
                          ),
                        ],
                      )
                    ),
                    
                    ),
                ),

              )
            ],
          ),
        ),
      ),
    );
  }
}
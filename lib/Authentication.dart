import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signin;
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:mydrive/home.dart';
import 'package:mydrive/main.dart';

class Authentication{
  signin.GoogleSignIn googleSignIn = signin.GoogleSignIn.standard(scopes: [drive.DriveApi.DriveScope]);
  Map<String, String> headers;
  bool state = false;

  signin.GoogleSignInAccount getCurrentUser(){
   return googleSignIn.currentUser; 
  }

  Future<bool> setHeaders() async{
   headers = await getCurrentUser().authHeaders;
   if(headers == null)
   {
      return false;
   }
  else{
      return true;
  }
  }

  listenStatusChange(func){
    googleSignIn.onCurrentUserChanged.listen((event) => func(event));
  }
  
  Future<bool> login() async{
    await googleSignIn.signIn();
    state = await googleSignIn.isSignedIn();
    return state;
  }

  Future<bool> silentLogin() async{
    signin.GoogleSignInAccount account = await googleSignIn.signInSilently();
    if(account != null)
      return true;
    else
      return false;
  }

  Future<signin.GoogleSignInAccount> logout() {
    prefs.setBool("auth", false);
    state = false;
    return googleSignIn.signOut();
    

    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()),);
  }
}
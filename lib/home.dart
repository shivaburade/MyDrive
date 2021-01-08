import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:mydrive/main.dart';
import './Authentication.dart' as auth;
import './GoogleDriveClient.dart';
import './GoogleAuthClient.dart';
import 'package:file_picker/file_picker.dart';

class Home extends StatefulWidget {
  auth.Authentication  googleAuth;
  
  Home(this.googleAuth);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleDriveClient driveClient;
  bool isLoading = false;
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    var currentUser = widget.googleAuth.getCurrentUser();
    driveClient = GoogleDriveClient(widget.googleAuth.headers);
    print(currentUser);
  }

  void test() async{
    final authenticateClient = GoogleAuthClient(widget.googleAuth.headers);
    final driveApi = drive.DriveApi(authenticateClient);
    final Stream<List<int>> mediaStream = Future.value([104, 105]).asStream();
    var media = new drive.Media(mediaStream, 2);
    var driveFile = new drive.File();
    driveFile.name = "hello_world.txt";
    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");
  }

  Widget getIcon(String mimiType){
      
      if(mimiType.contains("pdf")){
        return CircleAvatar(
          child: Icon(Icons.picture_as_pdf),
          foregroundColor: Colors.red,
        );
      }

      if(mimiType.contains("image")){
        return CircleAvatar(
          child: Icon(Icons.insert_photo),
          foregroundColor: Colors.red,
        );
      }

      if(mimiType.contains("video")){
        return CircleAvatar(
          child: Icon(Icons.ondemand_video),
          foregroundColor: Colors.red,
        );
      }

      if(mimiType.contains("folder")){
        return CircleAvatar(
          child: Icon(Icons.folder)
        );
      }

      return CircleAvatar(
          child: Icon(Icons.insert_drive_file)
      );


  }

  showAlertDialog(BuildContext context, String fileId) {

  // set up the button
  Widget confirmButton = FlatButton(
    child: Text("Confirm"),
    onPressed: () {
      Navigator.of(context).pop();
      toggleLoading();
      driveClient.deleteFile(fileId).then((value){
                                  print(value);
                                  toggleLoading();
                            }, onError: (error){
                              if(error is drive.DetailedApiRequestError){
                                  print(error.status);
                                  print(error.message);
                              }
     });
    });

    Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
     },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Delete"),
    content: Text("Do you want to delete this?"),
    actions: [
      cancelButton,
      confirmButton
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
toggleLoading(){
  setState(() {
      isLoading = !isLoading;
  });
}

formatBytes(num bytes) {
    var marker = 1024; // Change to 1000 if required
    var decimal = 3; // Change as required
    var kiloBytes = marker; // One Kilobyte is 1024 bytes
    var megaBytes = marker * marker; // One MB is 1024 KB
    var gigaBytes = marker * marker * marker; // One GB is 1024 MB
    var teraBytes = marker * marker * marker * marker; // One TB is 1024 GB

    // return bytes if less than a KB
    if(bytes < kiloBytes) return bytes.toString() + " Bytes";
    // return KB if less than a MB
    else if(bytes < megaBytes) return(bytes / kiloBytes).toStringAsFixed(2) + " KB";
    // return MB if less than a GB
    else if(bytes < gigaBytes) return(bytes / megaBytes).toStringAsFixed(2) + " MB";
    // return GB if less than a TB
    else return(bytes / gigaBytes).toStringAsFixed(2) + " GB";
}

buildFutureBuilder(){
  return FutureBuilder(
                future: driveClient.getAllFiles(),
                builder: (BuildContext context, AsyncSnapshot<drive.FileList> data){
                  if(data.hasError){
                    print(data.error);
                  }
                    if(data.hasData){
                      drive.FileList fileList = data.data;

                      List<Widget> widget_arr = [];
                      for(var i =0; i<fileList.files.length; i++){
                        print(fileList.files[i].toString());
                        widget_arr.add(ListTile(
                          leading: getIcon(fileList.files[i].mimeType),
                          title: Text(fileList.files[i].name),
                          
                          subtitle: Text(fileList.files[i].size != null ? formatBytes(num.parse(fileList.files[i].size)) : "NA"),
                          trailing: IconButton(icon: Icon(Icons.delete),color: Colors.red, onPressed: () => showAlertDialog(context, fileList.files[i].id))
                        ));
                      }
                    
                      return Expanded(child: ListView(children: widget_arr),) ;
                    }else{
                      return Center(child: CircularProgressIndicator(value: null,));
                    }

              });
}

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("My Drive"),
          FlatButton(onPressed: (){
              widget.googleAuth.logout().then((account) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()),);
              });
          }, child: Text("Logout", style: TextStyle(color: Colors.white),))
        ],
      ),
      ),
      body: Column(
          children: [
              /* RaisedButton(onPressed: () {
                  widget.googleAuth.logout().then((account) {
                  //    print(account);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()),);
                  });
              } , child: Text("Logout"),), */
              isLoading ? Center(child: CircularProgressIndicator(value: null,)) : buildFutureBuilder()
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            FilePickerResult result = await FilePicker.platform.pickFiles();
            if(result.files != null){
            
            File file = File(result.files.single.path);      
            toggleLoading();
            driveClient.uploadFile(file.openRead(), result.files.single.size, result.files.single.name).then((drive.File file){
                //print(file);
                toggleLoading();
            });
            }
           
           /*
            toggleLoading();
            driveClient.uploadTestFile().then((drive.File file){
                toggleLoading();
            });
            */
            }, 
          child: Icon(Icons.add),)
    );
  }
}
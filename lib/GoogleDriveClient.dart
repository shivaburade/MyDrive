import './GoogleAuthClient.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveClient{

  drive.DriveApi _driveApi; 

  GoogleDriveClient(Map<String, String> authHeaders){
    print(authHeaders);
    _driveApi = drive.DriveApi(GoogleAuthClient(authHeaders));
  }

  Future<drive.File> uploadTestFile(){
    final Stream<List<int>> mediaStream = Future.value([104, 105]).asStream();
    var media = new drive.Media(mediaStream, 2);
    var driveFile = new drive.File();
    driveFile.name = "hello_world.txt";
    return _driveApi.files.create(driveFile, uploadMedia: media);
  }

  Future<drive.File> uploadFile(Stream<List<int>> mediaStream, int size, String filename) async{
    
    var media = new drive.Media(mediaStream, size);
    var driveFile = new drive.File();
    driveFile.name = filename;
    return _driveApi.files.create(driveFile, uploadMedia: media);
  }

  Future<drive.FileList> getAllFiles() {
      return _driveApi.files.list(includeItemsFromAllDrives: true, supportsAllDrives: true ,$fields: "*");
  }

  Future<dynamic> deleteFile(String fileId){
    return _driveApi.files.delete(fileId);
  }


}
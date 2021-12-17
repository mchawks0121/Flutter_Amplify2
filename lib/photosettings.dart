import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as path;
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:package_info/package_info.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Photosettings extends StatefulWidget {
  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<Photosettings> {
  bool _isEnabled = false;
  var user = "";
  File? imagefile;
  File? getimage;
  late String name = "";
  var _getUrlResult;

  @override
  void initState() {
    super.initState();
    _currentuser();
    getUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("My Image"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Text("プロフィール画像を登録することができます。"),
          Padding(padding: const EdgeInsets.all(58.0),),
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: (_getUrlResult == null)?NetworkImage(_getUrlResult):NetworkImage(_getUrlResult)),
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
              color: Colors.redAccent,
            ),
          ),
          Center(
          child: ElevatedButton.icon(
            onPressed: (){
              deleteFile();
              _photoset();
            },
            label: Text("選択"),
            icon: Icon(Icons.photo_library),
          ),
    ),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                createAndUploadFile();
              },
              label: Text("送信"),
              icon: Icon(Icons.cloud_upload),
            ),
          ),
          ],
      )
    );
}

  void _currentuser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey== 'email') {
        print("user's email is ${attribute.value}");
        user = attribute.value;
      }
    }
  }

void _photoset() async {
  final picker = ImagePicker();
  try{
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(()  {
      imagefile = File(pickedFile!.path);
      name = path.basename(imagefile!.path);
      //await minio.putObject('amplify-fluamp-dev-74107-deployment', '【S3オブジェクトキー名】', 'name');
      print("filepath: $name");
    });
  }
  on PlatformException catch (err) {
    print(err);
  }
}
  Future<void> createAndUploadFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = imagefile as File;
    final key = user.split("@");
    try {
      final UploadFileResult result = await Amplify.Storage.uploadFile(
          local: file,
          key: '${key[0]}.jpeg',
          onProgress: (progress) {
            print("Fraction completed: " + progress.getFractionCompleted().toString());
          }
      );
      print(key);
      print('Successfully uploaded file: ${result.key}');
      _uploadsucess();
    } on StorageException catch (e) {
      print('Error uploading file: $e');
      _uploaderror();
    }
  }

  void _uploadsucess() async {
    print("AWS S3にアップロードしました");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AWS S3にファイルをアップロードしました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _uploaderror() async {
    print("AWS S3にアップロードできません");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AWS S3にファイルアップロードできません'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _deletesucess() async {
    print("AWS S3からリムーブしました");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AWS S3ファイルをから削除しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _deleteerror() async {
    print("AWS S3からリムーブできません");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AWS S3からファイルを削除できません'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void getUrl() async {
    try {
      var attributes = await Amplify.Auth.fetchUserAttributes();
      for (var attribute in attributes) {
        if (attribute.userAttributeKey== 'email') {
          print("user's email is ${attribute.value}");
          setState(() {
            user = attribute.value;
          });
        }
        }
      print('In getUrl');
      var key = user.split("@");
      S3GetUrlOptions options = S3GetUrlOptions(
          accessLevel: StorageAccessLevel.guest, expires: 10000);
      GetUrlResult result =
      await Amplify.Storage.getUrl(key: '${key[0]}.jpeg');

      setState(() {
        _getUrlResult = result.url;
      });
      print('imageurl: $_getUrlResult');
    } catch (e) {
      print('GetUrl Err: ' + e.toString());
    }
  }

  Future<void> deleteFile() async {
    try {
      var attributes = await Amplify.Auth.fetchUserAttributes();
      for (var attribute in attributes) {
        if (attribute.userAttributeKey== 'email') {
          print("user's email is ${attribute.value}");
          setState(() {
            user = attribute.value;
          });
        }
      }
      var key = user.split("@");
      final RemoveResult result =
      await Amplify.Storage.remove(key: '${key[0]}.jpeg');
      print('Deleted file: ${result.key}');
      _deletesucess();
    } on StorageException catch (e) {
      print('Error deleting file: $e');
      _deleteerror();
    }
  }
}
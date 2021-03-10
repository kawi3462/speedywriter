import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/usermodel.dart';

import 'package:http/http.dart' as http;
import 'package:speedywriter/common/colors.dart';

import 'package:path/path.dart' as path;

import 'package:speedywriter/network_utils/api.dart';
import 'finalorderdetails.dart';

import 'package:speedywriter/common/routenames.dart';

import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/common/drawer.dart';

import 'dart:convert';
import 'package:speedywriter/serializablemodelclasses/ordermaterial.dart';

import 'package:intl/intl.dart'; // for date format
import 'package:intl/date_symbol_data_local.dart'; 

class UploadMaterial extends StatefulWidget {
  static const routeName = '/ordermaterials';

  _UploadMaterialState createState() => _UploadMaterialState();
}

class _UploadMaterialState extends State<UploadMaterial> {
  //String _fileName;
  // String _path;
  String _token;
  String _email;
  //FilePickerResult _path;
  //List<PlatformFile> _paths;
//  Map<String, String> _paths;
  // String _extension = "doc docx pdf png jpeg jpg ";
  // bool _loadingPath = false;
  // bool _multiPick = false;
  // FileType _pickingType = FileType.custom;
  int _orderid;



  String _fileName;
  List<PlatformFile> _paths;
  String _directoryPath;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;


  final GlobalKey<ScaffoldState> _uploadScaffoldState = new GlobalKey();

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose(){

super.dispose();

  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      _uploadScaffoldState.currentState.showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed with success.'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _directoryPath = value);
    });
  }


  _showMsg(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _uploadScaffoldState.currentState.showSnackBar(snackbar);
  }

  /* SharedPreferences localStorage = await SharedPreferences.getInstance();
    _token = localStorage.getString('token') ?? '';
    */
  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null,
      ))
          ?.files;

      for (int i = 0; i < _paths.length; i++) {
        PlatformFile file = _paths.elementAt(i);

      //  String fileName = file.path.split('/').last;
       String _url = Network().url + "/order/"+_orderid.toString()+"/images";


          var postUri = Uri.parse(_url);
          // print(file.path);
          //  print(postUri);

var headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $_token',
};

          var request = http.MultipartRequest("POST", postUri);
          // request.headers['authorization'] = "Bearer $_token";
          // request.headers['Content-Type'] = "multipart/form-data";
    

          request.files.add(
            await http.MultipartFile.fromPath(
              'materials[]',
              file.path,

            ),

            
          );

          request.headers.addAll(headers);


http.StreamedResponse  res = await request.send();
          // var res = await request.send();
          if (res.statusCode == 200) {
            setState(() {
              _loadingPath = true;
            });
  

            


            int x = i + 1;
            if (x == _paths.length) {
              setState(() {
                _loadingPath = false;
              });

           
           ScopedModel.of<UserModel>(context, rebuildOnChange: true).loadUserOrders();

          
             _clearCachedFiles();
              _showMsg('Reference files uploaded successfully');
            }
          } 
          
          else {




            setState(() {
              _loadingPath = false;
            });
            int x = i + 1;
            if (x == _paths.length) {
                  _clearCachedFiles();
              _showMsg('Reference Files  not uploaded.Try again');
            }
          }


      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
        _loadingPath = false;
          _showMsg('Unsupported operation');
    } 
    catch (ex) {
      print(ex);
        _loadingPath = false;
          _showMsg('There was error uploading your file..try again please');
    }

    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
    });
  }



  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 600;
    final FinalOrderDetails _finalOrderDetails =
        ModalRoute.of(context).settings.arguments;
    _orderid = _finalOrderDetails.id;

    _token = ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;
    _email = ScopedModel.of<UserModel>(context, rebuildOnChange: true).email;

    return Row(
      children: [
        if (!displayMobileLayout)
          const SimpleDrawer(
            permanentlyDisplay: true,
          ),
        Expanded(
          child: Scaffold(
            key: _uploadScaffoldState,
            appBar: AppBar(
              // when the app isn't displaying the mobile version of app, hide the menu button that is used to open the navigation drawer
              automaticallyImplyLeading: displayMobileLayout,
              title: Text(
                PageTitles.uploadmaterials,
              ),
            ),
            drawer: displayMobileLayout
                ? const SimpleDrawer(
                    permanentlyDisplay: false,
                  )
                : null,
            body: new Center(
                child: new Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: 200.0),
                      child: Center(
                        child: new SwitchListTile.adaptive(
                          activeColor: speedyPurple100,
                          title: new Text('Pick multiple files',
                              textAlign: TextAlign.right),
                          onChanged: (bool value) =>
                              setState(() => _multiPick = value),
                          value: _multiPick,
                        ),
                      ),
                    ),
                    new Padding(
                        padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              new OutlineButton.icon(
                                  onPressed: () => _openFileExplorer(),
                                  icon: Icon(Icons.attach_file),
                                  disabledBorderColor: speedyPurple100,
                                  highlightColor: speedyPurple100,
                                  highlightedBorderColor: speedyPurple100,
                                  splashColor: speedyPurple100,
                                  label: Text('Open file picker')),
                              new RaisedButton(
                                onPressed: _loadingPath
                                    ? null
                                    : () {
                                        Navigator.pushNamed(
                                            context,RouteNames.makepayments,
                                            arguments: FinalOrderDetails(
                                              _finalOrderDetails.id,
                                  
                                              _finalOrderDetails.subject,
                                              _finalOrderDetails.document,
                                              _finalOrderDetails.pages,
                                              _finalOrderDetails.urgency,
                                            ));

                                        /* Navigator.pushNamed(
                                      context, OrderThankYou.routeName,
                                      arguments: FinalOrderDetails(
                                        finalOrderDetails.id,
                                        finalOrderDetails.email,
                                        finalOrderDetails.subject,
                                        finalOrderDetails.document,
                                        finalOrderDetails.pages,
                                        finalOrderDetails.urgency,
                                      ));  
                                      */
                                      },
                                child: new Text("Make Payment"),
                              ),
                            ])),
                    new Builder(
                      builder: (BuildContext context) => _loadingPath
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: const CircularProgressIndicator(),
                            )
                          : _directoryPath != null
                              ? ListTile(
                                  title: Text('Directory path'),
                                  subtitle: Text(_directoryPath),
                                )
                              : _paths != null
                                  ? Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 30.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.50,
                                      child: Scrollbar(
                                          child: ListView.separated(
                                        itemCount:
                                            _paths != null && _paths.isNotEmpty
                                                ? _paths.length
                                                : 1,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final bool isMultiPath =
                                              _paths != null &&
                                                  _paths.isNotEmpty;
                                          final String name = 'File '+(index+1  ).toString() +
                                              (isMultiPath
                                                  ? _paths
                                                      .map((e) => e.name)
                                                      .toList()[index]
                                                  : _fileName ?? '...');
                                          final path = _paths
                                              .map((e) => e.path)
                                              .toList()[index]
                                              .toString();

                                          return ListTile(
                                            title: Text(
                                              name,
                                            ),
                                            subtitle: Text(path),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const Divider(),
                                      )),
                                    )
                                  : const SizedBox(),
                    ),
                  ],
                ),
              ),
            )),
          ),
        )
      ],
    );
  }
}

//fire base uppload file code
/*
else if (_paths != null) {
        for (int i = 0; i < _paths.length; i++) {
          String _pathString = _paths.values.toList()[i].toString();

          Uri url = Uri.file(_pathString);

          File file = File.fromUri(url);

          String fileName = file.path.split('/').last;

          StorageReference storageReference =
              FirebaseStorage.instance.ref().child('ordermaterials/$fileName');
          StorageUploadTask uploadTask = storageReference.putFile(file);

          final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
          final String downloadurl = (await downloadUrl.ref.getDownloadURL());

          Map data = {
            'order_id': _order_id,
            'filename': fileName,
            'url': downloadurl,
          };

          String filedata = jsonEncode(data);
          var apiUrl = "/filesorder";

          var response = await Network().submitData(filedata, apiUrl, _token);

          if (response.statusCode == 201) {
            int x = i + 1;
            if (x == _paths.length) {
              _showMsg('Reference files uploaded successfully');
            }
          } else {
            int x = i + 1;
            if (x == _paths.length) {
              _showMsg('Reference Files  not uploaded.Try again');
            }
          }
        }
      }*/

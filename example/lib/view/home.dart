import 'package:flutter/material.dart';
import '../view/filter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'dart:io';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File imageFile;
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
 
 //Open gallery
  Future<void> pickImageFromGallery(ImageSource source) async {
      imageFile = await ImagePicker.pickImage(source: source);
  }

  //Switch Camera
  void _onSwitchCamera() {
  selectedCameraIdx =
  selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
  CameraDescription selectedCamera = cameras[selectedCameraIdx];
  _initCameraController(selectedCamera);
}

  // Taking Image
  void _onCapturePressed(context) async {
  Directory directory = await getTemporaryDirectory();
  try {
    // 1
    final path = join(
      directory.path,
      '${DateTime.now()}.jpg',
    );
    // 2
    await controller.takePicture(path);
    imageFile = File(path);
    // 3
    if(imageFile != null){
      if(selectedCameraIdx == 1){
        selectedCameraIdx =
      selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
      CameraDescription selectedCamera = cameras[selectedCameraIdx];
      _initCameraController(selectedCamera);
      }
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Filter(imageFile: imageFile,),
      ),
    );
    }
  } catch (e) {
    print(e);
  }
}

  // 1, 2
Future _initCameraController(CameraDescription cameraDescription) async {
  if (controller != null) {
    await controller.dispose();
  }

  // 3
  controller = CameraController(cameraDescription, ResolutionPreset.high);

  // If the controller is updated then update the UI.
  // 4
  controller.addListener(() {
    // 5
    if (mounted) {
      setState(() {});
    }

    if (controller.value.hasError) {
      print('Camera error ${controller.value.errorDescription}');
    }
  });

  // 6
  try {
    await controller.initialize();
  } on CameraException catch (e) {
    //_showCameraException(e);
    print('Camera ERROR: $e');
  }

  if (mounted) {
    setState(() {});
  }
}

Widget _cameraPreviewWidget(BuildContext context) {
  if (controller == null || !controller.value.isInitialized) {
    return const Text(
      'Loading',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  return Center(
    child: Transform.scale(
    scale: controller.value.aspectRatio/(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.height + AppBar().preferredSize.height*1.2)),
    child: AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      // child: CameraPreview(controller),
      child: Container(
        child: Stack(
          children: <Widget>[
            CameraPreview(controller),
            Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 0.35,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            //color: Color.fromRGBO(00, 00, 00, 0.5),
            color: Colors.transparent,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15, right: MediaQuery.of(context).size.width * 0.05,),
                child: Material(
                    borderOnForeground: false,
                    type: MaterialType.circle,
                    color: Colors.transparent,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      //focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      onTap: () async {
                        await pickImageFromGallery(ImageSource.gallery);
                        if(imageFile != null){
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Filter(imageFile: imageFile,)));
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 20,
                          //backgroundColor: Color.fromRGBO(00, 00, 00, 0.5),
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
              ),
              ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      onTap: () {
                        // _captureImage();
                        _onCapturePressed(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        child: FloatingActionButton(
                          onPressed: (){
                            _onCapturePressed(context);
                          },
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera, color: Colors.black, size: 30,),
                        )
                      ),
                    ),
                  ),
                ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.15),
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      //focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      onTap: () {
                        _onSwitchCamera();
                        // if (!_toggleCamera) {
                        //   onCameraSelected(widget.cameras[1]);
                        //   setState(() {
                        //     _toggleCamera = true;
                        //   });
                        // } else {
                        //   onCameraSelected(widget.cameras[0]);
                        //   setState(() {
                        //     _toggleCamera = false;
                        //   });
                        // }
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 20,
                          //backgroundColor: Color.fromRGBO(00, 00, 00, 0.5),
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.autorenew,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
              ),
              ),
                )
              ],
            ),
          ),
        ),
          ],
        ),
      ),
    ),
  ),
  );
}



  @override
void initState() {
  super.initState();
  // 1
  availableCameras().then((availableCameras) {
    
    cameras = availableCameras;
    if (cameras.length > 0) {
      setState(() {
        // 2
        selectedCameraIdx = 0;
      });

      _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
    }else{
      print("No camera available");
    }
  }).catchError((err) {
    // 3
    print('Error: $err.code\nError Message: $err.message');
  });
}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //appBar: AppBar(title: const Text('Bottom App Bar')),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.white,
      //   child: const Icon(Icons.camera, color: Colors.grey, size: 30,),
      //   onPressed: () {
      //     Navigator.of(context)
      //         .push(MaterialPageRoute(builder: (context) => Filter()));
      //   },
      // ),
      body: Container(
        child: _cameraPreviewWidget(context),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   color: Color.fromRGBO(00, 00, 00, 0.5),
      //   shape: CircularNotchedRectangle(),
      //   notchMargin: 4.0,
      //   child: Container(
      //     height: AppBar().preferredSize.height * 1.2,
      //     child: new Row(
      //       mainAxisSize: MainAxisSize.max,
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: <Widget>[
      //         // IconButton(
      //         //   icon: Icon(Icons.add),
      //         //   iconSize: 30,
      //         //   onPressed: () async {
      //         //     await pickImageFromGallery(ImageSource.gallery);
      //         //     Navigator.push(context,
      //         //         MaterialPageRoute(builder: (context) => Filter(imageFile: imageFile,)));
      //         //   },
      //         //   padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15, right: MediaQuery.of(context).size.width * 0.15),
      //         //   //alignment: Alignment.center,
      //         // ),
      //         Padding(
      //           padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15, right: MediaQuery.of(context).size.width * 0.15),
      //           child: Material(
      //               color: Colors.transparent,
      //               child: InkWell(
      //                 borderRadius: BorderRadius.all(Radius.circular(50.0)),
      //                 onTap: () {
      //                   // if (!_toggleCamera) {
      //                   //   onCameraSelected(widget.cameras[1]);
      //                   //   setState(() {
      //                   //     _toggleCamera = true;
      //                   //   });
      //                   // } else {
      //                   //   onCameraSelected(widget.cameras[0]);
      //                   //   setState(() {
      //                   //     _toggleCamera = false;
      //                   //   });
      //                   // }
      //                 },
      //                 child: Container(
      //                   padding: EdgeInsets.all(4.0),
      //                   child: CircleAvatar(
      //                     backgroundColor: Colors.grey,
      //                     child: Icon(Icons.autorenew,
      //                       color: Colors.grey[200],
      //                       size: 30,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //         ),
      //         ),
      //         Padding(
      //           padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15, right: MediaQuery.of(context).size.width * 0.15),
      //           child: Material(
      //               color: Colors.transparent,
      //               child: InkWell(
      //                 borderRadius: BorderRadius.all(Radius.circular(50.0)),
      //                 onTap: () {
      //                   // if (!_toggleCamera) {
      //                   //   onCameraSelected(widget.cameras[1]);
      //                   //   setState(() {
      //                   //     _toggleCamera = true;
      //                   //   });
      //                   // } else {
      //                   //   onCameraSelected(widget.cameras[0]);
      //                   //   setState(() {
      //                   //     _toggleCamera = false;
      //                   //   });
      //                   // }
      //                 },
      //                 child: Container(
      //                   padding: EdgeInsets.all(4.0),
      //                   child: CircleAvatar(
      //                     backgroundColor: Colors.black,
      //                     child: Icon(Icons.create_new_folder,
      //                       color: Colors.white,
      //                       size: 30,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //         ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
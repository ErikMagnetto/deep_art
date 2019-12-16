import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../model/artist.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart' as image;
import 'package:image/image.dart' as img;
import 'package:photo_view/photo_view.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:deep_art/deep_art.dart';
// import 'package:artistic_style_transfer/artistic_style_transfer.dart';
import '../view/waiting_dialog.dart';
import '../view/message_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:share/share.dart';
import 'package:image/image.dart';
import 'dart:io';
import 'dart:convert';

import '../view/filter.dart';

class RealTime extends StatefulWidget {
  File imageFile;
  RealTime({Key key, this.title, this.imageFile}) : super(key: key);

  final String title;

  @override
  _RealTimeState createState() => _RealTimeState();
}

class _RealTimeState extends State<RealTime> {
  File imageFile;
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  List<Widget> listFilter = [];
  List<Artist> listArtist = [];
  List<int> selected = [];

  void createListArtist() {
    for(int i = 0; i < 12; i++){
      // if(i == 0){
      //   Artist artist = new Artist('Da Vinci', 'assets/$i.jpeg', false);
      //   listArtist.add(artist);
      // }
      // else {
      //   Artist artist = new Artist('Da Vinci', 'assets/$i.jpg', false);
      //   listArtist.add(artist);
      // }
      switch (i) {
        case 0:
          Artist artist = new Artist('C. Hilsaca', 'assets/$i.jpeg', false);
          listArtist.add(artist);
          break;
        case 1:
          Artist artist = new Artist('Claude Monet', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 2:
          Artist artist = new Artist('Claude Monet', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 3:
          Artist artist = new Artist('Van Gogh', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 4:
          Artist artist = new Artist('Kathryn Corlett', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 5:
          Artist artist = new Artist('Da Vinci', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 6:
          Artist artist = new Artist('Picasso', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 7:
          Artist artist = new Artist('Van Gogh', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 8:
          Artist artist = new Artist('Van Gogh', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 9:
          Artist artist = new Artist('Van Gogh', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 10:
          Artist artist = new Artist('W. Turner', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
        case 11:
          Artist artist = new Artist('W. Turner', 'assets/$i.jpg', false);
          listArtist.add(artist);
          break;
      }
      
    }
    print(listArtist.length);
  }

  //Open gallery
  Future<void> pickImageFromGallery(ImageSource source) async {
    imageFile = await ImagePicker.pickImage(source: source);
  }

  //Switch Camera
  void _onSwitchCamera(int number) {
    selectedCameraIdx =
    selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera);
  }

  // Taking Image
  void _onCapturePressed(context, int number) async {
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
      await controller.initialize().then((_){
        if (!mounted){
          return;
        }
      });
    } on CameraException catch (e) {
      //_showCameraException(e);
      print('Camera ERROR: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  // Future<void> processImage(int number) async {
  //   Directory tempDir = await getTemporaryDirectory();
  //     String tempPath = tempDir.path;
  //     // processed = await DeepArt.styleTransfer(styles: selected, inputFilePath: widget.imageFile.path, outputFilePath: tempPath, quality: 40, styleFactor: 1.0, convertToGrey: false);
  //     processed = await DeepArt.realtimeTransfer(/*styles: selected, */inputFilePath: imageFile.path, outputDir: tempPath, number: number/*, quality: 40, styleFactor: 1.0, convertToGrey: false*/);
  //     setState(() {
  //     });
  // }

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

    return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
        // scale: controller.value.aspectRatio/(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.height + AppBar().preferredSize.height*1.2)),
        // scale: 1,
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          // child: CameraPreview(controller),
           child: Container(
             child: Stack(
               children: <Widget>[
                CameraPreview(controller),
                //  Align(
                //    alignment: Alignment.bottomCenter,
                //    child: Container(
                //      width: double.infinity,
                //      height: MediaQuery.of(context).size.width * 0.35,
                //      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                //      //color: Color.fromRGBO(00, 00, 00, 0.5),
                //      color: Colors.transparent,
                //      child: Row(
                //        children: <Widget>[
                //          Expanded(
                //            flex: 2,
                //            child: Padding(
                //              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15, right: MediaQuery.of(context).size.width * 0.05,),
                //              child: Material(
                //                borderOnForeground: false,
                //                type: MaterialType.circle,
                //                color: Colors.transparent,
                //                child: InkWell(
                //                  hoverColor: Colors.transparent,
                //                  //focusColor: Colors.transparent,
                //                  splashColor: Colors.transparent,
                //                  highlightColor: Colors.transparent,
                //                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                //                  onTap: () async {
                //                    await pickImageFromGallery(ImageSource.gallery);

                //                  },
                //                  child: Container(
                //                    padding: EdgeInsets.all(4.0),
                //                    child: CircleAvatar(
                //                      radius: 20,
                //                      //backgroundColor: Color.fromRGBO(00, 00, 00, 0.5),
                //                      backgroundColor: Colors.transparent,
                //                      child: Icon(Icons.add,
                //                        color: Colors.white,
                //                        size: 20,
                //                      ),
                //                    ),
                //                  ),
                //                ),
                //              ),
                //            ),
                //          ),
                //          Expanded(
                //            flex: 1,
                //            child: Align(
                //              alignment: Alignment.topCenter,
                //              child: Material(
                //                color: Colors.transparent,
                //                child: InkWell(
                //                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                //                  onTap: () {
                //                    // _captureImage();
                //                    _onCapturePressed(context);
                //                  },
                //                  child: Container(
                //                      padding: EdgeInsets.all(4.0),
                //                      child: FloatingActionButton(
                //                        onPressed: (){
                //                          _onCapturePressed(context);
                //                        },
                //                        backgroundColor: Colors.white,
                //                        child: Icon(Icons.camera, color: Colors.black, size: 30,),
                //                      )
                //                  ),
                //                ),
                //              ),
                //            ),
                //          ),
                //          Expanded(
                //            flex: 2,
                //            child: Padding(
                //              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.15),
                //              child: Material(
                //                color: Colors.transparent,
                //                child: InkWell(
                //                  hoverColor: Colors.transparent,
                //                  //focusColor: Colors.transparent,
                //                  splashColor: Colors.transparent,
                //                  highlightColor: Colors.transparent,
                //                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                //                  onTap: () {
                //                    _onSwitchCamera();
                //                    // if (!_toggleCamera) {
                //                    //   onCameraSelected(widget.cameras[1]);
                //                    //   setState(() {
                //                    //     _toggleCamera = true;
                //                    //   });
                //                    // } else {
                //                    //   onCameraSelected(widget.cameras[0]);
                //                    //   setState(() {
                //                    //     _toggleCamera = false;
                //                    //   });
                //                    // }
                //                  },
                //                  child: Container(
                //                    padding: EdgeInsets.all(4.0),
                //                    child: CircleAvatar(
                //                      radius: 20,
                //                      //backgroundColor: Color.fromRGBO(00, 00, 00, 0.5),
                //                      backgroundColor: Colors.transparent,
                //                      child: Icon(Icons.autorenew,
                //                        color: Colors.white,
                //                        size: 20,
                //                      ),
                //                    ),
                //                  ),
                //                ),
                //              ),
                //            ),
                //          )
                //        ],
                //      ),
                //    ),
                //  ),
               ],
             ),
           ),
        ),
    );
  }

  List<Widget> artistCard(List<Artist> list) {
    List<Widget> listCard = [];
    print(listArtist.length);
    for(int i=0; i < 12; i++){
      listCard.add(
      Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 4),
            child: Center(
              child: Text(list[i].name, style: TextStyle(color: list[i].isChoose == true ? Colors.pink : Colors.white, fontSize: 12),),
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 5, right: 5, left: 5, bottom: 5),
              //margin: EdgeInsets.only(right: 20),
              width: 80,
              height: 80,
              child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: InkWell(
                        child: list[i].isChoose == true ? Stack(
                          children: <Widget>[
                            Container(
                              child: image.Image.asset(list[i].demo,package: 'deep_art',),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              // margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: Colors.pink[200].withOpacity(0.8),
                                border: Border.all(width: 1, color: Colors.pink)
                              ),
                            )
                          ],
                        ) : Stack(
                          children: <Widget>[
                            Container(
                              child: image.Image.asset(list[i].demo, package: 'deep_art',
                              //size: 100,
                            ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          selected.clear();
                          for(int j=0; j<12; j++){
                            if(j != i){
                              setState(() {
                                list[j].isChoose = false;
                              });
                            }
                            else {
                              if(list[i].isChoose == false){
                                setState(() {
                                  list[i].isChoose = true;
                                  selected.add(i);
                                });
                                // showDialog(
                                //   context: context,
                                //   barrierDismissible: false,
                                //   child: WaitingDialog(
                                //     processingFunction: processImage(i),
                                //     errorHandle: _errorHandle,
                                //   ),
                                // );
                                // await processImage(i);
                                if(i >= 0){
                                  controller.startImageStream((CameraImage img){
                                  DeepArt.realtimeTransfer(
                                    // planes: img.planes,
                                    yRowStride: img.planes[0].bytesPerRow,
                                    uvRowStride: img.planes[1].bytesPerRow,
                                    uvPixelStride: img.planes[1].bytesPerPixel,
                                    byteList: img.planes.map((plane){
                                      return plane.bytes;
                                    }).toList(),
                                    imgHeight: img.height,
                                    imgWidth: img.width,
                                    number: i,
          );
        });
        }
                                // print(processed);
                              }
                              else if(list[i].isChoose == true){
                                setState(() {
                                  list[i].isChoose = false;
                                });
                              }
                            }
                          }
                        },
                      ),
                    )
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(12.0),
              //   child: GestureDetector(
              //     child: image.Image.asset(artist.demo
              //         //size: 100,
              //         ),
              //     onTap: () {},
              //   ),
              // )
            ),
        ],
      ),
    ),
      );
    }
    return listCard;
  }



  @override
  void initState() {
    createListArtist();
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
      body: Container(
        child: Column(
          children: <Widget>[
            _cameraPreviewWidget(context),
              Container(
                color: Colors.black54,
                height: 104,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:  artistCard(listArtist).length,
                  itemBuilder: (context, index) {
                    return artistCard(listArtist)[index];
                  },
                ),
              ),
          ],
        )
        
      ),
    );
  }
}
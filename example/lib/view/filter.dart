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
import 'package:share/share.dart';
import 'package:image/image.dart';
import 'real_time.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';

class Filter extends StatefulWidget {
  File imageFile;
  Filter({Key key, this.title, this.imageFile}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  int _counter = 0;
  double width;
  double height;
  List<Widget> listFilter = [];
  List<Artist> listArtist = [];
  List<int> selected = [];
  String processed;
  File processedFile;
  File imageFile;
  bool filterVisible;
  CameraController controller;

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

  Future<ByteData> getBytesFromFile() async {
    processedFile = File(processed);
    Uint8List bytes = processedFile.readAsBytesSync() as Uint8List;
    return ByteData.view(bytes.buffer);
  }

  //Open gallery
  Future<void> pickImageFromGallery(ImageSource source) async {
      imageFile = await ImagePicker.pickImage(source: source);
      if(source == ImageSource.camera){
        // ui.PictureRecorder recorder = new ui.PictureRecorder();
        // Canvas canvas = new Canvas(recorder);

      }
  }

  Future<void> processImage(int number) async {
    Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      // processed = await DeepArt.styleTransfer(styles: selected, inputFilePath: widget.imageFile.path, outputFilePath: tempPath, quality: 40, styleFactor: 1.0, convertToGrey: false);
      processed = await DeepArt.styleTransfer(/*styles: selected, */inputFilePath: imageFile.path, outputDir: tempPath, number: number/*, quality: 40, styleFactor: 1.0, convertToGrey: false*/);
      setState(() {
      });
  }

  void _errorHandle(){
    showDialog(
        context: context,
        barrierDismissible: false,
        child: MessageDialog(title: "Error", message: "Failed to process image, please try again or reduce quality"),
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
                                await processImage(i);
                                print(processed);
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
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return new Scaffold(
      backgroundColor: (imageFile != null) ? Colors.black54 : Colors.white,
      appBar: imageFile == null ? AppBar(
        backgroundColor: Colors.pink[200],
        actions: <Widget>[
        IconButton(
          icon: Icon(Icons.save_alt),
          onPressed: () async {
            await getBytesFromFile().then((bytes) {
              ImageGallerySaver.saveImage(bytes.buffer.asUint8List());
            });
            
          },
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            // await getBytesFromFile().then((bytes) {
            //   Share.file('Share via:', 'image',
            //   bytes.buffer.asUint8List(), 'image/jpg');
            // });
            if(processed != null){
              Share.shareFile(File(processed));
            }
          },
        ),
        // PopupMenuButton<String>(
        //   onSelected: (a) {},
        //   itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        //     const PopupMenuItem<String>(
        //       value: 'Lưu',
        //       child: Text('Lưu'),
        //     ),
        //     const PopupMenuItem<String>(
        //       value: 'Chia sẻ',
        //       child: Text('Chia sẻ'),
        //     ),
        //   ],
        // )
      ],
      ) : AppBar(
        backgroundColor: Colors.pink[200],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            setState(() {
              imageFile = null;
              processed = null;
            });
          },
        ),
        actions: <Widget>[
        IconButton(
          icon: Icon(Icons.save_alt),
          onPressed: () async {
            await getBytesFromFile().then((bytes) {
              ImageGallerySaver.saveImage(bytes.buffer.asUint8List());
            });
            
          },
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            // await getBytesFromFile().then((bytes) {
            //   Share.shareFile('Share via:', 'image',
            //   bytes.buffer.asUint8List(), 'image/jpg');
            // });
            if(processed != null){
              Share.shareFile(File(processed));
            }
          },
        ),
      ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            processed == null ? (imageFile != null ? Container(
              height: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  104,
              child: PhotoView.customChild(
                  customSize: Size(
                      width,
                      MediaQuery.of(context).size.height -
                          AppBar().preferredSize.height -
                          MediaQuery.of(context).padding.top -
                          104),
                  child: image.Image.file(imageFile),
                  childSize: Size(
                      width,
                      MediaQuery.of(context).size.height -
                          AppBar().preferredSize.height -
                          MediaQuery.of(context).padding.top -
                          104
                          ),
                        ),
            ) : Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - 104,
                  child: Center(
                    child: Text('No image'),
                  ),
            )) : (imageFile != null ? Container(
              height: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  104,
              child: PhotoView.customChild(
                  customSize: Size(
                      width,
                      MediaQuery.of(context).size.height -
                          AppBar().preferredSize.height -
                          MediaQuery.of(context).padding.top -
                          104),
                  child: image.Image.file(File(processed)),
                  childSize: Size(
                      width,
                      MediaQuery.of(context).size.height -
                          AppBar().preferredSize.height -
                          MediaQuery.of(context).padding.top -
                          104
                          ),
                        ),
            ) : Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - 104,
                  child: Center(
                    child: Text('No image'),
                  ),
            )),

            Visibility(
              visible: imageFile != null,
              child: Container(
                color: Colors.black54,
                height: 104,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: artistCard(listArtist).length,
                  itemBuilder: (context, index) {
                    return artistCard(listArtist)[index];
                  },
                ),
              ),
            ),

            Visibility(
              visible: imageFile == null,
              child: Center(
      // child: CameraPreview(controller),
      child: Container(
        height: 104,
        color: Colors.white,
        child: Stack(
          children: <Widget>[
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
                          setState(() {
                            
                          });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 20,
                          //backgroundColor: Color.fromRGBO(00, 00, 00, 0.5),
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.folder,
                            color: Colors.pink[200],
                            size: 25,
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
                        
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        child: FloatingActionButton(
                          onPressed: () async {
                            await pickImageFromGallery(ImageSource.camera);
                            setState(() {
                            
                            });
                          },
                          backgroundColor: Colors.pink[200],
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 30,),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RealTime(imageFile: imageFile,),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 20,
                          //backgroundColor: Color.fromRGBO(00, 00, 00, 0.5),
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.videocam,
                            color: Colors.pink[200],
                            size: 25,
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
          ],
        ),
      ),
    );
  }
}

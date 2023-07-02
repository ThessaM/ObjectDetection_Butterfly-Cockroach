// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:tflite/tflite.dart';

// List<CameraDescription> cameras = [];

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark(),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late CameraImage cameraImage;
//   late CameraController cameraController;
//   String result = "";

//   initCamera() {
//     cameraController = CameraController(cameras[0], ResolutionPreset.medium);
//     cameraController.initialize().then((value) {
//       if (!mounted) return;
//       setState(() {
//         cameraController.startImageStream((imageStream) {
//             cameraImage = imageStream;
//             runModel();
//         });
//       });
//     });
//   }

//   loadModel() async {
//     await Tflite.loadModel(
//         model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
//   }

//   runModel() async {
//     if (cameraImage != null) {
//       var recognitions = await Tflite.runModelOnFrame(
//           bytesList: cameraImage.planes.map((plane) {
//             return plane.bytes;
//           }).toList(),
//           imageHeight: cameraImage.height,
//           imageWidth: cameraImage.width,
//           imageMean: 127.5,
//           imageStd: 127.5,
//           rotation: 90,
//           numResults: 2,
//           threshold: 0.1,
//           asynch: true);
//       recognitions?.forEach((element) {
//         setState(() {
//           result = element["label"];
//           print(result);
//         });
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//     loadModel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Face Mask Detector"),
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Container(
//                 height: MediaQuery.of(context).size.height - 170,
//                 width: MediaQuery.of(context).size.width,
//                 child: !cameraController.value.isInitialized
//                     ? Container(
//                       child: Image.asset("assets/colorpalette.png"),
//                     )
//                     : AspectRatio(
//                         aspectRatio: cameraController.value.aspectRatio,
//                         child: CameraPreview(cameraController),
//                       ),
//               ),
//             ),
//             Text(
//               result,
//               style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool _isLoading=true;
  File _image = File("");
  List _output = [];
  // late List _output;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {

      });
    });
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.7,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    // var recognitions = await Tflite.detectObjectOnImage(
    //   path: filepath,       // required
    //   model: "SSDMobileNet",
    //   imageMean: 127.5,     
    //   imageStd: 127.5,      
    //   threshold: 0.4,       // defaults to 0.1
    //   numResultsPerClass: 2,// defaults to 5
    //   asynch: true          // defaults to true
    // );
    setState(() {
      _output = [];
      _output.add(output);
      _isLoading = false;
    });
    // output!=null ? output.clear() : null;
    // output!=null ? _output.clear() : null;
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if(image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });

    detectImage(_image);
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if(image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });

    detectImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[400],
        body: Center(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0,),
                const Center(
                  child: Text(
                    'Butterfly and Cockroach Detector app',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 200.0),
                Center(
                  child: _isLoading ? SizedBox(
                    width: MediaQuery.of(context).size.width*0.9,
                    // width: 400,
                    child: Column(
                      children: [
                        Image.asset("assets/colorpalette.png", fit: BoxFit.cover,)
                      ],
                    ),
                  ) : Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: Image.file(_image),
                        ),
                        const SizedBox(height: 20.0,),
                        // _output!=null ? Text('${_output[0]['label']}', style: TextStyle(color: Colors.white, fontSize: 15.0),) : Container(),
                        _output!=null ? !_output[0].isEmpty? Text(_output[0][0]["label"], style: const TextStyle(color: Colors.white, fontSize: 15.0),): const Text("0 others", style: TextStyle(color: Colors.white, fontSize: 15.0)) : Container(),
                        const SizedBox(height: 10.0,),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.6,
                    // width: 400,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            pickImage();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.grey),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15.0),
                            child: Text(
                              'Capture a pic',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.01,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            pickGalleryImage();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.grey),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                            child: Text(
                              'Select from gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.50,
                              ),
                            ),
                          ),
                        ),
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
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

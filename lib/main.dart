import 'dart:io';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:hello_me/Login.dart';
import 'package:hello_me/ImageCapture.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:file_picker/file_picker.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;







void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
   runApp((App()));

}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    // _initializeFireBase();
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {

          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: RandomWords(),

    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  //final _saved = <WordPair>{};
  final _saved = <dynamic>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController validatePasswordController = TextEditingController();


  void clearCredentials(){
    nameController.clear();
    passwordController.clear();
  }

  void _logInOrOut (){
   Login.instance().status == Status.Authenticated ? _pushLogOut()  : _pushLogin();

  }

  void _pushLogOut(){
    Login.instance().signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Successfully logged out'),
    ));

  }

  Future<void>getSavedWordsFromFB() async {
    FirebaseFirestore _fireStore = FirebaseFirestore.instance;

    var getWordsFromFB = await FirebaseFirestore.instance.collection('Users').doc(Login.instance().user!.email).
    get().then((querySnapshot) async {
      if(querySnapshot.exists){
        var savedFromCloud = querySnapshot.data();
        if (savedFromCloud != null) {_saved.addAll(savedFromCloud['favorites']);}

        ChangeDataInFB();



      }

    });
  }

  Future<bool> LogIn (_isButtonActive) async {
    if (_isButtonActive) {
      var loggedInUser;
      setState(() => _isButtonActive = false);
      loggedInUser = await Login.instance().signIn(
          nameController.text, passwordController.text);
      setState(() => _isButtonActive = true);

      if (loggedInUser) {
        var isLocalWords = _saved;
        getSavedWordsFromFB();



        Navigator.pop(context,true);

      }

      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('There was an error logging into the app'),
        ));
        return false;
      }
    }
    return true;

  }

  void _pushLogin() {
   bool _isButtonActive = true;
   clearCredentials();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
                (pair) {
              return ListTile(
                title: Text(
                  pair,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Center(child: Text('Login')),
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Welcome to Startup Names Generator, please log in below',
                      )),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),

                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: Text("Log in"),
                    style: TextButton.styleFrom(
                      fixedSize: const Size(350.0,20.0),
                      primary: Colors.white,  //Text Color
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0),
                      )
                    ),
                    onPressed: () async {
                      await LogIn(_isButtonActive);
                   }
                  ),
                  ElevatedButton(
                      child: Text("New user? Click to sign up"),
                      style: TextButton.styleFrom(
                          fixedSize: const Size(350.0,20.0),
                          primary: Colors.white,  //Text Color
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0),
                          )
                      ),
                      onPressed: () async {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                const Center(
                                child: TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Please confirm your password below:',
                                  border: InputBorder.none,
                                  floatingLabelAlignment: FloatingLabelAlignment.center,
                                ),
                              ),
                                ),

                                  Divider(),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    child: TextField(
                                      obscureText: true,
                                      controller: validatePasswordController,
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'Password',
                                      ),
                                    ),
                                  ),
                                  TextButton(

                                    child: const Text('Confirm'),
                                    style: TextButton.styleFrom(
                                        primary: Colors.white,  //Text Color
                                        backgroundColor: Colors.blueAccent,
                                        fixedSize: const Size(100.0,20.0),


                                    ),

                                    onPressed: () async {
                                      if(passwordController.text == validatePasswordController.text){
                                        await Login.instance().signUp(nameController.text, passwordController.text);
                                        LogIn(false);
                                        Navigator.pop(context,true);
                                        Navigator.pop(context,true);
                                      }
                                      else{
                                        Navigator.pop(context,true);

                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('Passwords must match'),
                                        ));
                                      }


                                    },
                                  ),
                                ],
                              );
                            });

                     }





                  )
                ],
              )
            )
          );
        },
      ),
    );
  }

  Future<bool?> _showMyDialog(word) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Suggestion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete'),
                Text(word + ' from your saved suggestions?'),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              style: TextButton.styleFrom(
                  primary: Colors.white,  //Text Color
                  backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pop(context,true);
              },
            ),
            TextButton(
              child: const Text('No'),
              style: TextButton.styleFrom(
                primary: Colors.white,  //Text Color
                backgroundColor: Colors.deepPurple,

              ),
              onPressed: () {

                Navigator.pop(context,false);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavedSuggestions(divided) {
    return Container(
      child: _saved.length > 0
          ? ListView.builder(
        itemCount: _saved.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            onDismissed: (direction) {
              setState(() {
                _saved.remove(_saved.elementAt(index));
                ChangeDataInFB();
              });
            },

            confirmDismiss: (DismissDirection direction) async {
              var toRemove = await _showMyDialog(_saved.elementAt(index).toString())==true;

              return toRemove==true;

                         },
            secondaryBackground: Container(
              color: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    Text('Delete Suggestion',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),),


            background: Container(
              color: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    Text('Delete Suggestion',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),),
            child: divided[index],
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
          );
        },
      )
          : Center(child: Text('No Items')),
    );
  }

  void _pushSaved() async{

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context)
    {
      final tiles = _saved.map(
            (pair) {
          return ListTile(
            title: Text(
              pair,
              style: _biggerFont,
            ),
          );
        },
      );
      final divided = tiles.isNotEmpty
          ? ListTile.divideTiles(
        context: context,
        tiles: tiles,
      ).toList()
          : <Widget>[];

      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Suggestions'),
        ),
        body: _buildSavedSuggestions(divided)

      );
    },
      )
    );
    }
  void ChangeDataInFB() async {
    FirebaseFirestore _fireStore = await FirebaseFirestore.instance;
    Map<String, dynamic> data = {"favorites":FieldValue.arrayUnion(_saved.toList())};
    await _fireStore.collection('Users').doc(Login.instance().user!.email).set(data,SetOptions(merge: false));



  }


  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair.asPascalCase.toString());


    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Colors.deepPurple : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair.asPascalCase.toString());

          } else {
            _saved.add(pair.asPascalCase.toString());

          }
          ChangeDataInFB();
        });
      },
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      // The itemBuilder callback is called once per suggested
      // word pairing, and places each suggestion into a ListTile
      // row. For even rows, the function adds a ListTile row for
      // the word pairing. For odd rows, the function adds a
      // Divider widget to visually separate the entries. Note that
      // the divider may be difficult to see on smaller devices.
      itemBuilder: (context, i) {
        // Add a one-pixel-high divider widget before each row
        // in the ListView.
        if (i.isOdd) {
          return const Divider();
        }

        // The syntax "i ~/ 2" divides i by 2 and returns an
        // integer result.
        // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
        // This calculates the actual number of word pairings
        // in the ListView,minus the divider widgets.
        final index = i ~/ 2;
        // If you've reached the end of the available word
        // pairings...
        if (index >= _suggestions.length) {
          // ...then generate 10 more and add them to the
          // suggestions list.
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }
  @override
  Widget build(BuildContext context)  {
    final profileController = SnappingSheetController();
    bool isPressed = false;

    //File? _userPicture;


    if(Login.instance().user!=null) {
      getSavedWordsFromFB();
      }

    return Scaffold (

        // Add from here...
        appBar: AppBar(
            title: const Text('Startup Name Generator'),
            titleTextStyle: TextStyle(fontSize: 20),

            // Add from here ...
          actions: [
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
            IconButton(
                icon: Login.instance().status==Status.Authenticated ? const Icon(Icons.exit_to_app) : const Icon(Icons.login),
                onPressed: (){
                  setState(() {
                    icon: const Icon(Icons.login);
                    _logInOrOut();
                  });
                }
            ),
          ],
        ),
        //body:_buildSuggestions()
         body: Login.instance().status == Status.Authenticated  ?
         InkWell(
           child: SnappingSheet(
             controller: profileController,
             child: _buildSuggestions(),
             grabbingHeight: 50,
             grabbing: Container(
               color: Colors.grey,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                 children: <Widget>[
                   Text('Welcome back ' + Login.instance().user!.email!),
                   const Icon(Icons.keyboard_arrow_up)
                 ],
               ),
             ),
             sheetBelow: SnappingSheetContent(
               draggable: true,

               //child: userProfile(context, _userPicture),
               child: Container(
                 color: Colors.white,
                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                 child: Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: <Widget>[
                   Container(
                     padding: EdgeInsets.all(10),
                     // set random = true
                     // default is false
                     child: getPicture(Login.instance().user!.email!),
                   ),
                   Column(
                       children: <Widget>[

                         Container(
                           padding: EdgeInsets.all(10),
                           child: Text(
                             Login.instance().user!.email!,
                             style: TextStyle(
                               fontSize: 14,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),

                         TextButton(

                           child: const Text('Change avatar'),
                           style: TextButton.styleFrom(
                             primary: Colors.white,  //Text Color
                             backgroundColor: Colors.blueAccent,
                             alignment: Alignment.bottomRight,
                           ),

                           onPressed: isPressed ? null : () async {
                              setState(() {
                              isPressed = true;
                              });
                              final result = await FilePicker.platform.pickFiles(
                              allowMultiple: false,
                              type: FileType.custom,
                              allowedExtensions: ['png', 'jpg'],);

                              if(result == null){
                              //widget.controller.snapToPosition(SnappingPosition.factor(positionFactor:0.1,grabbingContentOffset:0));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior:SnackBarBehavior.fixed,
                              content: Text('No image selected')));//margin:EdgeInsets.only(top: 90),
                              }

                              else {
                              final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
                              final path = result.files.single.path;
                              final fileName = result.files.single.name;
                              var doc =  await FirebaseFirestore.instance.collection('Users').doc(Login.instance().user!.email!).
                              get().then((querySnapshot) {return querySnapshot.data();});
                              File file = File(path!);

                              try {
                              await storage.ref('Users/${Login.instance().user!.email!}/$fileName').putFile(file);
                              await storage.ref('Users/${Login.instance().user!.email!}/$fileName').writeToFile(file);
                              }
                              on firebase_core.FirebaseException catch (e) {
                              print(e);
                              }
                              String returnURL = await storage.ref('Users/${Login.instance().user!.email!}/$fileName').getDownloadURL();//'files/$fileName'
                              Map<String, dynamic> data = {'address': returnURL, 'fileName' : fileName};
                              await FirebaseFirestore.instance.collection('Users').doc(Login.instance().user!.email!)
                                  .set(data,SetOptions(merge : false));
                              if(doc?.isNotEmpty == true && doc!['fileName'] != fileName){
                              await storage.refFromURL(doc['address']).delete();
                              }
                              }

                              setState(() {
                              isPressed = false;
                              });
                              }
                              ,
                         ),
                      ],
                   )
                 ]

                 ,

               ),
               )


             ),
           ),
             onTap: () {
               if (profileController.isAttached) {
                 if (profileController.currentPosition > 25) {
                   profileController.snapToPosition(
                       const SnappingPosition.pixels(positionPixels: 25)
                   );
                 }
                 else {
                   profileController.snapToPosition(
                       const SnappingPosition.factor(positionFactor: 0.75)
                   );
                 }
               }

             }
         ) :
         _buildSuggestions(),



    );
  }
}

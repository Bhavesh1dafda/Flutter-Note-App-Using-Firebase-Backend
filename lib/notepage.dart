import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_note_app/editNote.dart';
import 'package:firebase_note_app/profilePage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'dart:io';
import 'loginPage.dart';
import 'realtime_database_demo.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({Key? key}) : super(key: key);

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;

  bool loading = false;
  File? _image;
  final picker = ImagePicker();

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('no image picked');
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Home Page"),
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: InkWell(
                onTap: () {
                  Get.to(() => RealTimeDatabase());
                },
                child: Icon(Icons.pages)),
            actions: [
              InkWell(
                onTap: () {
                  Get.to(() => const ProfilePage());
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.manage_accounts),
                ),
              ),
              InkWell(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Get.to(() => const LoginaPage());
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.logout),
                ),
              ),
            ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                getImageGallery();
                              },
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black)),
                                child: _image != null
                                    ? Image.file(_image!.absolute)
                                    : Center(child: Icon(Icons.image)),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text("Add Bill Image"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            controller: amountController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Enter Amount"),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Required";
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            controller: noteController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Enter Your Note"),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Required";
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () async {
                            var amount = amountController.text.trim();
                            var note = noteController.text.trim();
                            User? user = FirebaseAuth.instance.currentUser;
                            if (_formKey.currentState!.validate()) {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  Future.delayed(
                                    Duration(seconds: 0),
                                    () async {
                                      firebase_storage.Reference ref =
                                          firebase_storage
                                              .FirebaseStorage.instance
                                              .ref('/billsImages/' +
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch
                                                      .toString());
                                      firebase_storage.UploadTask uploadTask =
                                          ref.putFile(_image!.absolute);
                                      Future.value(uploadTask)
                                          .then((value) async {
                                        var newUrl = await ref.getDownloadURL();
                                        await FirebaseFirestore.instance
                                            .collection("usersData")
                                            .doc(user?.uid)
                                            .collection("notes")
                                            .doc()
                                            .set({
                                          "Note": note,
                                          "Amount": amount,
                                          "BillImageUrl": newUrl.toString(),
                                          "CreatedAt": DateTime.now(),
                                          "UserId": user?.uid
                                        }).then((value) {
                                          noteController.clear();
                                          amountController.clear();
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              NotesHomePage()),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        });
                                      });
                                    },
                                  );
                                  return AlertDialog(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    titlePadding: EdgeInsets.zero,
                                    content: Container(
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                            child: Text("Please Wait..."))),
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text("Add Note")),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  height: 500,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("usersData")
                        .doc(user?.uid)
                        .collection("notes")
                        .where("UserId", isEqualTo: user?.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      print("firebase call data");
                      if (snapshot.hasError) {
                        print("hassError");
                        return const Text("something went wromg");
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        print("firebase Waiting");
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        print("firebase Done ?");
                        return ListView.builder(
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            var userID = snapshot.data?.docs[index]["UserId"];
                            var notes = snapshot.data?.docs[index]["Note"];
                            var amount = snapshot.data?.docs[index]["Amount"];
                            var billImage =
                                snapshot.data?.docs[index]["BillImageUrl"];

                            DateTime? myDateTime;
                            if (snapshot.data?.docs[index]["CreatedAt"] !=
                                null) {
                              myDateTime = (snapshot
                                  .data?.docs[index]['CreatedAt']
                                  .toDate());
                            }

                            var docId = snapshot.data?.docs[index].id;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text("Note : ${notes ?? ""}",style: TextStyle(fontSize: 20),),
                                    leading: Container(
                                      height: 100,
                                      width: 100,
                                      child: Image.network(
                                        billImage ?? "",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    trailing: Container(
                                      width: 80,
                                      height: 50,
                                      child: Row(
                                        children: [
                                          InkWell(
                                              onTap: () async {
                                                Get.to(() => EditNotes(),
                                                    arguments: {
                                                      "UserId": userID,
                                                      "Note": notes,
                                                      "Amount": amount,
                                                      "docId": docId,
                                                      "BillImageUrl": billImage,
                                                    });
                                              },
                                              child: Icon(
                                                Icons.edit,
                                                size: 30,
                                              )),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                FirebaseFirestore.instance
                                                    .collection("usersData")
                                                    .doc(userID)
                                                    .collection("notes")
                                                    .doc(docId)
                                                    .delete();
                                                setState(() {});
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                size: 30,
                                              )),
                                        ],
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Rs : ${amount ?? ""}",style: TextStyle(fontSize: 18)),
                                        Text(
                                            "Date : ${DateFormat('dd MMMM yyyy hh:mm').format(DateTime.parse(myDateTime.toString()))}",style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    onTap: () async {
                                      // await  FirebaseFirestore.instance.collection("notes").doc(docId).update({
                                      //   "Note" : "ORS"
                                      // });
                                      // setState((){});
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

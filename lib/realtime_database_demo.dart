import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class RealTimeDatabase extends StatefulWidget {
  const RealTimeDatabase({Key? key}) : super(key: key);

  @override
  State<RealTimeDatabase> createState() => _RealTimeDatabaseState();
}

class _RealTimeDatabaseState extends State<RealTimeDatabase> {
  final databaseRef = FirebaseDatabase.instance.ref('Notes');

  final noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Realtime Database",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              child: TextFormField(
                controller: noteController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Amount"),
              ),
            ),
            InkWell(onTap: (){
              String id  = DateTime.now().millisecondsSinceEpoch.toString() ;
              databaseRef.child(id).set({
                'Notes' : noteController.text.toString() ,
                'id' : id
              }).then((value){
                print("Notes uploaded");
                noteController.clear();
              }).onError((error, stackTrace){
                print("post Error $error");
              });
            },
              child: Container(
              height: 50,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text("Add Note")),
            ),),
            Container(
              height: 500,
              child: FirebaseAnimatedList(query:databaseRef , itemBuilder: (context, snapshot, animation, index){
                return ListTile(
                  trailing: IconButton(onPressed: (){
                    databaseRef.child(snapshot.child('id').value.toString()).remove();
                  }, icon: Icon(Icons.delete)),
                  onTap: (){

                    // databaseRef.child(snapshot.child('id').value.toString()).update(
                    //     {
                    //       'Notes' : 'nice world'
                    //     });
                  },
                  title: Text(snapshot.child('Notes').value.toString()),
                  subtitle: Text(snapshot.child('id').value.toString()),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}

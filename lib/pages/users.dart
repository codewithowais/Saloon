import 'dart:async';

import 'package:beautysalon/helper/stoarage_helper.dart';
import 'package:beautysalon/pages/login.dart';
import 'package:beautysalon/pages/chatting.dart';
import 'package:beautysalon/pages/profile.dart';
import 'package:beautysalon/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatUser extends StatefulWidget {
  const ChatUser({Key? key}) : super(key: key);

  @override
  _ChatUserState createState() => _ChatUserState();
}

class _ChatUserState extends State<ChatUser> {
  String imageurl = "";
  String currentuser = "";
  final Storage storageobj = Storage();
  final _auth = FirebaseAuth.instance.currentUser!;
  getChatRoomId(String a, String b) {
    // a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)
    if (true) {
      String first = a + "_" + b;
      String second = b + "_" + a;
      print(first);
      print(second);
      print(a);
      print(b);
      print("asd");
      return "$a\_$b";
    } else {
      print(a);
      print(b);
      print("dsd");
      return "$b\_$a";
    }
  }

  String chatRoomId = "";

  addData(context, currentuser, usertosend, sendto, profiledata) async {
    chatRoomId = "${currentuser}_${usertosend}";

    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('chatRoom');

    Future<void> getData() async {
      QuerySnapshot querySnapshot = await _collectionRef.get();
      final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      if (allData.toString().contains("${currentuser}_${usertosend}") ==
              false &&
          allData.toString().contains("${usertosend}_${currentuser}") ==
              false) {
        print("true");
        List<String> users = [currentuser, usertosend];

        chatRoomId = getChatRoomId(currentuser, usertosend);
        Map<String, dynamic> chatRoom = {
          "users": users,
          "chatRoomId": chatRoomId,
        };
        await FirebaseFirestore.instance
            .collection("chatRoom")
            .doc(chatRoomId)
            .set(chatRoom)
            .catchError((e) {
          print(e);
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                  sendto: sendto,
                  currentuseremail: currentuser,
                  sendtoemail: usertosend,
                  chatRoom: chatRoomId,
                  profile: profiledata)),
        );
      } else if ((allData
              .toString()
              .contains("${currentuser}_${usertosend}")) ==
          true) {
        setState(() {
          chatRoomId = "${currentuser}_${usertosend}";
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                  sendto: sendto,
                  currentuseremail: currentuser,
                  sendtoemail: usertosend,
                  chatRoom: chatRoomId,
                  profile: profiledata)),
        );
      } else if ((allData
              .toString()
              .contains("${usertosend}_${currentuser}")) ==
          true) {
        setState(() {
          chatRoomId = "${usertosend}_${currentuser}";
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                  sendto: sendto,
                  currentuseremail: currentuser,
                  sendtoemail: usertosend,
                  chatRoom: chatRoomId,
                  profile: profiledata)),
        );
      }
      print(chatRoomId);
    }

    getData();
    // print(chatRoomId);
  }

  signOut() async {
    try {
      return await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentuser = "${_auth.email}";
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/images/default.jpeg"),
                fit: BoxFit.cover,
              )),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: UIData.mainColor,
                  fontSize: 12,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            InkWell(
              onTap: () {
                signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: UIData.mainColor),
        elevation: 0,
        backgroundColor: UIData.lightColor,
        title: Text(
          "Messages",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UIData.mainColor),
        ),
      ),
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.06,
                    left: MediaQuery.of(context).size.width * 0.06,
                    right: MediaQuery.of(context).size.width * 0.06),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                          MediaQuery.of(context).size.width * 0.1),
                      bottomRight: Radius.circular(
                          MediaQuery.of(context).size.width * 0.1)),
                  color: UIData.lightColor,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.width * 0.01,
                              right: MediaQuery.of(context).size.width * 0.01,
                              left: MediaQuery.of(context).size.width * 0.01),
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.06,
                            backgroundColor: UIData.mainColor,
                            child: Icon(Icons.add),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.73,
                          height: 50,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('user_detail')
                                .where('email', isNotEqualTo: currentuser)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text("Error");
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(child: Text(""));
                              }

                              return ListView(
                                scrollDirection: Axis.horizontal,
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  return Padding(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.01),
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: StreamBuilder(
                                        stream: Storage().downloadedUrl(
                                            '${data['profile']}'),
                                        builder: (context,
                                            AsyncSnapshot<String> snap) {
                                          if (snap.hasError) {
                                            return Text("Error");
                                          } else if (snap.connectionState ==
                                                  ConnectionState.done &&
                                              snap.hasData) {
                                            return InkWell(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Imageprofile(
                                                              profileimage:
                                                                  '${snap.data!}'))),
                                              child: CircleAvatar(
                                                  backgroundColor:
                                                      UIData.mainColor,
                                                  backgroundImage: NetworkImage(
                                                    snap.data!,
                                                  )),
                                            );
                                            //Container(width: 300,height: 450,
                                            // child: Image.network(snap.data!,
                                            // fit: BoxFit.cover,),

                                          }
                                          if (snap.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircleAvatar(
                                                backgroundColor:
                                                    UIData.mainColor,
                                                backgroundImage: AssetImage(
                                                  "assets/images/default.jpeg",
                                                ));
                                          }
                                          return Container();
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01),
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25.7)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25.7)),
                          hintText: 'Enter a search term',
                          prefixText: ' ',
                          suffixText: 'Go',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: UIData.mainColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user_detail')
                      .where('email', isNotEqualTo: currentuser)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error");
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Image(
                          image: AssetImage("images/logo.png"),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.00,
                          right: MediaQuery.of(context).size.width * 0.0),
                      child: ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return Container(
                            child: InkWell(
                              onTap: () {
                                addData(
                                    context,
                                    currentuser,
                                    '${data['email']}',
                                    '${data['username']}',
                                    '${data['profile']}');
                              },
                              child: ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: StreamBuilder(
                                    stream: Storage()
                                        .downloadedUrl('${data['profile']}'),
                                    builder:
                                        (context, AsyncSnapshot<String> snap) {
                                      if (snap.hasError) {
                                        return Text("Error");
                                      } else if (snap.connectionState ==
                                              ConnectionState.done &&
                                          snap.hasData) {
                                        return CircleAvatar(
                                            backgroundColor: UIData.mainColor,
                                            backgroundImage: NetworkImage(
                                              snap.data!,
                                            ));
                                        //Container(width: 300,height: 450,
                                        // child: Image.network(snap.data!,
                                        // fit: BoxFit.cover,),

                                      }
                                      if (snap.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircleAvatar(
                                            backgroundColor: UIData.mainColor,
                                            backgroundImage: AssetImage(
                                              "assets/images/default.jpeg",
                                            ));
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                                //  CircleAvatar(
                                //   child: Icon(Icons.beach_access),
                                // ),
                                title: Text(
                                  data['username'],
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  data['email'],
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "12:00 am",
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.008),
                                      child: const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Color(0xFF1F1A30),
                                        child: Text(
                                          '1',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              //   Expanded(
              //     child: FutureBuilder(
              //       future: Storage()
              //           .downloadedUrl('a@gmail.com/IMG_20220112_113426.jpg'),
              //       builder: (BuildContext context, AsyncSnapshot<String> snap) {
              //         if (snap.hasError) {
              //           return Text("Error");
              //         } else if (snap.connectionState == ConnectionState.done &&
              //             snap.hasData) {
              //           return Expanded(
              //             child: ListView.builder(
              //                 itemCount: 1,
              //                 itemBuilder: (BuildContext context, index) {
              //                   return Text(
              //                     "${snap.data!}",
              //                   );
              //                   // CircleAvatar(
              //                   //   backgroundImage: NetworkImage(
              //                   //     snap.data!,
              //                   //   ),
              //                 }),
              //           );
              //           //Container(width: 300,height: 450,
              //           // child: Image.network(snap.data!,
              //           // fit: BoxFit.cover,),

              //         }
              //         if (snap.connectionState == ConnectionState.waiting) {
              //           return Center(child: CircularProgressIndicator());
              //         }
              //         return Container();
              //       },
              //     ),
              //   )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jaappalante/service/firebase/auth.dart';
import 'package:jaappalante/utils/global.colors.dart';
import 'package:jaappalante/view/MainNavigationPage.dart';
import 'package:jaappalante/view/widgets/message.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final CollectionReference myNotifs =
      FirebaseFirestore.instance.collection('notification');

  final User? user = Auth().currentUser;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          foregroundColor: GlobalColors.mainColor,
          backgroundColor: Colors.grey[300],
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MainNavigationPage()),
              );
            },
          ),
          title: const Text("Notifications"),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search notications",
                    fillColor: Colors.black12,
                    filled: true,
                    contentPadding: EdgeInsets.all(16.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                  child: ListView(children: [
                StreamBuilder<QuerySnapshot>(
                  stream: myNotifs
                      .where('userId', isEqualTo: user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Erreur: ${snapshot.error}"));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("Aucun message"));
                    } else {
                      return Column(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          final data = document.data() as Map<String, dynamic>;

                          return Message(
                            message: data['message'] ?? "Error message",
                            time: data['time'] ?? "Error time",
                            image: data['image'] ?? "Error image",
                            name: data['name'] ?? "Error name",
                            lastName: data['lastName'] ?? "Error lastName",
                            firstName: data['firstName'] ?? "Error firstName",
                            idNotif: document.id,
                            phoneNumber:
                                data['phoneNumber'] ?? "Error phoneNumber",
                            serviceId: data['serviceId'] ?? "Error serviceId",
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ]))
            ],
          ),
        ),
      ),
    );
  }
}


// child: ListView.separated(
//                       itemBuilder: (context, index) {
//                         return 
                        // Message(
                        //   message: 'demande de realisation de service',
                        //   time: '10:00',
                        //   image: './assets/images/logo.jpg',
                        //   name: 'Ali mar',
                        // );
//                       },
//                       separatorBuilder: (context, index) => Divider(
//                             color: Colors.grey[400],
//                             indent: size.width * .88,
//                             endIndent: size.width * .88,
//                           ),
//                       itemCount: 10)

// ListView.builder(
//   itemCount: 10,
//   itemBuilder: (context, index) {
//     return Message(
//       message: 'Message numéro ${index + 1}',
//       time: '${9 + index}:00',
//       image: './assets/images/user${index + 1}.jpg',
//       name: 'Utilisateur ${index + 1}',
//     );
//   },
// )


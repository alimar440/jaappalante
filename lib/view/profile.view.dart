import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jaappalante/view/change_profile.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  String firstName = "";
  String lastName = "";
  String imageUrl = "empty.jpg";
  bool isLoading = true;
  String? error;

  Future<void> deleteService(String serviceId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service supprimé avec succès.'),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (userId.isEmpty) {
        throw Exception('ID utilisateur non valide');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          setState(() {
            firstName = data['firstName'] ?? 'Inconnu';
            lastName = data['lastName'] ?? 'Inconnu';
            imageUrl = data['photoUrl'] ?? 'Inconnu';
            isLoading = false;
          });
        } else {
          throw Exception('Données utilisateur invalides');
        }
      } else {
        throw Exception('Aucun document trouvé pour cet utilisateur');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = "Erreur lors de la récupération des données: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: fetchUserData,
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/$imageUrl'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Container(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: DecorationImage(
                          image: AssetImage('assets/images/menage.jgp'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 108,
                      bottom: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 34, 76, 115),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 18.0,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 77),
        Center(
          child: Column(
            children: [
              Text(
                "$firstName $lastName",
                style: TextStyle(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 13, 33, 68),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/$imageUrl'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            image: DecorationImage(
                              image: AssetImage('assets/images/$imageUrl'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 108,
                          bottom: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 34, 76, 115),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 18.0,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 77,
            ),
            Center(
              child: Column(
                children: [
                  Container(
                      child: Text(
                    "$firstName $lastName",
                    style: TextStyle(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 13, 33, 68),
                      letterSpacing: 1.5,
                    ),
                  )),
                  SizedBox(
                    height: 4,
                  ),
                  Center(
                    child: Column(children: [
                      Text(
                        "etudiant",
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                            size: 20.0,
                          ),
                          Text(
                            "dakar/rufisque",
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "classement",
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "     8.2  ",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Icon(Icons.star, color: Colors.amber, size: 26.0),
                          Icon(Icons.star, color: Colors.amber, size: 26.0),
                          Icon(Icons.star, color: Colors.amber, size: 26.0),
                          Icon(Icons.star_half,
                              color: Colors.amber, size: 26.0),
                          Icon(Icons.star_border,
                              color: Colors.amber, size: 26.0),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 13, 33, 68)),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Change_Profile(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                            )),
                  );
                },
                child: const Text(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  'Personaliser',
                ),
              ),
              SizedBox(
                width: 16,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 13, 33, 68)),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Change_Profile(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                            )),
                  );
                },
                child: const Text(
                  'Cliquez ici',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Mes Postes'),
                      Tab(text: 'Recents'),
                    ],
                    labelColor: Colors.black,
                  ),
                  Container(
                    height: 300,
                    child: TabBarView(
                      children: [
                        _buildPhotoGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildPhotoGrid() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('services')
          .where('userId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucun service trouvé.'));
        }

        final services = snapshot.data!.docs;
        print('Nombre de services récupérés: ${services.length}');
        for (var doc in services) {
          print('Données du service: ${doc.data()}');
        }

        return SizedBox(
          height: 300,
          child: GridView.count(
            crossAxisCount: 3,
            padding: EdgeInsets.all(16),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: services.map((DocumentSnapshot document) {
              final data = document.data() as Map<String, dynamic>;
              final imageUrl = data['image'] ?? '';
              final title = data['titre'] ?? 'Titre inconnu';
              final price = data['price'] ?? 'Prix inconnu';
              final description = data['description'] ?? 'Description inconnue';
              final category = data['category'] ?? 'Catégorie inconnue';
              final serviceId = document.id;

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(title),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/$imageUrl',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              ),
                              SizedBox(height: 16),
                              Text('Prix: $price'),
                              SizedBox(height: 8),
                              Text('Catégorie: $category'),
                              SizedBox(height: 8),
                              Text('Description: $description'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmer la suppression'),
                                    content: Text(
                                        'Voulez-vous vraiment supprimer ce service ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text('Supprimer'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDelete == true) {
                                await deleteService(serviceId, context);
                              }
                            },
                            child: Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Fermer'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage('assets/images/$imageUrl'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:jaappalante/service/firebase/auth.dart';
import 'package:jaappalante/utils/card_service.dart';
import 'package:jaappalante/utils/category_box.dart';
import 'package:jaappalante/utils/global.colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final User? user = Auth().currentUser;

  final String userId = Auth().currentUser!.uid;

  String firstName = "";
  String photoUrl = "";
  String lastName = "";
  bool isLoading = true;
  String? error;

  final double horizontalPadding = 40;
  final double verticalPadding = 25;

  List myCategories = [
    ["Shopping", Icons.shopping_cart, true],
    ["Menage", Icons.cleaning_services, false],
    ["Reparation", Icons.build, false],
    ["Autre", Icons.shopping_cart, false]
  ];
  List options = ['Shopping', 'Menage', 'Reparation', 'Autre'];
  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String selectedCategory = 'Ménage';

  Future<void> create() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return myDialogBox(
              name: "Ajouter service",
              condition: "Ajouter",
              onPressed: () {
                String titre = titreController.text;
                String description = descriptionController.text;
                String image = imageController.text;
                String category = selectedCategory;
                int price = int.parse(priceController.text);
                addItems(titre, description, image, category, price);
                Navigator.pop(context);
              });
        });
  }

  void addItems(String titre, String description, String image, String category,
      int price) {
    final User? user = Auth().currentUser;

    if (category == "Menage") {
      image = "clean.jpg";
    } else if (category == "Reparage") {
      image = "Reparage.jpg";
    } else if (category == "Shopping") {
      image = "shopping.jpg";
    } else if (category == "Autre") {
      image = "Autre.jpg";
    }

    myItems.add({
      'titre': titre,
      'description': description,
      'image': image,
      'category': category,
      'price': price,
      'userId': user?.uid,
      'createdAt': Timestamp.now(),
    });
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
            photoUrl = data['photoUrl'] ?? 'Inconnu';
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

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('services');

  void powerSwitchChanged(bool value, int index) {
    setState(() {
      myCategories[index][2] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: create,
        backgroundColor: GlobalColors.mainColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      // bottomNavigationBar: Container(
      //   color: Colors.black,
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
      //     child: GNav(
      //         backgroundColor: GlobalColors.mainColor,
      //         color: Colors.white,
      //         activeColor: Colors.white,
      //         tabBackgroundColor: Colors.grey.shade800,
      //         padding: EdgeInsets.all(16),
      //         gap: 8,
      //         onTabChange: (index) {
      //           setState() {
      //             // _selectedIndex = index;
      //           }
      //         },

      //         tabs: const [
      //           GButton(
      //             icon: Icons.home,
      //             text: 'Home',
      //           ),
      //           GButton(
      //             icon: Icons.notifications,
      //             text: 'Notif',
      //           ),
      //           GButton(
      //             icon: Icons.search,
      //             text: 'recherche',
      //           ),
      //           GButton(icon: Icons.person, text: 'Profil'),
      //         ]),
      //   ),
      // ),

      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.search,
                      size: 45,
                      color: GlobalColors.mainColor,
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      iconSize: 45,
                      color: GlobalColors.mainColor,
                      tooltip: 'Déconnexion',
                      onPressed: () async {
                        bool? confirmLogout = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Déconnexion'),
                            content:
                                Text('Voulez-vous vraiment vous déconnecter ?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Se déconnecter'),
                              ),
                            ],
                          ),
                        );

                        await Auth().logout();
                      },
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to Home",
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                    Text(
                      " $firstName $lastName",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 72,
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  "Categories",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
                ),
              ),

              // Categories Grid
              SizedBox(
                height: 500,
                child: GridView.builder(
                  itemCount: myCategories.length,
                  padding: const EdgeInsets.all(25.0),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.3,
                  ),
                  itemBuilder: (context, index) {
                    return CategoryBox(
                      categoryName: myCategories[index][0],
                      categoryIcon: myCategories[index][1],
                      powerOn: myCategories[index][2],
                      onChanged: (value) => powerSwitchChanged(value, index),
                    );
                  },
                ),
              ),
              // Container(
              //   child: ,
              // )
              // Conditional Buttons
              if (myCategories[0][2] ||
                  myCategories[1][2] ||
                  myCategories[2][2] ||
                  myCategories[3][2])
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    height: 700,
                    width: double.infinity,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding),
                      child: ListView(
                        children: [
                          for (var category in myCategories)
                            if (category[2])
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(category[1], size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          category[0],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: myItems
                                        .where('category',
                                            isEqualTo: category[0])
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                "Erreur: ${snapshot.error}"));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return Center(
                                            child: Text(
                                                "Aucun élément trouvé pour ${category[0]}"));
                                      } else {
                                        return Column(
                                          children: snapshot.data!.docs
                                              .where(
                                                  (DocumentSnapshot document) =>
                                                      document['userId'] !=
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid)
                                              .map((DocumentSnapshot document) {
                                            final data = document.data()
                                                as Map<String, dynamic>;
                                            return ServiceCard(
                                              title: data['titre'] ??
                                                  'Titre non disponible',
                                              category: data['category'] ??
                                                  'Catégorie non disponible',
                                              description: data[
                                                      'description'] ??
                                                  'Description non disponible',
                                              imageUrl: data['image'] ??
                                                  'https://via.placeholder.com/150',
                                              price: (data['price'] ?? 0)
                                                  .toDouble(),
                                              serviceId: document.id,
                                              firstName: firstName ??
                                                  "erreur first name",
                                              lastName: lastName ??
                                                  "erreur last name",
                                              photoUrl: photoUrl ??
                                                  "erreur photo url",
                                            );
                                          }).toList(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Dialog myDialogBox({
    required String name,
    required String condition,
    required VoidCallback onPressed,
  }) =>
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),

                      // Champ Titre
                      TextField(
                        controller: titreController,
                        decoration: InputDecoration(
                          labelText: 'Titre',
                          hintText: 'Entrez le titre du service',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Champ Description

                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Entrez la description du service',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Champ Prix
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Prix',
                          hintText: 'Entrez le prix du service',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Sélection de la catégorie
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Catégorie',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('Ménage'),
                            value: 'Ménage',
                            groupValue: selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text('Réparage'),
                            value: 'Réparage',
                            groupValue: selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text('Shopping'),
                            value: 'Shopping',
                            groupValue: selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text('Autre'),
                            value: 'Autre',
                            groupValue: selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 15),

                      // Bouton de validation
                      ElevatedButton(
                        onPressed: () {
                          print('Catégorie sélectionnée : $selectedCategory');
                          onPressed();
                        },
                        child: Text(condition),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
}

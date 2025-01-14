import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final double price;
  final String serviceId;
  final String firstName;
  final String lastName;
  final String photoUrl;

  const ServiceCard({
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.serviceId,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
  });

  // Fonction pour ajouter une notification
  void addNotif(String serviceId) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Récupérer l'ID de l'utilisateur propriétaire du service
        DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
            .collection('services')
            .doc(serviceId)
            .get();

        String userId = "";
        if (serviceDoc.exists) {
          userId = serviceDoc.get('userId') ?? "User ID manquant";
        }

        // Ajouter une notification dans Firestore
        final CollectionReference myNotifs =
            FirebaseFirestore.instance.collection('notification');

        await myNotifs.add({
          'demandantId': user.uid,
          'firstName': firstName,
          'lastName': lastName,
          'image': photoUrl,
          'serviceId': serviceId,
          'message': 'Demande de réalisation du service "$title"',
          'time': Timestamp.now(),
          'userId': userId,
        });

        print('Notification ajoutée avec succès pour le service $serviceId');
      }
    } catch (e) {
      print("Erreur lors de l'ajout de la notification : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Afficher un AlertDialog avec les détails du service
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image du service
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/$imageUrl',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image, color: Colors.grey[500]),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Catégorie: $category'),
                    SizedBox(height: 8),
                    Text('Description: $description'),
                    SizedBox(height: 8),
                    Text('Prix: $price FCFA'),
                  ],
                ),
              ),
              actions: [
                // Bouton pour passer une demande
                TextButton(
                  onPressed: () async {
                    // Confirmation avant suppression
                    bool confirmRequest = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmer la demande'),
                          content: Text(
                              'Voulez-vous vraiment passer une demande pour ce service ?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // Annuler
                              },
                              child: Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Confirmer
                              },
                              child: Text('Confirmer'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmRequest == true) {
                      // Appeler la fonction addNotif
                      addNotif(serviceId);

                      // Simuler un délai de traitement
                      await Future.delayed(Duration(seconds: 1));

                      // Afficher une boîte de dialogue de succès
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Demande passée'),
                            content: Text(
                                'Votre demande de réalisation du service a été passée avec succès.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Fermer la boîte de dialogue
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    'Passer une demande',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                // Bouton Fermer
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                  child: Text('Fermer'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du service
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                'assets/images/$imageUrl',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[500]),
                  );
                },
              ),
            ),

            // Contenu de la carte
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),

                  // Catégorie
                  Text(
                    "Catégorie: $category",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),

                  // Prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Prix: $price FCFA",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.shopping_cart, color: Colors.blue),
                        onPressed: () async {
                          // Afficher une boîte de dialogue de confirmation
                          bool confirmRequest = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmer la demande'),
                                content: Text(
                                    'Voulez-vous vraiment passer une demande pour ce service ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(false); // Annuler
                                    },
                                    child: Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(true); // Confirmer
                                    },
                                    child: Text('Confirmer'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmRequest == true) {
                            // Ajouter une notification
                            addNotif(serviceId);

                            // Simuler un délai de traitement
                            await Future.delayed(Duration(seconds: 1));

                            // Afficher une boîte de dialogue de succès
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Demande passée'),
                                  content: Text(
                                      'Votre demande de réalisation du service a été passée avec succès.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Fermer la boîte de dialogue
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

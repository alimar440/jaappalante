import 'package:flutter/material.dart';
import 'package:jaappalante/service/firebase/auth.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: camel_case_types
class Change_Profile extends StatefulWidget {
  final String userId;
  const Change_Profile({Key? key, required this.userId}) : super(key: key);

  @override
  State<Change_Profile> createState() => _Change_Profile();
}

class _Change_Profile extends State<Change_Profile> {
  var showPass = true;
  final _formKey = GlobalKey<FormState>();
  final Auth _authService = Auth();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _numero = TextEditingController();
  String imageUrl = "empty.jpg";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _prenomController.dispose();
    _nomController.dispose();
    _numero.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (!mounted) return;
        setState(() {
          _prenomController.text = data?['firstName'] ?? '';
          _nomController.text = data?['lastName'] ?? '';
          _emailController.text = data?['email'] ?? '';
          _numero.text = data?['phoneNumber'] ?? '';
          imageUrl = data?['photoUrl'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception("Utilisateur introuvable.");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des données: $e")),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Veuillez remplir tous les champs correctement")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Vérifier que l'utilisateur est connecté
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Utilisateur non connecté");
      }

      // Mettre à jour le profil dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'firstName': _prenomController.text.trim(),
        'lastName': _nomController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _numero.text.trim(),
      });

      if (currentUser.email != _emailController.text.trim()) {
        await currentUser.updateEmail(_emailController.text.trim());
      }

      if (_passwordController.text.isNotEmpty) {
        await currentUser.updatePassword(_passwordController.text);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil mis à jour avec succès !")),
      );

      Navigator.pop(context);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "Cette adresse email est déjà utilisée.";
          break;
        case 'weak-password':
          message = "Le mot de passe est trop faible.";
          break;
        case 'requires-recent-login':
          message = "Veuillez vous reconnecter pour effectuer cette action.";
          break;
        default:
          message = "Une erreur est survenue: ${e.message}";
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur inattendue: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Modifier Profil',
          style: TextStyle(
            fontSize: 22,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 13, 33, 68),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 13, 33, 68)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Stack(
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
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 34, 76, 115),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 18.0,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // Implémenter la logique de changement de photo
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: _prenomController,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 13, 33, 68),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 13, 33, 68),
                          ),
                          hintText: "Votre Prénom",
                          labelText: "Prénom",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le prénom est obligatoire';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 13, 33, 68),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Color.fromARGB(255, 13, 33, 68),
                          ),
                          hintText: "Votre Nom",
                          labelText: "Nom",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le nom est obligatoire';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 13, 33, 68),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color.fromARGB(255, 13, 33, 68),
                          ),
                          hintText: "Votre Email",
                          labelText: "Email",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "L'email est obligatoire";
                          }
                          if (!value.contains('@')) {
                            return "Veuillez entrer un email valide";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: showPass,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 13, 33, 68),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color.fromARGB(255, 13, 33, 68),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color.fromARGB(255, 13, 33, 68),
                            ),
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                          ),
                          hintText: "Nouveau mot de passe (optionnel)",
                          labelText: "Mot de passe",
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _numero,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 13, 33, 68),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.phone,
                            color: Color.fromARGB(255, 13, 33, 68),
                          ),
                          hintText: "Pour vous",
                          labelText: "Téléphone",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le numéro de téléphone est obligatoire';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 13, 33, 68),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Sauvegarder les changements',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
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

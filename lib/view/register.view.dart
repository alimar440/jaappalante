import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jaappalante/service/firebase/auth.dart';
import 'package:jaappalante/utils/global.colors.dart';
import 'package:jaappalante/view/MainNavigationPage.dart';
import 'package:jaappalante/view/login.view.dart';
import 'package:jaappalante/view/profile.view.dart';
import 'package:jaappalante/view/widgets/social.login.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  var showPass = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final Auth _authService = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Image.asset("assets/images/logo.jpg"),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.withOpacity(0.5),
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 0.3,
                            color: const Color.fromARGB(255, 201, 211, 219),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    TextFormField(
                        controller: _prenomController,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      const Color.fromARGB(255, 57, 142, 211),
                                  width: 2)),
                          prefixIcon: Icon(
                            Icons.account_circle,
                            color: GlobalColors.mainColor,
                          ),
                          hintText: "Votre Prenom",
                          labelText: "Prenom",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'votre Prenom est obligatoire !';
                          } else {
                            return null;
                          }
                        }),
                    SizedBox(
                      height: 13,
                    ),
                    TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      const Color.fromARGB(255, 57, 142, 211),
                                  width: 2)),
                          prefixIcon: Icon(
                            Icons.account_circle,
                            color: GlobalColors.mainColor,
                          ),
                          hintText: "Votre Nom",
                          labelText: "nom",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'votre nom est obligatoire !';
                          } else {
                            return null;
                          }
                        }),
                    SizedBox(
                      height: 13,
                    ),
                    TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email_sharp,
                              color: GlobalColors.mainColor,
                            ),
                            hintText: "Votre Email",
                            labelText: "Email",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 57, 142, 211),
                                    width: 2))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "l'email est obligatoire !";
                          } else {
                            return null;
                          }
                        }),
                    SizedBox(
                      height: 13,
                    ),
                    TextFormField(
                        controller: _passwordController,
                        obscureText: showPass,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: GlobalColors.mainColor, width: 2)),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: GlobalColors.mainColor,
                          ),
                          hintText: "Creer un Mot De Passe",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                            icon: Icon(
                              Icons.remove_red_eye_sharp,
                              color: GlobalColors.mainColor,
                            ),
                          ),
                          labelText: "Mot de passe",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'mot de passe obligatoire !';
                          } else {
                            return null;
                          }
                        }),
                    SizedBox(
                      height: 13,
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: showPass,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: GlobalColors.mainColor, width: 2)),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: GlobalColors.mainColor,
                        ),
                        hintText: "Confirmer Votre Mot De Passe",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPass = !showPass;
                            });
                          },
                          icon: Icon(
                            Icons.remove_red_eye_sharp,
                            color: GlobalColors.mainColor,
                          ),
                        ),
                        labelText: "Confirmer Mot de passe",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'champ obligatoire !';
                        } else if (value != _passwordController.text) {
                          return 'les mots de passe ne sont pas identique !';
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          String email = _emailController.text.trim();
                          String password = _passwordController.text.trim();
                          String firstName = _prenomController.text.trim();
                          String lastName = _nomController.text.trim();

                          if (_formKey.currentState!.validate()) {
                            try {
                              User? user = await _authService
                                  .registerWithEmailAndPassword(
                                email,
                                password,
                                firstName,
                                lastName,
                              );

                              if (user != null) {
                                await Auth()
                                    .loginwithEmailAndPassword(email, password);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Inscription réussie ! Bienvenue, ${user.displayName}')),
                                );

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MainNavigationPage(),
                                    ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Échec de l\'inscription, veuillez réessayer.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Erreur lors de l\'inscription : $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlobalColors.mainColor,
                          foregroundColor: Colors.white,
                          elevation: 5,
                        ),
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(
                              fontSize: 18, fontStyle: FontStyle.normal),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                          thickness: 0.5,
                        )),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Ou continuez avec"),
                        ),
                        Expanded(
                            child: Divider(
                          thickness: 0.5,
                        ))
                      ],
                    ),
                  ],
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          SocialLogin(),
          const SizedBox(
            height: 30,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginView()),
              );
            },
            child: Row(
              children: [
                Text("Déjà un compte?", style: TextStyle(color: Colors.black)),
                Text(
                  " Se connecter",
                  style: TextStyle(color: GlobalColors.mainColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

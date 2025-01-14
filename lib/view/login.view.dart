import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jaappalante/service/firebase/auth.dart';
import 'package:jaappalante/utils/global.colors.dart';
import 'package:jaappalante/view/register.view.dart';
import 'package:jaappalante/view/widgets/social.login.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                
                Image.asset(
                  "assets/images/logo.jpg",
                  scale: 2,
                  height: 65,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Sign in",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 40,
                    color: GlobalColors.mainColor,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Sign in now to accept your opportunities",
                  style: TextStyle(
                    color: GlobalColors.mainColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                // Email TextField
                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: GlobalColors.mainColor,
                      ),
                      labelStyle: TextStyle(color: GlobalColors.textColor),
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: GlobalColors.mainColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse email valide';
                      } else {
                        return null;
                      }
                    }),
                const SizedBox(
                  height: 20,
                ),
                // Password TextField
                TextFormField(
                    keyboardType: TextInputType.text,
                    controller: passwordcontroller,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: GlobalColors.textColor),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: GlobalColors.mainColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: GlobalColors.mainColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      hintText: 'Entrer votre mot de passe',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: GlobalColors.mainColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer votre mot de passe";
                      } else {
                        return null;
                      }
                    }),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Mot de passe oublié ? ",
                      style: TextStyle(
                          color: GlobalColors.textColor, fontSize: 17),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SocialLogin(),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            await Auth().loginwithEmailAndPassword(
                              emailcontroller.text,
                              passwordcontroller.text,
                            );
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${e.message}"),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                              ),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.mainColor,
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 80),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Log In",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () {
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterView()),
                    );
                  },
                  child: Row(
                    children: 
                    [
                      
                      Text("Si vous n'avez pas de compte,", style: TextStyle(color: Colors.black)),
                      Text(
                        " cliquez ici",
                      style: TextStyle(color: GlobalColors.mainColor),
                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

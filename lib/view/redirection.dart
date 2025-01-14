import 'package:flutter/material.dart';
import 'package:jaappalante/service/firebase/auth.dart';
import 'package:jaappalante/view/mainNavigationPage.dart';
import 'package:jaappalante/view/login.view.dart';

class RedirectionView extends StatefulWidget {
  const RedirectionView({super.key});

  @override
  State<RedirectionView> createState() => _RedirectionViewState();
}

class _RedirectionViewState extends State<RedirectionView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStatechanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return MainNavigationPage();
          } else {
            return LoginView();
          }
        });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaappalante/utils/global.colors.dart';

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Texte d'invite
        Text(
          'Ou se connecter avec :',
          style: TextStyle(
              color: GlobalColors.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 17),
        ),
        const SizedBox(height: 15),

        // Ligne des boutons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton Google
            _buildSocialButton(
              assetPath: 'assets/images/google.png',
              label: 'Google',
            ),
            const SizedBox(width: 10),

            // Bouton Facebook
            _buildSocialButton(
              assetPath: 'assets/images/facebook.png',
              label: 'Facebook',
            ),
            const SizedBox(width: 10),

            // Bouton Twitter
            _buildSocialButton(
              assetPath: 'assets/images/twitter.png',
              label: 'Twitter',
            ),
          ],
        ),
      ],
    );
  }

  // Widget pour les boutons sociaux
  Widget _buildSocialButton(
      {required String assetPath, required String label}) {
    return Expanded(
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SvgPicture.asset(
          assetPath,
          height: 35,
          semanticsLabel: label,
        ),
      ),
    );
  }
}

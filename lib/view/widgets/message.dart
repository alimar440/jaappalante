import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Message extends StatelessWidget {
  final String message;
  final Timestamp time;
  final String image;
  final String name;
  final String firstName;
  final String lastName;
  final String idNotif;
  final String serviceId;
  final String phoneNumber;

  const Message({super.key, 
    required this.message,
    required this.time,
    required this.image,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.idNotif,
    required this.serviceId,
    required this.phoneNumber,
  });

  Future<void> deleteNotif(String notifId) async {
    try {
      final CollectionReference notifications =
          FirebaseFirestore.instance.collection('notification');

      await notifications.doc(notifId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de la notification : $e');
      }
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      // Référence à la collection 'notification'
      final CollectionReference notifications =
          FirebaseFirestore.instance.collection('service');

      // Suppression de la notification par son ID
      await notifications.doc(serviceId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de la notification : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Slidable(
        endActionPane: ActionPane(motion: const ScrollMotion(), children: [
          SlidableAction(
            onPressed: (context) async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Information'),
                  content: Text(
                      'Veuillez contacter $firstName $lastName et conseil , ne payer jamais avant votre service soit rendus!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final Uri whatsappUrl =
                            Uri.parse('https://wa.me/$phoneNumber');

                        if (await canLaunchUrl(whatsappUrl)) {
                          await launchUrl(whatsappUrl,
                              mode: LaunchMode.externalApplication);
                        } else {
                          final Uri playStoreUrl = Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.whatsapp',
                          );

                          if (await canLaunchUrl(playStoreUrl)) {
                            await launchUrl(playStoreUrl,
                                mode: LaunchMode.externalApplication);
                            deleteService(serviceId);
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Impossible d\'ouvrir WhatsApp ou le Play Store'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text('Contacter sur WhatsApp'),
                    ),
                  ],
                ),
              );
            },
            icon: Icons.check,
            backgroundColor: Colors.green[600]!,
          ),
          SlidableAction(
            onPressed: (context) {
              deleteNotif(idNotif);
            },
            icon: Icons.close,
            backgroundColor: Colors.red[700]!,
          )
        ]),
        child: ListTile(
          isThreeLine: true,
          contentPadding: EdgeInsets.symmetric(horizontal: size.width * .08),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/$image'),
          ),
          title: Text(
            "$firstName $lastName",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            DateFormat('HH:mm').format(time.toDate()),
            style: TextStyle(fontSize: 12),
          ),
        ));
    
  }
}

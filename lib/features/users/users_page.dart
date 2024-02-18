import 'package:flutter/material.dart';
import 'package:thefluttercorner/features/users/user.dart'; // Asegúrate de importar tu clase User
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:thefluttercorner/features/users/user_page.dart';
import '../../widgets/widgets.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Users',
            description: 'List of users who can sign in to this dashboard.',
          ),
          const Gap(16),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text("No hay datos disponibles"));
                  }
                  final users = snapshot.data!.docs.map((doc) => User.fromFirestore(doc)).toList();
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(
                          user.name,
                          style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          user.role,
                          style: theme.textTheme.labelMedium,
                        ),
                        trailing: const Icon(Icons.navigate_next_outlined),
                        onTap: () {
                          // Navegación a UserPage con los datos del usuario
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => UserPage(user: user)),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => UserPage(user: User(userId: '', name: '', role: ''))),
          );
        },
      ),
    );
  }
}

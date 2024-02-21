import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thefluttercorner/features/users/user.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.user});

  final User user;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _roleController = TextEditingController(text: widget.user.role);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<String> _getAvailableCustomDocumentId() async {
    // Esta función es solo un ejemplo y puede no ser eficiente o segura para concurrencias
    final collectionRef = FirebaseFirestore.instance.collection('users');
    const startId = 1; // Comenzamos a buscar desde el ID 1
    bool isAvailable = false;
    int currentId = startId;

    while (!isAvailable) {
      final docSnapshot = await collectionRef.doc(currentId.toString()).get();
      if (!docSnapshot.exists) {
        isAvailable = true; // El ID actual está disponible
      } else {
        currentId++; // Incrementa el ID y verifica el siguiente
      }
    }

    return currentId.toString(); // Retorna el primer ID disponible como string
  }

  Future<void> _saveUser() async {
    final String name = _nameController.text.trim();
    final String role = _roleController.text.trim();

    if (name.isNotEmpty && role.isNotEmpty) {
      if (widget.user.userId.isEmpty) {
        // Obtén el primer ID disponible
        String customDocumentId = await _getAvailableCustomDocumentId();
        // Usa este ID para el nuevo documento
        await FirebaseFirestore.instance.collection('users').doc(customDocumentId).set({
          'name': name,
          'role': role,
        });
      } else {
        // Actualizar un usuario existente
        await FirebaseFirestore.instance.collection('users').doc(widget.user.userId).update({
          'name': name,
          'role': role,
        });
      }

      Navigator.of(context).pop(); // Regresa a la pantalla anterior después de guardar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.userId.isEmpty ? 'Create User' : 'Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            ElevatedButton(
              onPressed: _saveUser,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveUser,
        child: const Icon(Icons.save),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mi_estudio/utils/provider/user_provider.dart';
import 'package:mi_estudio/views/drawer_view.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final user = provider.user;
    
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(child: Text("Bienvenido, ${user.email}")),
      drawer: DrawerView(),
    );
  }
}
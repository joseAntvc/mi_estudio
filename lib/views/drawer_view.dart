import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/utils/provider/user_provider.dart';
import 'package:provider/provider.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final user = provider.user;
    final theme = Theme.of(context).textTheme;
    
    return Drawer(
      width: 250,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: user.photoURL != null
                  ? CachedNetworkImageProvider(user.photoURL!)
                  : AssetImage("assets/Profile.png"),
            ),
            accountName: Text(user.displayName ?? "Nombre no disponible", style: theme.labelSmall),
            accountEmail: Text(user.email ?? "Correo no disponible", style: theme.labelSmall),
          ),
          ListTile(
            leading: Image.asset("assets/iconos/materias.png", width: 50),
            title: Text('Mis materias'),
            onTap: () {
              Navigator.pushNamed(context, "/subject");
            },
          ),
          ListTile(
            leading: Image.asset("assets/iconos/calendario.png", width: 50), 
            title: Text('Mi calendario'),
            onTap: () {
              Navigator.pushNamed(context, "/calendar");
            },
          ),
          ListTile(
            leading: Image.asset("assets/iconos/notas.png", width: 50), 
            title: Text('Notas'),
            onTap: () {
              Navigator.pushNamed(context, "/note");
            },
          ),
          ListTile(
            leading: Image.asset("assets/iconos/motivacion.png", width: 50),
            title: Text('Motivación'),
            onTap: () {
              //
            },
          ),
          ListTile(
            leading: Image.asset("assets/iconos/ubicacion.png", width: 50),
            title: Text('Ubicaciones'),
            onTap: () {
              Navigator.pushNamed(context, "/ubication");
            },
          ),
          ListTile(
            leading: Image.asset("assets/iconos/notificacion.png", width: 50),
            title: Text('Notificaciones'),
            onTap: () {
              //
            },
          ),
          ListTile(
            leading: Image.asset("assets/iconos/perfil.png", width: 50),
            title: Text('Perfil'),
            onTap: () {
              Navigator.pushNamed(context, "/profile");
            },
          ),
          ListTile(
            leading: Image.asset("assets/iconos/configuracion.png", width: 50),
            title: Text('Configuración'),
            onTap: () {
              Navigator.pushNamed(context, "/configuration");
            },
          ),
        ],
      ),
    );
  }
}
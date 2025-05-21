import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/utils/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  //Son las opciones para seleccionar la imagen del usuario
  void showOptions(UserProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(leading: Icon(Icons.camera), title: Text("Tomar foto"),
                onTap: () {
                  Navigator.pop(context);
                  provider.pickImage(ImageSource.camera);
                },
              ),
              ListTile(leading: Icon(Icons.photo_library),title: Text("Seleccionar de la galería"),
                onTap: () {
                  Navigator.pop(context);
                  provider.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500; 
    final separador = SizedBox(height: 50);
    final separador2 = SizedBox(height: 10);
    final provider = Provider.of<UserProvider>(context, listen: false); 

    final title = Text("Perfil", style: theme.textTheme.displayMedium);
    
    final left = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer<UserProvider>(
          builder:  (context, prov, _){
            return CircleAvatar(
              backgroundImage: prov.photo != null //Primero checa si hay una foto
                  ? FileImage(prov.photo!) 
                  : (prov.user.photoURL != null //Si no hay una foto, checa si hay una URL
                      ? CachedNetworkImageProvider(prov.user.photoURL!)
                      : null),
              radius: 90,
              child: prov.photo == null && prov.user.photoURL == null ? Image.asset('assets/Profile.png', width: 150, color: theme.scaffoldBackgroundColor) : null,
            );
          },
        ),
        SizedBox(height: 20),
        if(provider.isEmailUser)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(150, 50),
              backgroundColor: theme.scaffoldBackgroundColor,
              side: BorderSide(color: Colors.grey[400]!),
            ),
            onPressed: () {
              showOptions(provider);
            },
            child: Text("Editar foto", style: theme.textTheme.titleMedium),
          )
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        separador2,
        Consumer<UserProvider>(
          builder:  (context, prov, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Nombre", style: theme.textTheme.titleLarge),
                    if (prov.isEmailUser)
                      IconButton(
                        icon: Icon(prov.editandoNombre ? Icons.check : Icons.edit, size: 18),
                        onPressed: () {
                          prov.toggleEditarNombre();
                        },
                      ),
                  ],
                ),
                prov.editandoNombre && prov.isEmailUser
                  ? TextField(
                      controller: prov.conNombre,
                      decoration: InputDecoration(
                        hintText: "Nuevo nombre",
                      ),
                    )
                  : Text(
                      prov.conNombre.text.isNotEmpty
                        ? prov.conNombre.text
                        : prov.user.displayName ?? "Nombre no disponible",
                      style: theme.textTheme.titleSmall,
                    ),
              ],
            );
          }
        ),
        separador,
        Text("Correo electronico", style: theme.textTheme.titleLarge),
        separador2,
        Text(
          provider.user.email ?? "Correo no disponible",
          style: theme.textTheme.titleSmall
        ),
        separador,
        if(provider.isEmailUser)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: (){
              final nombreCambiado = provider.conNombre.text.trim() != (provider.user.displayName ?? "");
              final fotoCambiada = provider.photo != null;

              if (nombreCambiado || fotoCambiada) {
                provider.guardarCambios();
                CustomToast.show(context, "Informacion actualizada", disa: true);
              } else {
                CustomToast.show(context, "No hay cambios para guardar", type: "w", disa: true);
              }
            },
            child: Text("Guardar cambios", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
      ],
    );

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: isWide
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    title,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: left,
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: right,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      title,
                      separador,
                      left,
                      separador,
                      right
                    ],
                  ),
                ),
            ),
          ),
          Positioned(
            top: 40,
            left: 5,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 25),
              onPressed: () {
                provider.clearInfo();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';
import 'package:mi_estudio/utils/custom_toast.dart';
import 'package:mi_estudio/views/head_view.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  TextEditingController conEmail = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late AuthFirebase auth;

  @override
  void initState() {
    super.initState();
    auth = AuthFirebase();
  }

  @override
  Widget build(BuildContext context) {
    const separador = SizedBox(height: 20);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500; 

    final formulario = Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Ingresa tu correo electrónico\npara restablecer tu contraseña", style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          SizedBox(height: 50),
          TextFormField(
            controller: conEmail,
            decoration: InputDecoration(hintText: "Correo electrónico"),
            validator: (value) => (value == null || value.isEmpty) 
              ? 'El email es requerido' 
              : (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) 
                ? 'El email no es válido' 
                : null,
          ),
          separador,
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50), // Botón ancho
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                auth.sendPasswordReset(conEmail.text).then((value){
                  if (value) {
                    CustomToast.show(context, "Correo enviado", descrip: "Revisa tu bandeja de entrada.");
                    Navigator.pop(context);
                  } else {
                    CustomToast.show(context, "Asegúrate de que el correo esté registrado o intenta más tarde", type: "e");
                  }
                });
              }
            },
            child: Text("Restablecer contraseña",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          separador,
          Divider(thickness: 1),                  
          separador,
          InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Text("Iniciar sesión", style: theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: HeadView(titulo: "Recuperar\nContraseña"),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: formulario,
                  ),
                ),
              ],
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeadView(titulo: "Recuperar\nContraseña"),
                  SizedBox(height: 50),
                  formulario,
                ],
              ),
            ),
        ),
      ),
    );
  }
}
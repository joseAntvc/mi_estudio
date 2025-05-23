// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/utils/provider/user_provider.dart';
import 'package:mi_estudio/views/head_view.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController conEmail = TextEditingController();
  TextEditingController conPassword = TextEditingController();
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text("Iniciar sesión", style: theme.textTheme.headlineSmall),
          ),
          SizedBox(height: 15),
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
          TextFormField(
            controller: conPassword,
            obscureText: true,
            decoration: InputDecoration(hintText: "Contraseña"),
            validator: (value) => (value == null || value.isEmpty)
                ? 'La contraseña es requerida'
                : null,
          ),
          SizedBox(height: 10),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, "/password"),
              child: Text("¿Olvidaste tu contraseña?", style: theme.textTheme.labelLarge),
            ),
          ),
          separador,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                auth.loginUser(conEmail.text, conPassword.text).then((value) {
                if (value == null) {
                  CustomToast.show(context, "Iniciando sesión...", disa: false);
                  Provider.of<UserProvider>(context, listen: false).refreshUser();
                  Future.delayed(Duration(milliseconds: 3000)).then((value) =>
                    Navigator.pushReplacementNamed(context, "/dash"), //Es para ir al dashboard y borrar la pantalla anterior
                  );
                } else if(value == "verificacion") {
                  CustomToast.show(context, "Verifica tu correo electronico", type: "w");
                } else {
                  CustomToast.show(context, "Correo o contraseña incorrectos", type: "e");
                }});
              }
            },
            child: Text("Iniciar sesión", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          separador,
          Divider(thickness: 1),
          separador,
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: theme.scaffoldBackgroundColor,
              side: BorderSide(color: Colors.grey[400]!),
            ),
            onPressed: () {
              auth.signInWithGoogle().then((value){
                if (value == null) {
                  CustomToast.show(context, "Inicio de sesión exitoso con Google", disa: false);
                  Provider.of<UserProvider>(context, listen: false).refreshUser();
                  Future.delayed(Duration(milliseconds: 3000)).then((value) =>
                    Navigator.pushReplacementNamed(context, "/dash"), //Es para ir al dashboard y borrar la pantalla anterior
                  );
                } else if (value == "cancelado") {
                  CustomToast.show(context, "Inicio de sesión cancelado", type: "w");
                } else {
                  CustomToast.show(context, "Error al iniciar sesión con Google", type: "e");
                }
              });
            },
            icon: Image.asset('assets/logo_google.png', width: 24),
            label: Text("Continuar con Google", style: theme.textTheme.titleMedium),
          ),
          separador,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("¿No tienes una cuenta? ", style: theme.textTheme.bodyMedium),
              InkWell(
                onTap: () => Navigator.pushNamed(context, "/register"),
                child: Text("Regístrate", style: theme.textTheme.labelLarge),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      body: Center(
        child: isWide
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: HeadView(titulo: "Mi estudio"),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: formulario,
                  ),
                ),
              ),
            ],
          )
        : SingleChildScrollView(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeadView(titulo: "Mi estudio"),
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

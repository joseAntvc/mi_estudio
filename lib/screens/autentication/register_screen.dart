import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/utils/provider/register_provider.dart';
import 'package:mi_estudio/views/head_view.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController conEmail = TextEditingController();
  TextEditingController conPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late AuthFirebase auth;

  // Validaciones individuales
  Widget requirementItem(String text, bool correct) {
    return Row(
      spacing: 10,
      children: [
        Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.green : Colors.red, size: 14),
        Text(text, style: TextStyle(color: correct ? Colors.green : Colors.red)),
      ],
    );
  }

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
    final provider = Provider.of<RegisterProvider>(context, listen: false); 

    final formulario = Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text("Regístrate", style:  theme.textTheme.headlineSmall)
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
            onChanged: (value) => provider.password = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                provider.setMostrarErrores(false);
                return 'La contraseña es requerida';
              }
              if (!provider.esValida) {
                provider.setMostrarErrores(true);
                return '';
              }
              provider.setMostrarErrores(false);
              return null;
            },
          ),
          Consumer<RegisterProvider>(
            builder: (context, prov, _) {
              if (!prov.mostrarErrores) return SizedBox.shrink();
              return Column(
                children: [
                  for (var entry in prov.validaciones.entries)
                    requirementItem(entry.key, entry.value),
                ],
              );
            },
          ),
          separador, 
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50), // Botón ancho
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                auth.createUser(conEmail.text, conPassword.text).then((value) {
                  if (value) {
                    CustomToast.show(context, "Usuario Registrado", descrip: "Checa tu correo electrónico");
                    Navigator.pop(context);
                  } else {
                    CustomToast.show(context, "El correo ya está registrado", type: "e");
                  }
                });
              }
            },
            child: Text("Regístrate",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          separador,
          Divider(thickness: 1),                  
          separador,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text("¿Ya tienes una cuenta? ", style: theme.textTheme.bodyMedium,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Text("Iniciar sesión", style: theme.textTheme.labelLarge),
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
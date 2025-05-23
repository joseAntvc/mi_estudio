import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';
import 'package:mi_estudio/utils/provider/theme_provider.dart';
import 'package:mi_estudio/utils/provider/user_provider.dart';
import 'package:mi_estudio/views/configuracion/font_view.dart';
import 'package:mi_estudio/views/configuracion/opcion_view.dart';
import 'package:mi_estudio/views/configuracion/theme_view.dart';
import 'package:provider/provider.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  // Lista de fuentes disponibles
  final List<String> _availableFonts = [
    'Roboto', 'Caveat', 'Montserrat', 'Courgette', 'Mulish', 'Parisienne'
  ];
  final List<Map<String, dynamic>> themeOptions = [
    { 'label': 'Sistema', 'icon': Icons.settings_outlined, 'theme': AppTheme.system},
    { 'label': 'Claro', 'icon': Icons.wb_sunny_outlined, 'theme': AppTheme.light },
    { 'label': 'Oscuro', 'icon': Icons.nightlight_round_outlined, 'theme': AppTheme.dark },
    { 'label': 'Azul', 'icon': Icons.water_drop_outlined, 'theme': AppTheme.blue },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Apariencia
            _encabezado('Apariencia', theme),
            _card(
              children: [
                _temas(theme),
                const SizedBox(height: 20),
                _fuente(theme),
              ],
            ),
            /*const SizedBox(height: 24),
            //Sección de Notificaciones
            _encabezado('Notificaciones'),
            _card(
              children: [
                _buildSwitchOption(
                  title: 'Notificaciones push',
                  subtitle: 'Recibe notificaciones importantes',
                  value: true,
                  onChanged: (value) {},
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildSwitchOption(
                  title: 'Sonido de notificación',
                  subtitle: 'Reproducir sonido al recibir notificaciones',
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),*/
            const SizedBox(height: 24),
            // Sección de Cuenta
            _encabezado('Cuenta', theme),
            _card(
              children: [
                OpcionView(
                  title: 'Subcripción',
                  icon: Icons.credit_card,
                  onTap: () {
                    Navigator.pushNamed(context, "/billing");
                  },
                ),
                const Divider(height: 10, thickness: 0.5),
                OpcionView(
                  title: 'Cerrar sesión',
                  icon: Icons.exit_to_app_outlined,
                  cerrar: true,
                  onTap: () {
                    AuthFirebase().signOut();
                    Provider.of<UserProvider>(context, listen: false).refreshUser();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para los encabezados de sección
  Widget _encabezado(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: theme.textTheme.titleSmall),
    );
  }

  // Widget para las tarjetas de sección
  Widget _card({required List<Widget> children}) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children),
      ),
    );
  }

  // Widget para el selector de tema
  Widget _temas(ThemeData theme) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tema de la aplicación', style: theme.textTheme.bodyLarge),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: themeOptions.map((theme) => ThemeView(
            label: theme['label'],
            icon: theme['icon'],
            selected: themeProvider.appTheme == theme['theme'],
            onTap: () {
              themeProvider.setAppTheme(theme['theme']);
            },
          )).toList(),
        ),
      ],
    );
  }

  // Widget para el selector de fuente
  Widget _fuente(ThemeData theme) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Fuente de texto', style: theme.textTheme.bodyLarge),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _availableFonts.map((font) => FontView(
            label: font,
            selected: themeProvider.font == font,
            onTap: () {
              themeProvider.setFont(font);
            },
          )).toList(),
        ),
      ],
    );
  }

  /*// Widget para opciones con switch
  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }*/
}
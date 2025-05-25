import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_estudio/utils/provider/notification_provider.dart';

class NotificacionScreen extends StatelessWidget {
  const NotificacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500;

    return Consumer<NotificationProvider>(
      builder: (context, notifProv, _) {
        final subs = notifProv.topicSubscriptions;
        Widget general() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _encabezado('Configuración general', theme),
            _card(children: [
              _buildNotificationOption(
                context: context,
                topic: 'general',
                title: 'Todas las notificaciones',
                description: 'Activa todas las notificaciones disponibles',
                value: subs['general'] ?? false,
                onChanged: (v) => notifProv.handleSubscriptionChange('general', v),
                showDivider: true,
              ),
              _buildNotificationOption(
                context: context,
                topic: 'Sin',
                title: 'Desactivar todas',
                description: 'Desactiva todas las notificaciones',
                value: subs['Sin'] ?? false,
                onChanged: (v) => notifProv.handleSubscriptionChange('Sin', v),
                showDivider: false,
              ),
            ]),
          ],
        );

        Widget especificas() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _encabezado('Notificaciones específicas', theme),
            _card(children: [
              _buildNotificationOption(
                context: context,
                topic: 'actualizacion',
                title: 'Actualizaciones',
                description: 'Te avisará cada dos semanas sobre novedades',
                value: subs['actualizacion'] ?? false,
                onChanged: (v) => notifProv.handleSubscriptionChange('actualizacion', v),
                showDivider: true,
              ),
              _buildNotificationOption(
                context: context,
                topic: 'motivacion',
                title: 'Motivación diaria',
                description: 'Notificación cada día a la 1 pm con frase motivacional',
                value: subs['motivacion'] ?? false,
                onChanged: (v) => notifProv.handleSubscriptionChange('motivacion', v),
                showDivider: true,
              ),
              _buildNotificationOption(
                context: context,
                topic: 'calendario',
                title: 'Eventos del día',
                description: 'Notificación cada día a las 8 am con tus eventos',
                value: subs['calendario'] ?? false,
                onChanged: (v) => notifProv.handleSubscriptionChange('calendario', v),
                showDivider: false,
              ),
            ]),
          ],
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de Notificaciones'),
            centerTitle: true,
          ),
          body: isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: general(),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: especificas(),
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    general(),
                    const SizedBox(height: 24),
                    especificas(),
                  ],
                ),
              ),
        );
      },
    );
  }

  Widget _buildNotificationOption({
    required BuildContext context,
    required String topic,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 5),
                  Text(description, style: TextStyle(fontSize: 12, color: theme.hintColor)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
        if (showDivider) const Divider(height: 24, thickness: 0.5),
      ],
    );
  }

  Widget _encabezado(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: theme.textTheme.titleSmall),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}
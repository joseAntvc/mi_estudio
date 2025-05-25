import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/utils/provider/subscription_provider.dart';
import 'package:mi_estudio/utils/provider/user_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    Provider.of<SubscriptionProvider>(context, listen: false).loadSubscription();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final user = provider.user;
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500; 
  
    // Lista de elementos del menú
    final menuItems = [
      { 'icon': 'assets/iconos/materias.png', 'title': 'Mis materias',
        'route': '/subject', 'color': Colors.indigo, },
      { 'icon': 'assets/iconos/calendario.png', 'title': 'Mi calendario',
        'route': '/calendar', 'color': Colors.teal, },
      { 'icon': 'assets/iconos/notas.png', 'title': 'Notas',
        'route': '/note', 'color': Colors.orange, },
      { 'icon': 'assets/iconos/motivacion.png', 'title': 'Motivación',
        'route': '/motivation', 'color': Colors.pink, },
      { 'icon': 'assets/iconos/ubicacion.png', 'title': 'Ubicaciones',
        'route': '/ubication', 'color': Colors.blue, },
      { 'icon': 'assets/iconos/notificacion.png', 'title': 'Notificaciones',
        'route': '/notifications', 'color': Colors.purple, },
      { 'icon': 'assets/iconos/perfil.png', 'title': 'Perfil',
        'route': '/profile', 'color': Colors.green, },
      { 'icon': 'assets/iconos/configuracion.png', 'title': 'Configuración',
        'route': '/configuration', 'color': Colors.grey, },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado con información del usuario
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20), 
                  bottomRight: Radius.circular(20)
                )
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user.photoURL != null
                              ? CachedNetworkImageProvider(user.photoURL!)
                              : const AssetImage("assets/Profile.png") as ImageProvider,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? "Nombre no disponible",
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? "Correo no disponible",
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<SubscriptionProvider>(
                      builder: (context, subscription, _) {
                        final plan = subscription.type;
                        final isPremium = plan != null;       
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPremium ? Icons.workspace_premium : Icons.card_giftcard,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isPremium ? 'Plan Premium' : 'Plan Gratis',
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isPremium)
                                ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/billing'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Text('Mejorar'),
                                ),
                              if (isPremium)
                                Icon(Icons.check_circle, color: theme.primaryColor),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: menuItems.map((item) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: item['color'] as Color,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pushNamed(context, item['route'] as String),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            item['icon'] as String,
                            width: 50,
                            height: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
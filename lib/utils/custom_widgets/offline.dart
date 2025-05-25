import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_estudio/utils/provider/connectivity_provider.dart';

class Offline extends StatelessWidget {
  const Offline({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, prov, _) {
        return (!prov.isOnline)
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi_off_outlined, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(
                        'Sin conexión a internet',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
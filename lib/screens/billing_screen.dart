import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mi_estudio/services/key.dart';
import 'package:mi_estudio/services/payment_services.dart';
import 'package:mi_estudio/utils/provider/subscription_provider.dart';
import 'package:mi_estudio/views/plan_view.dart';
import 'package:provider/provider.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {

  final PaymentServices _paymentServices = PaymentServices.instance;

  @override
  void initState() {
  _initializeStripe(); 
  super.initState();
  }
  _initializeStripe() async {
    Stripe.publishableKey = stripePublishablekey;
    await Stripe.instance.applySettings();
  }

  _showPaymentSheet(int amount, String type) async {
    await _paymentServices.makePayment(amount, 'MXN', context, type);
  }

  @override
  Widget build(BuildContext context) {
    final subscription = Provider.of<SubscriptionProvider>(context);
    final isActivo = subscription.isActive;
    final isMensual = subscription.type == 'mensual';
    final isAnual = subscription.type == 'anual';

    return Scaffold(
      appBar: AppBar(title: const Text('Suscripciones'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isActivo)
              Container(
                color: Colors.amber[100],
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Podrás renovar cuando tu suscripción termine.\nCon esto evitamos pagos equivocados :)',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
              PlanView(
                title: 'Gratis',
                price: '0 MXN',
                description: 'Acceso básico a la app\n• Solo puedes subir imágenes (fotos)\n• No puedes subir videos ni otros archivos',
                onPressed: !isActivo ? () {} : null,
                isCurrent: !isActivo,
              ),
              const SizedBox(height: 24),
              PlanView(
                title: 'Mensual',
                price: '100 MXN/mes',
                description: 'Acceso premium mensual\n• Puedes subir imágenes, videos y archivos de cualquier extensión',
                onPressed: (!isActivo)
                  ? () async {
                      await _showPaymentSheet(100, 'mensual');
                      await Provider.of<SubscriptionProvider>(context, listen: false).loadSubscription();
                    }
                  : null,
                isCurrent: isMensual && isActivo,
              ),
              const SizedBox(height: 24),
              PlanView(
                title: 'Anual',
                price: '1000 MXN/año',
                description: 'Acceso premium anual\n• Puedes subir imágenes, videos y archivos de cualquier extensión',
                ahorro: '¡Ahorras 2 meses!',
                onPressed: (!isActivo)
                  ? () async {
                      await _showPaymentSheet(1000, 'anual');
                      await Provider.of<SubscriptionProvider>(context, listen: false).loadSubscription();
                    }
                  : null,
                isCurrent: isAnual && isActivo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

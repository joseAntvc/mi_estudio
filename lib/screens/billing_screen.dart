import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mi_estudio/services/key.dart';
import 'package:mi_estudio/services/payment_services.dart';
import 'package:mi_estudio/views/plan_view.dart';

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

  _showPaymentSheet(int amount) async {
    await _paymentServices.makePayment(amount, 'MXN');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suscripciones'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlanView(
                title: 'Gratis',
                price: '0 MXN',
                description: 'Acceso básico a la app',
                buttonText: 'Plan actual',
                onPressed: (){},
                isCurrent: true,
              ),
              const SizedBox(height: 24),
              PlanView(
                title: 'Mensual',
                price: '100 MXN/mes',
                description: 'Acceso premium mensual',
                buttonText: 'Suscribirse',
                onPressed: () async {
                  await _showPaymentSheet(100);
                },
              ),
              const SizedBox(height: 24),
              PlanView(
                title: 'Anual',
                price: '1000 MXN/año',
                description: 'Acceso premium anual',
                buttonText: 'Suscribirse',
                onPressed: () async {
                  await _showPaymentSheet(1000);
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}

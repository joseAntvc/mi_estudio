import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mi_estudio/firebase/pay_firebase.dart';
import 'package:mi_estudio/services/key.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';

class PaymentServices {
  PaymentServices._();

  static final PaymentServices instance = PaymentServices._();


  Future<bool> makePayment(int amount, String currency, BuildContext context, String type) async {
    try{
      final paymentIntent = await _createPaymentIntent(_changeToDollarInstedofCents(amount), currency);
      if(paymentIntent == null) {
        log('Error creating payment intent'); 
        return false;
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent,
          style: ThemeMode.light,
          merchantDisplayName: 'Mi_estudio',
          billingDetails: BillingDetails(
            address: Address(city: 'Ciudad de México', country: 'MX', line1: '', line2: '', postalCode: '', state: '')
          ),
        )
      );
      await Stripe.instance.presentPaymentSheet().then((value) async{
        CustomToast.show(context, "Pago completado");
        DateTime now = DateTime.now();
        DateTime? endDate;
        if (type == 'mensual') {
          endDate = DateTime(now.year, now.month + 1, now.day);
        } else if (type == 'anual') {
          endDate = DateTime(now.year + 1, now.month, now.day);
        }
        await PayFirebase().addPay({
          'amount': amount,
          'currency': currency,
          'type': type,
          'createdAt': FieldValue.serverTimestamp(),
          'endDate': endDate
        });
      });
      return true;
    } catch (e){
      CustomToast.show(context, "Pago fallido");
      log('Error marking payment: $e');
      return false;
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try{
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        'amount': amount,
        'currency': currency,
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer $stripeSecretkey',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
        ),
      );
      if (response.data != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (e){
      debugPrint('Create payment error: $e');
      return null;
    }
  }

  _changeToDollarInstedofCents(int amount){
    return amount * 100;
  }
}
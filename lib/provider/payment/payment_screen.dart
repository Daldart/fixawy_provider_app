import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fixawy_provider/components/app_widgets.dart';
import 'package:fixawy_provider/components/back_widget.dart';
import 'package:fixawy_provider/main.dart';
import 'package:fixawy_provider/models/provider_subscription_model.dart';
import 'package:fixawy_provider/utils/configs.dart';
import 'package:fixawy_provider/utils/constant.dart';
import 'package:fixawy_provider/utils/extensions/num_extenstions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';
import '../../models/configuration_response.dart';
import '../../networks/rest_apis.dart';
import 'components/cinet_pay_services_new.dart';
import 'components/razorpay_service_new.dart';
import 'components/sadad_services_new.dart';
import 'components/stripe_service_new.dart';

class PaymentScreen extends StatefulWidget {
  final ProviderSubscriptionModel selectedPricingPlan;

  const PaymentScreen(this.selectedPricingPlan);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<PaymentSetting> paymentList = [];

  PaymentSetting? selectedPaymentSetting;

  bool isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    paymentList = PaymentSetting.decode(getStringAsync(PAYMENT_LIST));
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_COD);

    if (paymentList.isNotEmpty) {
      selectedPaymentSetting = paymentList.first;
    }
  }

  void _handleClick() async {
    if (isPaymentProcessing) return;
    isPaymentProcessing = false;

    if (selectedPaymentSetting!.type == PAYMENT_METHOD_STRIPE) {
      StripeServiceNew stripeServiceNew = StripeServiceNew(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: widget.selectedPricingPlan.amount.validate(),
        onComplete: (p0) {
          savePayment(
            data: widget.selectedPricingPlan,
            paymentMethod: PAYMENT_METHOD_STRIPE,
            paymentStatus: BOOKING_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      stripeServiceNew.stripePay();
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_RAZOR) {
      RazorPayServiceNew razorPayServiceNew = RazorPayServiceNew(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: widget.selectedPricingPlan.amount.validate(),
        onComplete: (p0) {
          savePayment(
            data: widget.selectedPricingPlan,
            paymentMethod: PAYMENT_METHOD_RAZOR,
            paymentStatus: BOOKING_STATUS_PAID,
            txnId: p0['paymentId'],
          );
        },
      );
      razorPayServiceNew.razorPayCheckout();
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_FLUTTER_WAVE) {
      // FlutterWaveServiceNew flutterWaveServiceNew = FlutterWaveServiceNew();

/*      flutterWaveServiceNew.checkout(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: widget.selectedPricingPlan.amount.validate(),
        onComplete: (p0) {
          savePayment(
            data: widget.selectedPricingPlan,
            paymentMethod: PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: BOOKING_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );*/
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_CINETPAY) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appStore.currencyCode)) {
        toast(languages.cinetpayIsnTSupportedByCurrencies);
        return;
      } else if (widget.selectedPricingPlan.amount.validate() < 100) {
        return toast('${languages.totalAmountShouldBeMoreThan} ${100.toPriceFormat()}');
      } else if (widget.selectedPricingPlan.amount.validate() > 1500000) {
        return toast('${languages.totalAmountShouldBeLessThan} ${1500000.toPriceFormat()}');
      }

      CinetPayServicesNew cinetPayServices = CinetPayServicesNew(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: widget.selectedPricingPlan.amount.validate(),
        onComplete: (p0) {
          savePayment(
            data: widget.selectedPricingPlan,
            paymentMethod: PAYMENT_METHOD_CINETPAY,
            paymentStatus: BOOKING_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      cinetPayServices.payWithCinetPay(context: context);
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_SADAD_PAYMENT) {
      SadadServicesNew sadadServices = SadadServicesNew(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: widget.selectedPricingPlan.amount.validate(),
        onComplete: (p0) {
          savePayment(
            data: widget.selectedPricingPlan,
            paymentMethod: PAYMENT_METHOD_SADAD_PAYMENT,
            paymentStatus: BOOKING_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      sadadServices.payWithSadad(context);
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_PAYPAL) {
      /*PayPalService.paypalCheckOut(
        context: context,
        paymentSetting: selectedPaymentSetting!,
        totalAmount: widget.selectedPricingPlan.amount.validate(),
        onComplete: (p0) {
          savePayment(
            data: widget.selectedPricingPlan,
            paymentMethod: PAYMENT_METHOD_PAYPAL,
            paymentStatus: BOOKING_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );*/
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(languages.lblPayment, color: context.primaryColor, textColor: Colors.white, backWidget: BackWidget()),
      body: Stack(
        children: [
          if (paymentList.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text(languages.lblChoosePaymentMethod, style: boldTextStyle(size: 18)).paddingOnly(left: 16),
                16.height,
                AnimatedListView(
                  itemCount: paymentList.length,
                  shrinkWrap: true,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  itemBuilder: (context, index) {
                    PaymentSetting value = paymentList[index];
                    return RadioListTile<PaymentSetting>(
                      dense: true,
                      activeColor: primaryColor,
                      value: value,
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: selectedPaymentSetting,
                      onChanged: (PaymentSetting? ind) {
                        selectedPaymentSetting = ind;
                        setState(() {});
                      },
                      title: Text(value.title.validate(), style: primaryTextStyle()),
                    );
                  },
                ),
                Spacer(),
                AppButton(
                  onTap: () {
                    if (selectedPaymentSetting!.type == PAYMENT_METHOD_COD) {
                      showConfirmDialogCustom(
                        context,
                        dialogType: DialogType.CONFIRMATION,
                        title: "${languages.lblPayWith} ${selectedPaymentSetting!.title.validate()}",
                        primaryColor: primaryColor,
                        positiveText: languages.lblYes,
                        negativeText: languages.lblNo,
                        onAccept: (p0) {
                          _handleClick();
                        },
                      );
                    } else {
                      _handleClick();
                    }
                  },
                  text: languages.lblProceed,
                  color: context.primaryColor,
                  width: context.width(),
                ).paddingAll(16),
              ],
            ),
          if (paymentList.isEmpty)
            NoDataWidget(
              imageWidget: EmptyStateWidget(),
              title: languages.lblNoPayments,
              imageSize: Size(150, 150),
            ),
          Observer(builder: (context) => LoaderWidget().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}

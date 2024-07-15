import 'package:fixawy_provider/handyman/component/handyman_total_component.dart';
import 'package:fixawy_provider/main.dart';
import 'package:fixawy_provider/screens/cash_management/component/today_cash_component.dart';
import 'package:fixawy_provider/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../components/app_widgets.dart';
import '../components/back_widget.dart';
import '../components/empty_error_state_widget.dart';
import '../handyman/component/withdrow_inforamtion.dart';
import '../handyman/shimmer/handyman_dashboard_shimmer.dart';
import '../models/financial_Data.dart';
import '../models/handyman_dashboard_response.dart';
import '../models/request_withdraw.dart';
import '../networks/rest_apis.dart';

import '../utils/common.dart';
import '../utils/images.dart';

class Withdrow extends StatefulWidget {
  @override
  _Withdrow createState() => _Withdrow();
}

class _Withdrow extends State<Withdrow> {
  late Future<FinancialDataModel> future;

  late TextEditingController amountCont;

  late TextEditingController noteCont;
  String? _selectedMethod;
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    future = withdrawSummary();
    amountCont = TextEditingController();
    noteCont = TextEditingController();

    appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.withdraw,
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          FutureBuilder<FinancialDataModel>(
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                return AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration:
                      FadeInConfiguration(duration: 500.milliseconds),
                  children: [
                    WithdrowCards(snap: snap.data!),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.NUMBER,
                      controller: amountCont,
                      decoration:
                          inputDecoration(context, hint: languages.amount),
                    ),
                    16.height,
                    DropdownButtonFormField<String>(
                      decoration: inputDecoration(context,
                          hint: snap.data!.readyToWithdrawal > 0
                              ? languages.withdrawMethods
                              : languages.paymentMethod),
                      isExpanded: true,
                      value: _selectedMethod,
                      dropdownColor: context.cardColor,
                      items: <String>['Cash'].map((String data) {
                        return DropdownMenuItem<String>(
                          value: data,
                          child: Text(data, style: primaryTextStyle()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                    ).paddingTop(16),
                    16.height,
                    AppTextField(
                      controller: noteCont,
                      textFieldType: TextFieldType.MULTILINE,
                      maxLines: 5,
                      minLines: 3,
                      decoration:
                          inputDecoration(context, hint: languages.note),
                    ),
                    16.height,
                    AppButton(
                      text: snap.data!.readyToWithdrawal > 0
                          ? languages.withdraw
                          : languages.payofdebt,
                      width: context.width(),
                      color: primaryColor,
                      textColor: Colors.white,
                      onTap: () async {
                        if (_selectedMethod == null ||
                            amountCont.value.text.isEmpty) {
                          return;
                        }
                        WithdrawModel withdrawal = WithdrawModel(
                          amount: double.parse(amountCont.value.text),
                          paymentMethod: _selectedMethod!,
                          notes: noteCont.value.text,
                        );

                        appStore.setLoading(true);

                        final response = await requestWithdraw(withdrawal);

                        toast(response.message);
                        appStore.setLoading(false);
                        init();
                        setState(() {});
                      },
                    ),
                  ],
                  onSwipeRefresh: () async {
                    init();
                    setState(() {});
                  },
                );
              }
              return snapWidgetHelper(
                snap,
                loadingWidget: HandymanDashboardShimmer(),
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    imageWidget: ErrorStateWidget(),
                    retryText: languages.reload,
                    onRetry: () {
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fixawy_provider/handyman/component/handyman_total_widget.dart';
import 'package:fixawy_provider/main.dart';
import 'package:fixawy_provider/models/handyman_dashboard_response.dart';
import 'package:fixawy_provider/screens/total_earning_screen.dart';
import 'package:fixawy_provider/utils/constant.dart';
import 'package:fixawy_provider/utils/extensions/num_extenstions.dart';
import 'package:fixawy_provider/utils/images.dart';
import 'package:fixawy_provider/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';




class WithdrowCards extends StatelessWidget {
  final HandymanDashBoardResponse snap;

  WithdrowCards({required this.snap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        HandymanTotalWidget(
          title: languages.netRevenue,
          total: snap.totalPayments.validate().toPriceFormat(),
          icon: percent_line,
        ).onTap(
              () {
            TotalEarningScreen().launch(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        HandymanTotalWidget(
          title: languages.alreadyWithdrawn,
          total: snap.totalPayments.validate().toPriceFormat(),
          icon: percent_line,
        ).onTap(
              () {
            TotalEarningScreen().launch(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),     HandymanTotalWidget(
          title: languages.pendingWithdraw,
          total: snap.totalPayments.validate().toPriceFormat(),
          icon: percent_line,
        ).onTap(
              () {
            TotalEarningScreen().launch(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        HandymanTotalWidget(
          title: languages.readyToWithdraw,
          total: snap.totalPayments.validate().toPriceFormat(),
          icon: percent_line,
        ).onTap(
              () {
       //     TotalEarningScreen().launch(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),

      ],
    ).paddingAll(16);
  }
}

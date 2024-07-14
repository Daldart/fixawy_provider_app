import 'package:flutter/material.dart';
import 'package:fixawy_provider/handyman/component/handyman_total_widget.dart';
import 'package:fixawy_provider/main.dart';
import 'package:fixawy_provider/screens/total_earning_screen.dart';
import 'package:fixawy_provider/utils/extensions/num_extenstions.dart';
import 'package:fixawy_provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/financial_Data.dart';

class WithdrowCards extends StatelessWidget {
  final FinancialDataModel snap;

  WithdrowCards({required this.snap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        HandymanTotalWidget(
          title: languages.netRevenue,
          total: snap.netTotal.validate().toPriceFormat(),
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
          total: snap.alreadyWithdrawn.validate().toPriceFormat(),
          icon: percent_line,
        ).onTap(
          () {
            //   TotalEarningScreen().launch(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        HandymanTotalWidget(
          title: languages.pendingWithdraw,
          total: snap.pendingWithdrawal.validate().toPriceFormat(),
          icon: percent_line,
        ).onTap(
          () {
            //  TotalEarningScreen().launch(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        HandymanTotalWidget(
          color: snap.readyToWithdrawal > 0 ? Colors.green : Colors.red,
          title: snap.readyToWithdrawal > 0
              ? languages.readyToWithdraw
              : languages.debt,
          total: snap.readyToWithdrawal.validate().toPriceFormat(),
          icon: percent_line,
        ).onTap(
          () {
            //     TotalEarningScreen().launch(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
      ],
    );
  }
}

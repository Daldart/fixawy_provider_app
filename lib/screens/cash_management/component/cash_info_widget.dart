import 'package:flutter/material.dart';
import 'package:fixawy_provider/main.dart';
import 'package:fixawy_provider/screens/cash_management/cash_constant.dart';
import 'package:fixawy_provider/screens/cash_management/model/cash_filter_model.dart';
import 'package:fixawy_provider/utils/configs.dart';
import 'package:fixawy_provider/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class CashInfoWidget extends StatelessWidget {
  const CashInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<CashFilterModel> statusInfoList = getStatusInfo();
    return Container(
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          8.height,
          Text(languages.cashStatus, style: boldTextStyle(size: LABEL_TEXT_SIZE, color: context.primaryColor)).paddingOnly(left: 16, right: 16, top: 16, bottom: 8).center(),
          ...List.generate(
            statusInfoList.length,
            (index) {
              CashFilterModel data = statusInfoList[index];
              return Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: boxDecorationDefault(color: data.color, shape: BoxShape.circle),
                      margin: EdgeInsets.only(right: 16),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(handleStatusText(status: data.type.validate()), style: boldTextStyle(size: 12)),
                        0.height,
                        Text(
                          data.name.validate(),
                          style: primaryTextStyle(size: 12),
                        ),
                      ],
                    ).expand(),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                finish(context);
              },
              child: Text(languages.close, style: boldTextStyle(color: primaryColor)),
            ),
          ).paddingRight(8),
          8.height,
        ],
      ),
    );
  }
}

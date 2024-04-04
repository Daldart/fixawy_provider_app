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
import '../handyman/component/handyman_review_component.dart';
import '../handyman/component/withdrow_inforamtion.dart';
import '../handyman/shimmer/handyman_dashboard_shimmer.dart';
import '../models/handyman_dashboard_response.dart';
import '../networks/rest_apis.dart';
import '../provider/components/chart_component.dart';
import '../provider/components/upcoming_booking_component.dart';
import '../utils/images.dart';

class Withdrow extends StatefulWidget {
  @override
  _Withdrow createState() => _Withdrow();
}

class _Withdrow extends State<Withdrow> {
  late Future<HandymanDashBoardResponse> future;
   String? _selectedMethod;
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = handymanDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: appBarWidget(
        languages.withdraw,
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          FutureBuilder<HandymanDashBoardResponse>(
            initialData: cachedHandymanDashboardResponse,
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                return AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 16, top: 16 ),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration:
                      FadeInConfiguration(duration: 500.milliseconds),
                  children: [
                    WithdrowCards(snap: snap.data!),
                    8.height,
                    Container(
                    margin: EdgeInsets.all(16),child:
                  DropdownButtonFormField<String>(

                      decoration: InputDecoration(

                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),

                        filled: true,
                        fillColor: Colors.white,
                      ),

                      borderRadius:
                      BorderRadius.all(Radius.circular(10)),
                      value: _selectedMethod,
                      hint: Text(languages.withdrawMethods),
                      items: <String>['محفظة كاش', 'تحويل بنكي', 'انستاباي'].map((String value) {
                        return  DropdownMenuItem<String>(

                          value: value,
                          alignment: Alignment.center,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                  ))  ,
                    16.height,
                    AppButton(

                      text: languages.submit,
                      width: context.width(),
                      margin: EdgeInsets.all(16),
                      color: primaryColor,
                      textColor: Colors.white,
                      onTap: () async {
                        if(_selectedMethod ==null)
                          {return;}
                      //  finish(context, true);
                        appStore.setLoading(true);


                        setState(() {});

                        await 2.seconds.delay;
                        appStore.setLoading(false);

                      },
                    ),
                   ],
                  onSwipeRefresh: () async {
                    appStore.setLoading(true);

                    init();
                    setState(() {});

                    return await 2.seconds.delay;
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

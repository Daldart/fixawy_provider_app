import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fixawy_provider/main.dart';
import 'package:fixawy_provider/models/dashboard_response.dart';
import 'package:fixawy_provider/networks/rest_apis.dart';
import 'package:fixawy_provider/provider/components/chart_component.dart';
import 'package:fixawy_provider/provider/components/handyman_list_component.dart';
import 'package:fixawy_provider/provider/components/handyman_recently_online_component.dart';
import 'package:fixawy_provider/provider/components/job_list_component.dart';
import 'package:fixawy_provider/provider/components/services_list_component.dart';
import 'package:fixawy_provider/provider/components/total_component.dart';
import 'package:fixawy_provider/provider/fragments/shimmer/provider_dashboard_shimmer.dart';
import 'package:fixawy_provider/provider/subscription/pricing_plan_screen.dart';
import 'package:fixawy_provider/screens/cash_management/component/today_cash_component.dart';
import 'package:fixawy_provider/utils/common.dart';
import 'package:fixawy_provider/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_widgets.dart';
import '../../components/booking_item_component.dart';
import '../../components/empty_error_state_widget.dart';
import '../../fragments/shimmer/noSearchBookingShimmer.dart';
import '../../models/booking_list_response.dart';
import '../components/upcoming_booking_component.dart';

class ProviderHomeFragment extends StatefulWidget {
  @override
  _ProviderHomeFragmentState createState() => _ProviderHomeFragmentState();
}

class _ProviderHomeFragmentState extends State<ProviderHomeFragment> {
  int page = 1;

  int currentIndex = 0;
  Future<List<BookingData>>? pendingBooking;
  Future<List<BookingData>>? inProgressBooking;
  Future<List<BookingData>>? completedBooking;

  UniqueKey keyForPendingList = UniqueKey();
  UniqueKey keyForInProgressList = UniqueKey();
  UniqueKey keyForCompletedList = UniqueKey();
  bool isLastPage = false;

  List<BookingData> pendingBookingList = [];
  List<BookingData> inProgressBookingList = [];
  List<BookingData> completedBookingList = [];
  late Future<DashboardResponse> future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = providerDashboard();
    inProgressBooking = getBookingList(1,
        perPage: 5,
        status: 'inProgress',
        searchText: "",
        bookings: inProgressBookingList, lastPageCallback: (b) {
      isLastPage = b;
    });
    pendingBooking = getBookingList(1,
        perPage: 5,
        status: 'pending',
        searchText: "",
        bookings: pendingBookingList, lastPageCallback: (b) {
      isLastPage = b;
    });
    completedBooking = getBookingList(1,
        perPage: 5,
        status: 'completed',
        searchText: "",
        bookings: completedBookingList, lastPageCallback: (b) {
      isLastPage = b;
    });
  }

  Widget _buildHeaderWidget(DashboardResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text("${languages.lblHello}, ${appStore.userFullName}",
                style: boldTextStyle(size: 16))
            .paddingLeft(16),
        8.height,
        Text(languages.lblWelcomeBack, style: secondaryTextStyle(size: 14))
            .paddingLeft(16),
        16.height,
      ],
    );
  }

  Widget planBanner(DashboardResponse data) {
    if (data.isPlanExpired.validate()) {
      return subSubscriptionPlanWidget(
        planBgColor:
            appStore.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: languages.lblPlanExpired,
        planSubtitle: languages.lblPlanSubTitle,
        planButtonTxt: languages.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.userNeverPurchasedPlan.validate()) {
      return subSubscriptionPlanWidget(
        planBgColor:
            appStore.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: languages.lblChooseYourPlan,
        planSubtitle: languages.lblRenewSubTitle,
        planButtonTxt: languages.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.isPlanAboutToExpire.validate()) {
      int days = getRemainingPlanDays();

      if (days != 0 && days <= PLAN_REMAINING_DAYS) {
        return subSubscriptionPlanWidget(
          planBgColor:
              appStore.isDarkMode ? context.cardColor : Colors.orange.shade50,
          planTitle: languages.lblReminder,
          planSubtitle: languages.planAboutToExpire(days),
          planButtonTxt: languages.lblRenew,
          btnColor: Colors.orange,
          onTap: () {
            PricingPlanScreen().launch(context);
          },
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<DashboardResponse>(
            initialData: cachedProviderDashboardResponse,
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                return AnimatedScrollView(
                  padding: EdgeInsets.only(bottom: 16),
                  physics: AlwaysScrollableScrollPhysics(),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  children: [
                    if ((snap.data!.earningType == EARNING_TYPE_SUBSCRIPTION))
                      planBanner(snap.data!),
                    _buildHeaderWidget(snap.data!),
                    TodayCashComponent(
                        todayCashAmount: snap.data!.todayCashAmount.validate()),
                    TotalComponent(snap: snap.data!),
                    // ChartComponent(),
                    // #region  Tabbed
                    SizedBox(
                        height: context.height() / 2,
                        child: DefaultTabController(
                            length: 3,
                            child: Scaffold(
                                appBar: TabBar(
                                  onTap: (index) {},
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  indicatorColor: context.primaryColor,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelPadding: const EdgeInsets.all(0.5),
                                  tabs: [
                                    Tab(
                                      text: languages.inProgress,
                                    ),
                                    Tab(
                                      text: languages.pending,
                                    ),
                                    Tab(text: languages.completed),
                                  ],
                                ),
                                body: TabBarView(
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      SnapHelperWidget<List<BookingData>>(
                                        future: inProgressBooking,
                                        loadingWidget: NoSearchBookingShimmer(),
                                        onSuccess: (list) {
                                          return AnimatedListView(
                                            key: keyForInProgressList,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(), // new

                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            listAnimationType:
                                                ListAnimationType.FadeIn,
                                            fadeInConfiguration:
                                                FadeInConfiguration(
                                                    duration: 2.seconds),
                                            itemCount: list.length,
                                            shrinkWrap: true,

                                            emptyWidget: NoDataWidget(
                                              title: languages.noBookingTitle,
                                              imageWidget: EmptyStateWidget(),
                                            ),
                                            itemBuilder: (_, index) =>
                                                BookingItemComponent(
                                                    bookingData: list[index],
                                                    index: index),
                                          );
                                        },
                                        errorBuilder: (error) {
                                          return NoDataWidget(
                                            title: error,
                                            retryText: languages.reload,
                                            imageWidget: ErrorStateWidget(),
                                            onRetry: () {
                                              appStore.setLoading(true);

                                              init();
                                              setState(() {});
                                            },
                                          );
                                        },
                                      ),
                                      SnapHelperWidget<List<BookingData>>(
                                        future: pendingBooking,
                                        loadingWidget: NoSearchBookingShimmer(),
                                        onSuccess: (list) {
                                          return AnimatedListView(
                                            key: keyForPendingList,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(), // new

                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            listAnimationType:
                                                ListAnimationType.FadeIn,
                                            fadeInConfiguration:
                                                FadeInConfiguration(
                                                    duration: 2.seconds),
                                            itemCount: list.length,
                                            shrinkWrap: true,

                                            emptyWidget: NoDataWidget(
                                              title: languages.noBookingTitle,
                                              imageWidget: EmptyStateWidget(),
                                            ),
                                            itemBuilder: (_, index) =>
                                                BookingItemComponent(
                                                    bookingData: list[index],
                                                    index: index),
                                          );
                                        },
                                        errorBuilder: (error) {
                                          return NoDataWidget(
                                            title: error,
                                            retryText: languages.reload,
                                            imageWidget: ErrorStateWidget(),
                                            onRetry: () {
                                              appStore.setLoading(true);

                                              init();
                                              setState(() {});
                                            },
                                          );
                                        },
                                      ),
                                      SnapHelperWidget<List<BookingData>>(
                                        future: completedBooking,
                                        loadingWidget: NoSearchBookingShimmer(),
                                        onSuccess: (list) {
                                          return AnimatedListView(
                                            key: keyForCompletedList,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(), // new

                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            listAnimationType:
                                                ListAnimationType.FadeIn,
                                            fadeInConfiguration:
                                                FadeInConfiguration(
                                                    duration: 2.seconds),
                                            itemCount: list.length,
                                            shrinkWrap: true,

                                            emptyWidget: NoDataWidget(
                                              title: languages.noBookingTitle,
                                              imageWidget: EmptyStateWidget(),
                                            ),
                                            itemBuilder: (_, index) =>
                                                BookingItemComponent(
                                                    bookingData: list[index],
                                                    index: index),
                                          );
                                        },
                                        errorBuilder: (error) {
                                          return NoDataWidget(
                                            title: error,
                                            retryText: languages.reload,
                                            imageWidget: ErrorStateWidget(),
                                            onRetry: () {
                                              appStore.setLoading(true);

                                              init();
                                              setState(() {});
                                            },
                                          );
                                        },
                                      ),
                                    ])))),
// #endregion
                    HandymanRecentlyOnlineComponent(
                        images: snap.data!.onlineHandyman.validate()),
                    HandymanListComponent(list: snap.data!.handyman.validate()),
                    UpcomingBookingComponent(
                        bookingData: snap.data!.upcomingBookings.validate()),
                    JobListComponent(list: snap.data!.myPostJobData.validate())
                        .paddingOnly(left: 16, right: 16, top: 8),
                    ServiceListComponent(list: snap.data!.service.validate()),
                  ],
                  onSwipeRefresh: () async {
                    page = 1;
                    appStore.setLoading(true);

                    init();
                    setState(() {});

                    return await 2.seconds.delay;
                  },
                );
              }

              return snapWidgetHelper(
                snap,
                loadingWidget: ProviderDashboardShimmer(),
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    imageWidget: ErrorStateWidget(),
                    retryText: languages.reload,
                    onRetry: () {
                      page = 1;
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
              builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}

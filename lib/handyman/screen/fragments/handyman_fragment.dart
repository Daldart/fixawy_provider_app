import 'package:fixawy_provider/locale/base_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fixawy_provider/handyman/component/handyman_review_component.dart';
import 'package:fixawy_provider/handyman/component/handyman_total_component.dart';
import 'package:fixawy_provider/handyman/shimmer/handyman_dashboard_shimmer.dart';
import 'package:fixawy_provider/main.dart';
import 'package:fixawy_provider/models/handyman_dashboard_response.dart';
import 'package:fixawy_provider/networks/rest_apis.dart';
import 'package:fixawy_provider/provider/components/chart_component.dart';
import 'package:fixawy_provider/screens/cash_management/component/today_cash_component.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_widgets.dart';
import '../../../components/booking_item_component.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../fragments/booking_fragment.dart';
import '../../../fragments/shimmer/booking_shimmer.dart';
import '../../../fragments/shimmer/noSearchBookingShimmer.dart';
import '../../../models/booking_list_response.dart';
import '../../../provider/components/upcoming_booking_component.dart';

class HandymanHomeFragment extends StatefulWidget {
  const HandymanHomeFragment({Key? key}) : super(key: key);

  @override
  _HandymanHomeFragmentState createState() => _HandymanHomeFragmentState();
}

class _HandymanHomeFragmentState extends State<HandymanHomeFragment> {
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

  late Future<HandymanDashBoardResponse> future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = handymanDashboard();
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

    appStore.setLoading(false);
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
          FutureBuilder<HandymanDashBoardResponse>(
            initialData: cachedHandymanDashboardResponse,
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                return AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 16, top: 16),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration:
                      FadeInConfiguration(duration: 500.milliseconds),
                  children: [
                    Text("${languages.lblHello}, ${appStore.userFullName}",
                            style: boldTextStyle(size: 16))
                        .paddingLeft(16),
                    8.height,
                    Text(languages.lblWelcomeBack,
                            style: secondaryTextStyle(size: 14))
                        .paddingLeft(16),
                    16.height,
                    TodayCashComponent(
                        todayCashAmount: snap.data!.todayCashAmount.validate()),
                    8.height,
                    HandymanTotalComponent(snap: snap.data!),
                    8.height,
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

                    ChartComponent(),
                    UpcomingBookingComponent(
                        bookingData: snap.data!.upcomingBookings.validate()),
                    16.height,
                    HandymanReviewComponent(
                        reviews: snap.data!.handymanReviews.validate()),
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

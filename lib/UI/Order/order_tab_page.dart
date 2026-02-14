import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart';
import 'package:simple/ModelClass/User/getUserModel.dart';
import 'package:simple/ModelClass/Waiter/getWaiterModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:simple/UI/Order/order_list.dart';

class OrdersTabbedScreen extends StatelessWidget {
  final VoidCallback? onRefresh;
  final GlobalKey<OrderViewViewState>? orderAllKey;
  final GlobalKey<OrderTabViewViewState>? orderResetKey;
  const OrdersTabbedScreen({
    super.key,
    this.onRefresh,
    this.orderAllKey,
    this.orderResetKey,
  });

  @override
  Widget build(BuildContext context) {
    // Move BlocProvider to the top level to share state across all tabs
    return BlocProvider(
      create: (_) => OrderTodayBloc(),
      child: OrderTabViewView(
        key: orderResetKey,
        onRefresh: onRefresh,
        orderAllKey: orderAllKey,
      ),
    );
  }
}

class OrderTabViewView extends StatefulWidget {
  final VoidCallback? onRefresh;
  final GlobalKey<OrderViewViewState>? orderAllKey;
  const OrderTabViewView({super.key, this.onRefresh, this.orderAllKey});

  @override
  OrderTabViewViewState createState() => OrderTabViewViewState();
}

class OrderTabViewViewState extends State<OrderTabViewView>
    with SingleTickerProviderStateMixin {
  bool hasRefreshedOrder = false;
  late TabController _tabController;
  GetTableModel getTableModel = GetTableModel();
  GetWaiterModel getWaiterModel = GetWaiterModel();
  GetUserModel getUserModel = GetUserModel();
  GetOrderListTodayModel getOrderListTodayModel = GetOrderListTodayModel();
  dynamic selectedValue;
  dynamic selectedValueWaiter;
  dynamic selectedValueUser;
  dynamic selectedPaymentMode;
  dynamic tableId;
  dynamic waiterId;
  dynamic userId;
  dynamic operatorId;
  dynamic paymentMode;
  bool tableLoad = false;
  bool isLoadingOrders = false;
  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? fromDate;

  // Payment modes list
  final List<String> paymentModes = ['CASH', 'CARD', 'UPI'];

  final List<GlobalKey<OrderViewViewState>> _tabKeys = List.generate(
    6,
        (index) => GlobalKey<OrderViewViewState>(),
  );

  Future<void> getOperatorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      operatorId = prefs.getString("userId");
    });
    debugPrint("operatorId: $operatorId");
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController.index == 0 && widget.orderAllKey != null) {
        setState(() {
          selectedValue = null;
          selectedValueWaiter = null;
          selectedValueUser = null;
          selectedPaymentMode = null;
          tableId = null;
          waiterId = null;
          userId = null;
          paymentMode = null;
          hasRefreshedOrder = false;
          isLoadingOrders = true;
        });
        widget.orderAllKey?.currentState?.refreshOrders();
        setState(() {});
      }
    });
  }

  void resetSelections() {
    setState(() {
      selectedValue = null;
      selectedValueWaiter = null;
      selectedValueUser = null;
      selectedPaymentMode = null;
      tableId = null;
      waiterId = null;
      userId = null;
      paymentMode = null;
      hasRefreshedOrder = false;
      isLoadingOrders = true;
    });
    context.read<OrderTodayBloc>().add(
      OrderTodayList(todayDate, todayDate, "", "", "", ""),
    );
  }

  void _loadInitialData() {
    if (isLoadingOrders) return;
    debugPrint("tableIntialLoad:$selectedValue");
    getOperatorId();
    setState(() {
      selectedValue = null;
      selectedValueWaiter = null;
      selectedValueUser = null;
      selectedPaymentMode = null;
      tableId = null;
      waiterId = null;
      userId = null;
      paymentMode = null;
      hasRefreshedOrder = false;
      isLoadingOrders = true;
    });
    context.read<OrderTodayBloc>().add(
      OrderTodayList(todayDate, todayDate, "", "", "", ""),
    );
    context.read<OrderTodayBloc>().add(TableDine());
    context.read<OrderTodayBloc>().add(WaiterDine());
    context.read<OrderTodayBloc>().add(UserDetails());
  }

  void _refreshAllTabs() {
    if (isLoadingOrders) return;

    setState(() {
      isLoadingOrders = true;
    });
    debugPrint("refreshTab");
    context.read<OrderTodayBloc>().add(
      OrderTodayList(
        todayDate,
        todayDate,
        tableId ?? "",
        waiterId ?? "",
        userId ?? "",
        paymentMode ?? "",
      ),
    );
  }

  void _refreshData() {
    setState(() {
      selectedValue = null;
      selectedValueWaiter = null;
      selectedValueUser = null;
      selectedPaymentMode = null;
      tableId = null;
      waiterId = null;
      userId = null;
      paymentMode = null;
      hasRefreshedOrder = false;
      isLoadingOrders = true; // Set loading state
    });
    _tabController.animateTo(0);
    context.read<OrderTodayBloc>().add(TableDine());
    context.read<OrderTodayBloc>().add(WaiterDine());
    context.read<OrderTodayBloc>().add(UserDetails());
    context.read<OrderTodayBloc>().add(
      OrderTodayList(
        todayDate,
        todayDate,
        tableId ?? "",
        waiterId ?? "",
        userId ?? "",
        paymentMode ?? "",
      ),
    );
  }

  void _onFilterChanged() {
    _refreshAllTabs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContainer() {
      return DefaultTabController(
        length: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Orders",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: appPrimaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _refreshData();
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: appPrimaryColor,
                      size: 28,
                    ),
                    tooltip: 'Refresh Orders',
                  ),
                ],
              ),
            ),
            // First row of dropdown labels
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Select Table',
                      style: MyTextStyle.f14(
                        blackColor,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Select Waiter',
                      style: MyTextStyle.f14(
                        blackColor,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Select Operator',
                      style: MyTextStyle.f14(
                        blackColor,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Payment Mode',
                      style: MyTextStyle.f14(
                        blackColor,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Second row of dropdowns
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: DropdownButtonFormField<String>(
                      value: (getTableModel.data?.any(
                            (item) => item.name == selectedValue,
                      ) ??
                          false)
                          ? selectedValue
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: appPrimaryColor),
                        ),
                      ),
                      items: getTableModel.data?.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            "Table ${item.name}",
                            style: MyTextStyle.f14(
                              blackColor,
                              weight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedValue = newValue;
                            final selectedItem = getTableModel.data?.firstWhere(
                                  (item) => item.name == newValue,
                            );
                            tableId = selectedItem?.id.toString();
                          });
                          _onFilterChanged();
                        }
                      },
                      hint: Text(
                        '-- Select Table --',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: DropdownButtonFormField<String>(
                      value: (getWaiterModel.data?.any(
                            (item) => item.name == selectedValueWaiter,
                      ) ??
                          false)
                          ? selectedValueWaiter
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: appPrimaryColor),
                        ),
                      ),
                      items: getWaiterModel.data?.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            "${item.name}",
                            style: MyTextStyle.f14(
                              blackColor,
                              weight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedValueWaiter = newValue;
                            final selectedItem = getWaiterModel.data
                                ?.firstWhere((item) => item.name == newValue);
                            waiterId = selectedItem?.id.toString();
                          });
                          _onFilterChanged();
                        }
                      },
                      hint: Text(
                        '-- Select Waiter --',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: DropdownButtonFormField<String>(
                      value: (getUserModel.data?.any(
                            (item) => item.name == selectedValueUser,
                      ) ??
                          false)
                          ? selectedValueUser
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: appPrimaryColor),
                        ),
                      ),
                      items: getUserModel.data?.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            "${item.name}",
                            style: MyTextStyle.f14(
                              blackColor,
                              weight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedValueUser = newValue;
                            final selectedItem = getUserModel.data?.firstWhere(
                                  (item) => item.name == newValue,
                            );
                            userId = selectedItem?.id.toString();
                          });
                          debugPrint("operatorSelectr:$userId");
                          _onFilterChanged();
                        }
                      },
                      hint: Text(
                        '-- Select Operator --',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                // New Payment Mode Dropdown
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: DropdownButtonFormField<String>(
                      value: selectedPaymentMode,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: appPrimaryColor),
                        ),
                      ),
                      items: paymentModes.map((mode) {
                        return DropdownMenuItem<String>(
                          value: mode,
                          child: Text(
                            mode,
                            style: MyTextStyle.f14(
                              blackColor,
                              weight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedPaymentMode = newValue;
                            paymentMode = newValue;
                          });
                          _onFilterChanged();
                        }
                      },
                      hint: Text(
                        '-- Select Mode --',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              labelColor: appPrimaryColor,
              unselectedLabelColor: greyColor,
              indicatorColor: appPrimaryColor,
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Line"),
                Tab(text: "Parcel"),
                Tab(text: "AC"),
                Tab(text: "HD"),
                Tab(text: "SWIGGY"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  OrderViewView(
                    key: widget.orderAllKey ?? _tabKeys[0],
                    type: 'All',
                    selectedTableName: tableId,
                    selectedWaiterName: waiterId,
                    selectOperator: userId,
                    selectedPaymentMode: paymentMode,
                    operatorShared: operatorId,
                    sharedOrderData: getOrderListTodayModel,
                    isLoading: isLoadingOrders,
                  ),
                  OrderViewView(
                    key: _tabKeys[1],
                    type: 'Line',
                    selectedTableName: tableId,
                    selectedWaiterName: waiterId,
                    selectOperator: userId,
                    selectedPaymentMode: paymentMode,
                    operatorShared: operatorId,
                    sharedOrderData: getOrderListTodayModel,
                    isLoading: isLoadingOrders,
                  ),

                  OrderViewView(
                    key: _tabKeys[2],
                    type: 'Parcel',
                    selectedTableName: tableId,
                    selectedWaiterName: waiterId,
                    selectOperator: userId,
                    selectedPaymentMode: paymentMode,
                    operatorShared: operatorId,
                    sharedOrderData: getOrderListTodayModel,
                    isLoading: isLoadingOrders,
                  ),
                  OrderViewView(
                    key: _tabKeys[3],
                    type: 'AC',
                    selectedTableName: tableId,
                    selectedWaiterName: waiterId,
                    selectOperator: userId,
                    selectedPaymentMode: paymentMode,
                    operatorShared: operatorId,
                    sharedOrderData: getOrderListTodayModel,
                    isLoading: isLoadingOrders,
                  ),
                  OrderViewView(
                    key: _tabKeys[4],
                    type: 'HD',
                    selectedTableName: tableId,
                    selectedWaiterName: waiterId,
                    selectOperator: userId,
                    selectedPaymentMode: paymentMode,
                    operatorShared: operatorId,
                    sharedOrderData: getOrderListTodayModel,
                    isLoading: isLoadingOrders,
                  ),
                  OrderViewView(
                    key: _tabKeys[5],
                    type: 'SWIGGY',
                    selectedTableName: tableId,
                    selectedWaiterName: waiterId,
                    selectOperator: userId,
                    selectedPaymentMode: paymentMode,
                    operatorShared: operatorId,
                    sharedOrderData: getOrderListTodayModel,
                    isLoading: isLoadingOrders,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<OrderTodayBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetOrderListTodayModel) {
          getOrderListTodayModel = current;
          if (getOrderListTodayModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          setState(() {
            isLoadingOrders = false;
            tableLoad = false;
          });
          return true;
        }
        if (current is GetTableModel) {
          getTableModel = current;
          if (getTableModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getTableModel.success == true) {
            setState(() {
              tableLoad = false;
            });
          } else {
            setState(() {
              tableLoad = false;
            });
            showToast("No Tables found", context, color: false);
          }
          return true;
        }
        if (current is GetWaiterModel) {
          getWaiterModel = current;
          if (getWaiterModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getWaiterModel.success == true) {
            setState(() {
              tableLoad = false;
            });
          } else {
            setState(() {
              tableLoad = false;
            });
            showToast("No Waiter found", context, color: false);
          }
          return true;
        }
        if (current is GetUserModel) {
          getUserModel = current;
          if (getUserModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getUserModel.success == true) {
            setState(() {
              tableLoad = false;
            });
          } else {
            setState(() {
              tableLoad = false;
            });
            showToast("No Operator found", context, color: false);
          }
          return true;
        }
        return false;
      }),
      builder: (context, dynamic) {
        return mainContainer();
      },
    );
  }

  void _handle401Error() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("token");
    await sharedPreferences.clear();
    showToast("Session expired. Please login again.", context, color: false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
}
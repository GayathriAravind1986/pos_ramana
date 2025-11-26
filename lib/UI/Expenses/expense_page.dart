import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Expense/expense_bloc.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';

class ExpenseView extends StatelessWidget {
  final GlobalKey<ExpenseViewViewState>? expenseKey;
  bool? hasRefreshedExpense;
  ExpenseView({
    super.key,
    this.expenseKey,
    this.hasRefreshedExpense,
  });

  @override
  Widget build(BuildContext context) {
    return ExpenseViewView(
        expenseKey: expenseKey, hasRefreshedExpense: hasRefreshedExpense);
  }
}

class ExpenseViewView extends StatefulWidget {
  final GlobalKey<ExpenseViewViewState>? expenseKey;
  bool? hasRefreshedExpense;
  ExpenseViewView({
    super.key,
    this.expenseKey,
    this.hasRefreshedExpense,
  });

  @override
  ExpenseViewViewState createState() => ExpenseViewViewState();
}

class ExpenseViewViewState extends State<ExpenseViewView> {
  GetLocationModel getLocationModel = GetLocationModel();
  GetCategoryModel getCategoryModel = GetCategoryModel();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String? selectedLocation;
  String? selectedCategory;
  String? selectedCategoryFilter;
  String? categoryId;
  String? categoryIdFilter;
  String? selectedPayment;
  String? locationId;
  List<String> categories = ["Pongal", "Festival", "Food", "Travel"];
  List<String> paymentMethods = ["Card", "Cash", "Bank Transfer", "UPI"];
  bool categoryLoad = false;
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appPrimaryColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    appPrimaryColor, // OK & Cancel button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  bool stockLoad = false;
  String? errorMessage;

  void refreshExpense() {
    if (!mounted || !context.mounted) return;
    context.read<ExpenseBloc>().add(StockInLocation());
    setState(() {
      stockLoad = true;
    });
  }

  final List<Map<String, dynamic>> expenses = [
    {
      "date": "24/11/2025",
      "location": "Andhra",
      "category": "laddu",
      "name": "ram",
      "amount": "₹10.00",
      "method": "Bank Transfer",
    },
    {
      "date": "15/09/2025",
      "location": "Ambasamudram",
      "category": "black forest cake",
      "name": "sfd",
      "amount": "₹800.00",
      "method": "Card",
    },
    {
      "date": "13/08/2025",
      "location": "Nagercoil",
      "category": "evt",
      "name": "abcdee",
      "amount": "₹38.00",
      "method": "Cash",
    },
  ];
  @override
  void initState() {
    super.initState();
    dateController.text =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    context.read<ExpenseBloc>().add(ProductCategory());
    if (widget.hasRefreshedExpense == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          stockLoad = true;
        });
        widget.expenseKey?.currentState?.refreshExpense();
      });
    } else {
      context.read<ExpenseBloc>().add(StockInLocation());
      setState(() {
        stockLoad = true;
      });
    }
  }

  void _refreshData() {
    setState(() {
      // selectedValue = null;
      // categoryId = null;
    });
    context.read<ExpenseBloc>().add(StockInLocation());
    context.read<ExpenseBloc>().add(ProductCategory());
    widget.expenseKey?.currentState?.refreshExpense();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Expense",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ---------------- Row 1 ----------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Date",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: pickDate,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  getLocationModel.data?.locationName != null
                      ? Expanded(
                          child: TextFormField(
                            enabled: false,
                            initialValue: getLocationModel.data!.locationName!,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              labelStyle: TextStyle(color: appPrimaryColor),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: greyColor),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: greyColor),
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),

              const SizedBox(height: 15),

              // ---------------- Row 2 ----------------
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (getCategoryModel.data?.any(
                                  (item) => item.name == selectedCategory) ??
                              false)
                          ? selectedCategory
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: appPrimaryColor,
                          ),
                        ),
                      ),
                      items: getCategoryModel.data?.map((item) {
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
                            selectedCategory = newValue;
                            final selectedItem = getCategoryModel.data
                                ?.firstWhere((item) => item.name == newValue);
                            categoryId = selectedItem?.id.toString();
                          });
                        }
                      },
                      hint: Text(
                        'Category *',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedPayment,
                      items: paymentMethods
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedPayment = v),
                      decoration: const InputDecoration(
                        labelText: "Payment Method *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ---------------- Row 3 ----------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    "SAVE",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Expenses List",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Filters",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Search by name...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (getCategoryModel.data?.any((item) =>
                                  item.name == selectedCategoryFilter) ??
                              false)
                          ? selectedCategoryFilter
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: appPrimaryColor,
                          ),
                        ),
                      ),
                      items: getCategoryModel.data?.map((item) {
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
                            selectedCategoryFilter = newValue;
                            final selectedItem = getCategoryModel.data
                                ?.firstWhere((item) => item.name == newValue);
                            categoryIdFilter = selectedItem?.id.toString();
                          });
                        }
                      },
                      hint: Text(
                        'All Categories',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Payment Method",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        "All Methods",
                        "Cash",
                        "UPI",
                        "Card",
                        "Bank Transfer"
                      ]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {},
                      value: "All Methods",
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text("CLEAR FILTERS"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Replace your DataTable widget with this responsive version

              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate column widths based on available screen width
                  final availableWidth = constraints.maxWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth:
                            availableWidth, // Ensures table takes full width
                      ),
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(Colors.grey.shade200),
                        dataRowHeight: 55,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        columnSpacing:
                            availableWidth * 0.02, // 2% of screen width
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              width: availableWidth * 0.12,
                              child: const Text("Date"),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: availableWidth * 0.15,
                              child: const Text("Location"),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: availableWidth * 0.15,
                              child: const Text("Category"),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: availableWidth * 0.15,
                              child: const Text("Name"),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: availableWidth * 0.12,
                              child: const Text("Amount"),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: availableWidth * 0.16,
                              child: const Text("Payment Method"),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: availableWidth * 0.13,
                              child: const Text("Actions"),
                            ),
                          ),
                        ],
                        rows: expenses.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: availableWidth * 0.12,
                                  child: Text(
                                    item["date"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: availableWidth * 0.15,
                                  child: Text(
                                    item["location"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: availableWidth * 0.15,
                                  child: Text(
                                    item["category"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: availableWidth * 0.15,
                                  child: Text(
                                    item["name"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: availableWidth * 0.12,
                                  child: Text(
                                    item["amount"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: availableWidth * 0.16,
                                  child: Text(
                                    item["method"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: availableWidth * 0.13,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                        onPressed: () {},
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        onPressed: () {},
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      );
    }

    return BlocBuilder<ExpenseBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetLocationModel) {
          getLocationModel = current;
          if (getLocationModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getLocationModel.success == true) {
            locationId = getLocationModel.data?.locationId;
            debugPrint("locationId:$locationId");
            setState(() {
              stockLoad = false;
            });
          } else {
            debugPrint("${getLocationModel.data?.locationName}");
            setState(() {
              stockLoad = false;
            });
            showToast("No Location found", context, color: false);
          }
          return true;
        }
        if (current is GetCategoryModel) {
          getCategoryModel = current;
          if (getCategoryModel.success == true) {
            setState(() {
              categoryLoad = false;
            });
          }
          if (getCategoryModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
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

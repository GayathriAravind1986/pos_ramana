import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/LastOrder/lastorderbloc.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';

class OrderNumberDialog extends StatefulWidget {
  const OrderNumberDialog({super.key});

  @override
  State<OrderNumberDialog> createState() => _OrderNumberDialogState();
}

class _OrderNumberDialogState extends State<OrderNumberDialog> {
  final TextEditingController _orderController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// Fetch last order safely after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LastOrderBloc>().add(FetchLastOrder());
    });
  }

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: size.width * 0.4,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),

            /// Bloc Builder for Displaying Last Order
            BlocBuilder<LastOrderBloc, LastOrderState>(
              buildWhen: (previous, current) =>
              current is LastOrderLoading ||
                  current is LastOrderLoaded ||
                  current is LastOrderError,
              builder: (context, state) {
                String displayOrderNo = "Loading...";

                if (state is LastOrderLoaded) {
                  displayOrderNo = state.orders.isNotEmpty
                      ? state.orders[0].orderNumber ?? "N/A"
                      : "No Records";
                } else if (state is LastOrderError) {
                  displayOrderNo = "Error";
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Row(
                    children: [
                      Text(
                        "Last Order Number: ",
                        style: MyTextStyle.f16(
                            weight: FontWeight.w500, Colors.black87),
                      ),
                      Text(
                        displayOrderNo,
                        style: MyTextStyle.f16(
                            weight: FontWeight.bold, appPrimaryColor),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter Order Number",
                    style: MyTextStyle.f14(
                        weight: FontWeight.w500, Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _orderController,
                    decoration: InputDecoration(
                      hintText: "Order number",
                      hintStyle: MyTextStyle.f14(
                          weight: FontWeight.normal, Colors.grey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: appPrimaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),

            /// Buttons with integrated POST Logic and Error Handling
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "CANCEL",
                      style: MyTextStyle.f14(weight: FontWeight.w600, greyColor),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Wrap Submit button with BlocConsumer for the POST action
                  BlocConsumer<LastOrderBloc, LastOrderState>(
                    listener: (context, state) {
                      if (state is ChangeOrderNumberSuccess) {
                        showToast(state.message, context);
                        Navigator.of(context).pop(); // Close on success
                      }
                      // --- NEW ERROR HANDLING LOGIC ---
                      else if (state is LastOrderError) {
                        // If API returns an error, show "Order not found" or the API message
                        String errorMessage = state.message;
                        if (errorMessage.toLowerCase().contains("not found") || errorMessage.isEmpty) {
                          showToast("Order not found", context);
                        } else {
                          showToast(errorMessage, context);
                        }
                      }
                    },
                    builder: (context, state) {
                      bool isSubmitting = state is ChangeOrderNumberSubmitting;

                      return ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                          if (_orderController.text.isNotEmpty) {
                            // Call Post API via Bloc
                            context.read<LastOrderBloc>().add(
                                ChangeOrderNumber(_orderController.text.trim()));
                          } else {
                            showToast("Please enter an order number", context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: appPrimaryColor,
                            minimumSize: const Size(100, 45)),
                        child: isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : Text(
                          "SUBMIT",
                          style: MyTextStyle.f14(
                              weight: FontWeight.w600, whiteColor),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "POS Shops",
            style: MyTextStyle.f20(weight: FontWeight.bold, appPrimaryColor),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: greyColor, size: 24),
          ),
        ],
      ),
    );
  }
}


void showOrderNumberDialog(BuildContext parentContext) {
  showDialog(
    context: parentContext,
    builder: (_) {
      return BlocProvider.value(
        value: parentContext.read<LastOrderBloc>(),
        child: const OrderNumberDialog(),
      );
    },
  );
}
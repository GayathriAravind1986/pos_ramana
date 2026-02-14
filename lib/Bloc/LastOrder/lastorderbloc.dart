import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Api/apiProvider.dart';
import '../../ModelClass/LastOrder/GetLastOrderModel.dart';
import '../../ModelClass/LastOrder/PostOrderIdModel.dart';


// --- Events ---
abstract class LastOrderEvent {}

class FetchLastOrder extends LastOrderEvent {}

// New Event for POST request
class ChangeOrderNumber extends LastOrderEvent {
  final String orderId;
  ChangeOrderNumber(this.orderId);
}

// --- States ---
abstract class LastOrderState {}

class LastOrderInitial extends LastOrderState {}

class LastOrderLoading extends LastOrderState {}

// Added a specific loading state for the submission process
class ChangeOrderNumberSubmitting extends LastOrderState {}

class LastOrderLoaded extends LastOrderState {
  final List<Data> orders;
  LastOrderLoaded(this.orders);
}

class LastOrderError extends LastOrderState {
  final String message;
  LastOrderError(this.message);
}

// Added a success state for the POST request
class ChangeOrderNumberSuccess extends LastOrderState {
  final String message;
  ChangeOrderNumberSuccess(this.message);
}

// --- Bloc ---
class LastOrderBloc extends Bloc<LastOrderEvent, LastOrderState> {
  final ApiProvider apiProvider = ApiProvider();

  LastOrderBloc() : super(LastOrderInitial()) {

    // --- Fetch Logic (GET) ---
    on<FetchLastOrder>((event, emit) async {
      emit(LastOrderLoading());
      try {
        final GetLastOrderModel response = await apiProvider.getLastOrderAPI();
        if (response.errorResponse == null) {
          if (response.data != null && response.data!.isNotEmpty) {
            emit(LastOrderLoaded(response.data!));
          } else {
            emit(LastOrderError("No recent orders found."));
          }
        } else {
          emit(LastOrderError(response.errorResponse?.message ?? "Failed to fetch last order"));
        }
      } catch (e) {
        emit(LastOrderError("An unexpected error occurred: $e"));
      }
    });

    // --- Change Order Logic (POST) ---
    on<ChangeOrderNumber>((event, emit) async {
      emit(ChangeOrderNumberSubmitting()); // Show loader on button
      try {
        final PostOrderIdModel response = await apiProvider.changeOrderNumberAPI(event.orderId);

        if (response.errorResponse == null) {
          // Success: Emit success message
          emit(ChangeOrderNumberSuccess(response.message ?? "Order number updated successfully"));

          // Optional: Re-fetch the last order to update the UI with the new number
          add(FetchLastOrder());
        } else {
          // Failure: Emit error from API
          emit(LastOrderError(response.errorResponse?.message ?? "Failed to update order number"));
        }
      } catch (e) {
        emit(LastOrderError("An unexpected error occurred: $e"));
      }
    });
  }
}
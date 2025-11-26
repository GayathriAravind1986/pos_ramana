import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class ExpenseEvent {}

class StockInLocation extends ExpenseEvent {}

class ProductCategory extends ExpenseEvent {}

class ExpenseBloc extends Bloc<ExpenseEvent, dynamic> {
  ExpenseBloc() : super(dynamic) {
    on<StockInLocation>((event, emit) async {
      await ApiProvider().getLocationAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<ProductCategory>((event, emit) async {
      await ApiProvider().getCategoryAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
  }
}

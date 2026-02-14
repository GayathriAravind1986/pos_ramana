import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

GetLastOrderModel getLastOrderModelFromJson(String str) => GetLastOrderModel.fromJson(json.decode(str));
String getLastOrderModelToJson(GetLastOrderModel data) => json.encode(data.toJson());

class GetLastOrderModel {
  GetLastOrderModel({
    bool? success,
    List<Data>? data,
    this.errorResponse,
  }) {
    _success = success;
    _data = data;
  }

  GetLastOrderModel.fromJson(dynamic json) {
    // --- Error Message Implementation ---
    if (json['success'] == false || json['errors'] != null) {
      if (json['errors'] != null) {
        errorResponse = ErrorResponse.fromJson(json['errors']);
      } else if (json['message'] != null) {
        errorResponse = ErrorResponse(
          message: json['message'].toString(),
          statusCode: json['status'] ?? 400,
        );
      }
    }

    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }

  bool? _success;
  List<Data>? _data;
  ErrorResponse? errorResponse; // Public error field

  GetLastOrderModel copyWith({
    bool? success,
    List<Data>? data,
    ErrorResponse? errorResponse,
  }) => GetLastOrderModel(
    success: success ?? _success,
    data: data ?? _data,
    errorResponse: errorResponse ?? this.errorResponse,
  );

  bool? get success => _success;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    if (errorResponse != null) {
      map['errors'] = errorResponse?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    String? id,
    String? orderNumber,
    List<Items>? items,
    List<FinalTaxes>? finalTaxes,
    num? subtotal,
    num? tax,
    num? total,
    dynamic tableNo,
    dynamic waiter,
    String? orderType,
    bool? isDeleted,
    String? orderStatus,
    String? operator,
    String? locationId,
    bool? isDiscountApplied,
    num? discountAmount,
    num? tipAmount,
    String? notes,
    String? createdAt,
    String? updatedAt,
    num? orderSequence,
    num? v,
  }) {
    _id = id;
    _orderNumber = orderNumber;
    _items = items;
    _finalTaxes = finalTaxes;
    _subtotal = subtotal;
    _tax = tax;
    _total = total;
    _tableNo = tableNo;
    _waiter = waiter;
    _orderType = orderType;
    _isDeleted = isDeleted;
    _orderStatus = orderStatus;
    _operator = operator;
    _locationId = locationId;
    _isDiscountApplied = isDiscountApplied;
    _discountAmount = discountAmount;
    _tipAmount = tipAmount;
    _notes = notes;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _orderSequence = orderSequence;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _orderNumber = json['orderNumber'];
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }
    if (json['finalTaxes'] != null) {
      _finalTaxes = [];
      json['finalTaxes'].forEach((v) {
        _finalTaxes?.add(FinalTaxes.fromJson(v));
      });
    }
    _subtotal = json['subtotal'];
    _tax = json['tax'];
    _total = json['total'];
    _tableNo = json['tableNo'];
    _waiter = json['waiter'];
    _orderType = json['orderType'];
    _isDeleted = json['isDeleted'];
    _orderStatus = json['orderStatus'];
    _operator = json['operator'];
    _locationId = json['locationId'];
    _isDiscountApplied = json['isDiscountApplied'];
    _discountAmount = json['discountAmount'];
    _tipAmount = json['tipAmount'];
    _notes = json['notes'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _orderSequence = json['orderSequence'];
    _v = json['__v'];
  }

  String? _id;
  String? _orderNumber;
  List<Items>? _items;
  List<FinalTaxes>? _finalTaxes;
  num? _subtotal;
  num? _tax;
  num? _total;
  dynamic _tableNo;
  dynamic _waiter;
  String? _orderType;
  bool? _isDeleted;
  String? _orderStatus;
  String? _operator;
  String? _locationId;
  bool? _isDiscountApplied;
  num? _discountAmount;
  num? _tipAmount;
  String? _notes;
  String? _createdAt;
  String? _updatedAt;
  num? _orderSequence;
  num? _v;

  // Getters
  String? get id => _id;
  String? get orderNumber => _orderNumber;
  List<Items>? get items => _items;
  List<FinalTaxes>? get finalTaxes => _finalTaxes;
  num? get subtotal => _subtotal;
  num? get tax => _tax;
  num? get total => _total;
  dynamic get tableNo => _tableNo;
  dynamic get waiter => _waiter;
  String? get orderType => _orderType;
  bool? get isDeleted => _isDeleted;
  String? get orderStatus => _orderStatus;
  String? get operator => _operator;
  String? get locationId => _locationId;
  bool? get isDiscountApplied => _isDiscountApplied;
  num? get discountAmount => _discountAmount;
  num? get tipAmount => _tipAmount;
  String? get notes => _notes;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get orderSequence => _orderSequence;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['orderNumber'] = _orderNumber;
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    if (_finalTaxes != null) {
      map['finalTaxes'] = _finalTaxes?.map((v) => v.toJson()).toList();
    }
    map['subtotal'] = _subtotal;
    map['tax'] = _tax;
    map['total'] = _total;
    map['tableNo'] = _tableNo;
    map['waiter'] = _waiter;
    map['orderType'] = _orderType;
    map['isDeleted'] = _isDeleted;
    map['orderStatus'] = _orderStatus;
    map['operator'] = _operator;
    map['locationId'] = _locationId;
    map['isDiscountApplied'] = _isDiscountApplied;
    map['discountAmount'] = _discountAmount;
    map['tipAmount'] = _tipAmount;
    map['notes'] = _notes;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['orderSequence'] = _orderSequence;
    map['__v'] = _v;
    return map;
  }
}

class FinalTaxes {
  FinalTaxes({String? name, String? amount, num? percentage, String? id}) {
    _name = name;
    _amount = amount;
    _percentage = percentage;
    _id = id;
  }

  FinalTaxes.fromJson(dynamic json) {
    _name = json['name'];
    _amount = json['amount'];
    _percentage = json['percentage'];
    _id = json['_id'];
  }
  String? _name;
  String? _amount;
  num? _percentage;
  String? _id;

  String? get name => _name;
  String? get amount => _amount;
  num? get percentage => _percentage;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['amount'] = _amount;
    map['percentage'] = _percentage;
    map['_id'] = _id;
    return map;
  }
}

class Items {
  Items({
    String? product,
    String? name,
    num? quantity,
    num? unitPrice,
    List<dynamic>? addons,
    num? tax,
    num? subtotal,
    String? id,
  }) {
    _product = product;
    _name = name;
    _quantity = quantity;
    _unitPrice = unitPrice;
    _addons = addons;
    _tax = tax;
    _subtotal = subtotal;
    _id = id;
  }

  Items.fromJson(dynamic json) {
    _product = json['product'];
    _name = json['name'];
    _quantity = json['quantity'];
    _unitPrice = json['unitPrice'];
    _addons = json['addons'] != null ? List<dynamic>.from(json['addons']) : [];
    _tax = json['tax'];
    _subtotal = json['subtotal'];
    _id = json['_id'];
  }
  String? _product;
  String? _name;
  num? _quantity;
  num? _unitPrice;
  List<dynamic>? _addons;
  num? _tax;
  num? _subtotal;
  String? _id;

  String? get product => _product;
  String? get name => _name;
  num? get quantity => _quantity;
  num? get unitPrice => _unitPrice;
  List<dynamic>? get addons => _addons;
  num? get tax => _tax;
  num? get subtotal => _subtotal;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['product'] = _product;
    map['name'] = _name;
    map['quantity'] = _quantity;
    map['unitPrice'] = _unitPrice;
    if (_addons != null) {
      map['addons'] = _addons;
    }
    map['tax'] = _tax;
    map['subtotal'] = _subtotal;
    map['_id'] = _id;
    return map;
  }
}
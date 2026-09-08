// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderResponse extends OrderResponse {
  @override
  final String? id;
  @override
  final String? customerId;
  @override
  final String? status;
  @override
  final num? totalAmount;
  @override
  final String? currency;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? reservedUntil;
  @override
  final int? reservationSecondsRemaining;

  factory _$OrderResponse([void Function(OrderResponseBuilder)? updates]) =>
      (OrderResponseBuilder()..update(updates))._build();

  _$OrderResponse._({
    this.id,
    this.customerId,
    this.status,
    this.totalAmount,
    this.currency,
    this.createdAt,
    this.reservedUntil,
    this.reservationSecondsRemaining,
  }) : super._();
  @override
  OrderResponse rebuild(void Function(OrderResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderResponseBuilder toBuilder() => OrderResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderResponse &&
        id == other.id &&
        customerId == other.customerId &&
        status == other.status &&
        totalAmount == other.totalAmount &&
        currency == other.currency &&
        createdAt == other.createdAt &&
        reservedUntil == other.reservedUntil &&
        reservationSecondsRemaining == other.reservationSecondsRemaining;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, customerId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, totalAmount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, reservedUntil.hashCode);
    _$hash = $jc(_$hash, reservationSecondsRemaining.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderResponse')
          ..add('id', id)
          ..add('customerId', customerId)
          ..add('status', status)
          ..add('totalAmount', totalAmount)
          ..add('currency', currency)
          ..add('createdAt', createdAt)
          ..add('reservedUntil', reservedUntil)
          ..add('reservationSecondsRemaining', reservationSecondsRemaining))
        .toString();
  }
}

class OrderResponseBuilder
    implements Builder<OrderResponse, OrderResponseBuilder> {
  _$OrderResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _customerId;
  String? get customerId => _$this._customerId;
  set customerId(String? customerId) => _$this._customerId = customerId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  num? _totalAmount;
  num? get totalAmount => _$this._totalAmount;
  set totalAmount(num? totalAmount) => _$this._totalAmount = totalAmount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _reservedUntil;
  DateTime? get reservedUntil => _$this._reservedUntil;
  set reservedUntil(DateTime? reservedUntil) =>
      _$this._reservedUntil = reservedUntil;

  int? _reservationSecondsRemaining;
  int? get reservationSecondsRemaining => _$this._reservationSecondsRemaining;
  set reservationSecondsRemaining(int? reservationSecondsRemaining) =>
      _$this._reservationSecondsRemaining = reservationSecondsRemaining;

  OrderResponseBuilder() {
    OrderResponse._defaults(this);
  }

  OrderResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _customerId = $v.customerId;
      _status = $v.status;
      _totalAmount = $v.totalAmount;
      _currency = $v.currency;
      _createdAt = $v.createdAt;
      _reservedUntil = $v.reservedUntil;
      _reservationSecondsRemaining = $v.reservationSecondsRemaining;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderResponse other) {
    _$v = other as _$OrderResponse;
  }

  @override
  void update(void Function(OrderResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderResponse build() => _build();

  _$OrderResponse _build() {
    final _$result =
        _$v ??
        _$OrderResponse._(
          id: id,
          customerId: customerId,
          status: status,
          totalAmount: totalAmount,
          currency: currency,
          createdAt: createdAt,
          reservedUntil: reservedUntil,
          reservationSecondsRemaining: reservationSecondsRemaining,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

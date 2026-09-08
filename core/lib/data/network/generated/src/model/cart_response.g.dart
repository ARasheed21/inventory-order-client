// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CartResponse extends CartResponse {
  @override
  final String? id;
  @override
  final String? customerId;
  @override
  final String? productId;
  @override
  final int? quantity;

  factory _$CartResponse([void Function(CartResponseBuilder)? updates]) =>
      (CartResponseBuilder()..update(updates))._build();

  _$CartResponse._({this.id, this.customerId, this.productId, this.quantity})
    : super._();
  @override
  CartResponse rebuild(void Function(CartResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CartResponseBuilder toBuilder() => CartResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CartResponse &&
        id == other.id &&
        customerId == other.customerId &&
        productId == other.productId &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, customerId.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CartResponse')
          ..add('id', id)
          ..add('customerId', customerId)
          ..add('productId', productId)
          ..add('quantity', quantity))
        .toString();
  }
}

class CartResponseBuilder
    implements Builder<CartResponse, CartResponseBuilder> {
  _$CartResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _customerId;
  String? get customerId => _$this._customerId;
  set customerId(String? customerId) => _$this._customerId = customerId;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  CartResponseBuilder() {
    CartResponse._defaults(this);
  }

  CartResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _customerId = $v.customerId;
      _productId = $v.productId;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CartResponse other) {
    _$v = other as _$CartResponse;
  }

  @override
  void update(void Function(CartResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CartResponse build() => _build();

  _$CartResponse _build() {
    final _$result =
        _$v ??
        _$CartResponse._(
          id: id,
          customerId: customerId,
          productId: productId,
          quantity: quantity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

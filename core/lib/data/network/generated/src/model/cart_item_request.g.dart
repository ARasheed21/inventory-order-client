// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CartItemRequest extends CartItemRequest {
  @override
  final String productId;
  @override
  final int? quantity;

  factory _$CartItemRequest([void Function(CartItemRequestBuilder)? updates]) =>
      (CartItemRequestBuilder()..update(updates))._build();

  _$CartItemRequest._({required this.productId, this.quantity}) : super._();
  @override
  CartItemRequest rebuild(void Function(CartItemRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CartItemRequestBuilder toBuilder() => CartItemRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CartItemRequest &&
        productId == other.productId &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CartItemRequest')
          ..add('productId', productId)
          ..add('quantity', quantity))
        .toString();
  }
}

class CartItemRequestBuilder
    implements Builder<CartItemRequest, CartItemRequestBuilder> {
  _$CartItemRequest? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  CartItemRequestBuilder() {
    CartItemRequest._defaults(this);
  }

  CartItemRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CartItemRequest other) {
    _$v = other as _$CartItemRequest;
  }

  @override
  void update(void Function(CartItemRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CartItemRequest build() => _build();

  _$CartItemRequest _build() {
    final _$result =
        _$v ??
        _$CartItemRequest._(
          productId: BuiltValueNullFieldError.checkNotNull(
            productId,
            r'CartItemRequest',
            'productId',
          ),
          quantity: quantity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

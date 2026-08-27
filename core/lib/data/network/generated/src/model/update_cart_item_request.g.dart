// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_cart_item_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateCartItemRequest extends UpdateCartItemRequest {
  @override
  final String? productId;
  @override
  final int? quantity;

  factory _$UpdateCartItemRequest([
    void Function(UpdateCartItemRequestBuilder)? updates,
  ]) => (UpdateCartItemRequestBuilder()..update(updates))._build();

  _$UpdateCartItemRequest._({this.productId, this.quantity}) : super._();
  @override
  UpdateCartItemRequest rebuild(
    void Function(UpdateCartItemRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateCartItemRequestBuilder toBuilder() =>
      UpdateCartItemRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateCartItemRequest &&
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
    return (newBuiltValueToStringHelper(r'UpdateCartItemRequest')
          ..add('productId', productId)
          ..add('quantity', quantity))
        .toString();
  }
}

class UpdateCartItemRequestBuilder
    implements Builder<UpdateCartItemRequest, UpdateCartItemRequestBuilder> {
  _$UpdateCartItemRequest? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  UpdateCartItemRequestBuilder() {
    UpdateCartItemRequest._defaults(this);
  }

  UpdateCartItemRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateCartItemRequest other) {
    _$v = other as _$UpdateCartItemRequest;
  }

  @override
  void update(void Function(UpdateCartItemRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateCartItemRequest build() => _build();

  _$UpdateCartItemRequest _build() {
    final _$result =
        _$v ??
        _$UpdateCartItemRequest._(productId: productId, quantity: quantity);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

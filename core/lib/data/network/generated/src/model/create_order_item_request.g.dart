// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_item_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateOrderItemRequest extends CreateOrderItemRequest {
  @override
  final String productId;
  @override
  final int? quantity;

  factory _$CreateOrderItemRequest([
    void Function(CreateOrderItemRequestBuilder)? updates,
  ]) => (CreateOrderItemRequestBuilder()..update(updates))._build();

  _$CreateOrderItemRequest._({required this.productId, this.quantity})
    : super._();
  @override
  CreateOrderItemRequest rebuild(
    void Function(CreateOrderItemRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateOrderItemRequestBuilder toBuilder() =>
      CreateOrderItemRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateOrderItemRequest &&
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
    return (newBuiltValueToStringHelper(r'CreateOrderItemRequest')
          ..add('productId', productId)
          ..add('quantity', quantity))
        .toString();
  }
}

class CreateOrderItemRequestBuilder
    implements Builder<CreateOrderItemRequest, CreateOrderItemRequestBuilder> {
  _$CreateOrderItemRequest? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  CreateOrderItemRequestBuilder() {
    CreateOrderItemRequest._defaults(this);
  }

  CreateOrderItemRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateOrderItemRequest other) {
    _$v = other as _$CreateOrderItemRequest;
  }

  @override
  void update(void Function(CreateOrderItemRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateOrderItemRequest build() => _build();

  _$CreateOrderItemRequest _build() {
    final _$result =
        _$v ??
        _$CreateOrderItemRequest._(
          productId: BuiltValueNullFieldError.checkNotNull(
            productId,
            r'CreateOrderItemRequest',
            'productId',
          ),
          quantity: quantity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

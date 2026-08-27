// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InventoryResponse extends InventoryResponse {
  @override
  final String? productId;
  @override
  final String? name;
  @override
  final int? quantityInStock;

  factory _$InventoryResponse([
    void Function(InventoryResponseBuilder)? updates,
  ]) => (InventoryResponseBuilder()..update(updates))._build();

  _$InventoryResponse._({this.productId, this.name, this.quantityInStock})
    : super._();
  @override
  InventoryResponse rebuild(void Function(InventoryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InventoryResponseBuilder toBuilder() =>
      InventoryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InventoryResponse &&
        productId == other.productId &&
        name == other.name &&
        quantityInStock == other.quantityInStock;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantityInStock.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InventoryResponse')
          ..add('productId', productId)
          ..add('name', name)
          ..add('quantityInStock', quantityInStock))
        .toString();
  }
}

class InventoryResponseBuilder
    implements Builder<InventoryResponse, InventoryResponseBuilder> {
  _$InventoryResponse? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _quantityInStock;
  int? get quantityInStock => _$this._quantityInStock;
  set quantityInStock(int? quantityInStock) =>
      _$this._quantityInStock = quantityInStock;

  InventoryResponseBuilder() {
    InventoryResponse._defaults(this);
  }

  InventoryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _name = $v.name;
      _quantityInStock = $v.quantityInStock;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InventoryResponse other) {
    _$v = other as _$InventoryResponse;
  }

  @override
  void update(void Function(InventoryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InventoryResponse build() => _build();

  _$InventoryResponse _build() {
    final _$result =
        _$v ??
        _$InventoryResponse._(
          productId: productId,
          name: name,
          quantityInStock: quantityInStock,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

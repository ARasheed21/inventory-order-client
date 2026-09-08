// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reserved_inventory_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservedInventoryItem extends ReservedInventoryItem {
  @override
  final String? productId;
  @override
  final String? name;
  @override
  final int? quantityInStock;
  @override
  final int? quantityReserved;
  @override
  final int? quantityAvailable;

  factory _$ReservedInventoryItem([
    void Function(ReservedInventoryItemBuilder)? updates,
  ]) => (ReservedInventoryItemBuilder()..update(updates))._build();

  _$ReservedInventoryItem._({
    this.productId,
    this.name,
    this.quantityInStock,
    this.quantityReserved,
    this.quantityAvailable,
  }) : super._();
  @override
  ReservedInventoryItem rebuild(
    void Function(ReservedInventoryItemBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReservedInventoryItemBuilder toBuilder() =>
      ReservedInventoryItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservedInventoryItem &&
        productId == other.productId &&
        name == other.name &&
        quantityInStock == other.quantityInStock &&
        quantityReserved == other.quantityReserved &&
        quantityAvailable == other.quantityAvailable;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantityInStock.hashCode);
    _$hash = $jc(_$hash, quantityReserved.hashCode);
    _$hash = $jc(_$hash, quantityAvailable.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservedInventoryItem')
          ..add('productId', productId)
          ..add('name', name)
          ..add('quantityInStock', quantityInStock)
          ..add('quantityReserved', quantityReserved)
          ..add('quantityAvailable', quantityAvailable))
        .toString();
  }
}

class ReservedInventoryItemBuilder
    implements Builder<ReservedInventoryItem, ReservedInventoryItemBuilder> {
  _$ReservedInventoryItem? _$v;

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

  int? _quantityReserved;
  int? get quantityReserved => _$this._quantityReserved;
  set quantityReserved(int? quantityReserved) =>
      _$this._quantityReserved = quantityReserved;

  int? _quantityAvailable;
  int? get quantityAvailable => _$this._quantityAvailable;
  set quantityAvailable(int? quantityAvailable) =>
      _$this._quantityAvailable = quantityAvailable;

  ReservedInventoryItemBuilder() {
    ReservedInventoryItem._defaults(this);
  }

  ReservedInventoryItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _name = $v.name;
      _quantityInStock = $v.quantityInStock;
      _quantityReserved = $v.quantityReserved;
      _quantityAvailable = $v.quantityAvailable;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservedInventoryItem other) {
    _$v = other as _$ReservedInventoryItem;
  }

  @override
  void update(void Function(ReservedInventoryItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservedInventoryItem build() => _build();

  _$ReservedInventoryItem _build() {
    final _$result =
        _$v ??
        _$ReservedInventoryItem._(
          productId: productId,
          name: name,
          quantityInStock: quantityInStock,
          quantityReserved: quantityReserved,
          quantityAvailable: quantityAvailable,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductResponse extends ProductResponse {
  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? price;
  @override
  final String? currency;
  @override
  final int? quantityInStock;
  @override
  final String? category;

  factory _$ProductResponse([void Function(ProductResponseBuilder)? updates]) =>
      (ProductResponseBuilder()..update(updates))._build();

  _$ProductResponse._({
    this.id,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.quantityInStock,
    this.category,
  }) : super._();
  @override
  ProductResponse rebuild(void Function(ProductResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductResponseBuilder toBuilder() => ProductResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductResponse &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        price == other.price &&
        currency == other.currency &&
        quantityInStock == other.quantityInStock &&
        category == other.category;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, quantityInStock.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductResponse')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description)
          ..add('price', price)
          ..add('currency', currency)
          ..add('quantityInStock', quantityInStock)
          ..add('category', category))
        .toString();
  }
}

class ProductResponseBuilder
    implements Builder<ProductResponse, ProductResponseBuilder> {
  _$ProductResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _price;
  String? get price => _$this._price;
  set price(String? price) => _$this._price = price;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _quantityInStock;
  int? get quantityInStock => _$this._quantityInStock;
  set quantityInStock(int? quantityInStock) =>
      _$this._quantityInStock = quantityInStock;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  ProductResponseBuilder() {
    ProductResponse._defaults(this);
  }

  ProductResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _price = $v.price;
      _currency = $v.currency;
      _quantityInStock = $v.quantityInStock;
      _category = $v.category;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductResponse other) {
    _$v = other as _$ProductResponse;
  }

  @override
  void update(void Function(ProductResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductResponse build() => _build();

  _$ProductResponse _build() {
    final _$result =
        _$v ??
        _$ProductResponse._(
          id: id,
          name: name,
          description: description,
          price: price,
          currency: currency,
          quantityInStock: quantityInStock,
          category: category,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

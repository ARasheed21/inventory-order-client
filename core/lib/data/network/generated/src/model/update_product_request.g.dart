// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_product_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateProductRequest extends UpdateProductRequest {
  @override
  final String name;
  @override
  final String? description;
  @override
  final String price;
  @override
  final String currency;
  @override
  final int quantityInStock;
  @override
  final String? category;

  factory _$UpdateProductRequest([
    void Function(UpdateProductRequestBuilder)? updates,
  ]) => (UpdateProductRequestBuilder()..update(updates))._build();

  _$UpdateProductRequest._({
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    required this.quantityInStock,
    this.category,
  }) : super._();
  @override
  UpdateProductRequest rebuild(
    void Function(UpdateProductRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateProductRequestBuilder toBuilder() =>
      UpdateProductRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateProductRequest &&
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
    return (newBuiltValueToStringHelper(r'UpdateProductRequest')
          ..add('name', name)
          ..add('description', description)
          ..add('price', price)
          ..add('currency', currency)
          ..add('quantityInStock', quantityInStock)
          ..add('category', category))
        .toString();
  }
}

class UpdateProductRequestBuilder
    implements Builder<UpdateProductRequest, UpdateProductRequestBuilder> {
  _$UpdateProductRequest? _$v;

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

  UpdateProductRequestBuilder() {
    UpdateProductRequest._defaults(this);
  }

  UpdateProductRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(UpdateProductRequest other) {
    _$v = other as _$UpdateProductRequest;
  }

  @override
  void update(void Function(UpdateProductRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateProductRequest build() => _build();

  _$UpdateProductRequest _build() {
    final _$result =
        _$v ??
        _$UpdateProductRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'UpdateProductRequest',
            'name',
          ),
          description: description,
          price: BuiltValueNullFieldError.checkNotNull(
            price,
            r'UpdateProductRequest',
            'price',
          ),
          currency: BuiltValueNullFieldError.checkNotNull(
            currency,
            r'UpdateProductRequest',
            'currency',
          ),
          quantityInStock: BuiltValueNullFieldError.checkNotNull(
            quantityInStock,
            r'UpdateProductRequest',
            'quantityInStock',
          ),
          category: category,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

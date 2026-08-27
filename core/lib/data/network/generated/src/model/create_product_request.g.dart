// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_product_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateProductRequest extends CreateProductRequest {
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

  factory _$CreateProductRequest([
    void Function(CreateProductRequestBuilder)? updates,
  ]) => (CreateProductRequestBuilder()..update(updates))._build();

  _$CreateProductRequest._({
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    required this.quantityInStock,
    this.category,
  }) : super._();
  @override
  CreateProductRequest rebuild(
    void Function(CreateProductRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateProductRequestBuilder toBuilder() =>
      CreateProductRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateProductRequest &&
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
    return (newBuiltValueToStringHelper(r'CreateProductRequest')
          ..add('name', name)
          ..add('description', description)
          ..add('price', price)
          ..add('currency', currency)
          ..add('quantityInStock', quantityInStock)
          ..add('category', category))
        .toString();
  }
}

class CreateProductRequestBuilder
    implements Builder<CreateProductRequest, CreateProductRequestBuilder> {
  _$CreateProductRequest? _$v;

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

  CreateProductRequestBuilder() {
    CreateProductRequest._defaults(this);
  }

  CreateProductRequestBuilder get _$this {
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
  void replace(CreateProductRequest other) {
    _$v = other as _$CreateProductRequest;
  }

  @override
  void update(void Function(CreateProductRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateProductRequest build() => _build();

  _$CreateProductRequest _build() {
    final _$result =
        _$v ??
        _$CreateProductRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CreateProductRequest',
            'name',
          ),
          description: description,
          price: BuiltValueNullFieldError.checkNotNull(
            price,
            r'CreateProductRequest',
            'price',
          ),
          currency: BuiltValueNullFieldError.checkNotNull(
            currency,
            r'CreateProductRequest',
            'currency',
          ),
          quantityInStock: BuiltValueNullFieldError.checkNotNull(
            quantityInStock,
            r'CreateProductRequest',
            'quantityInStock',
          ),
          category: category,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

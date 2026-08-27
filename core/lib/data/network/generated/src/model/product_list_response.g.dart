// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductListResponse extends ProductListResponse {
  @override
  final BuiltList<ProductResponse>? content;
  @override
  final int? total;
  @override
  final int? page;
  @override
  final int? size;

  factory _$ProductListResponse([
    void Function(ProductListResponseBuilder)? updates,
  ]) => (ProductListResponseBuilder()..update(updates))._build();

  _$ProductListResponse._({this.content, this.total, this.page, this.size})
    : super._();
  @override
  ProductListResponse rebuild(
    void Function(ProductListResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ProductListResponseBuilder toBuilder() =>
      ProductListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductListResponse &&
        content == other.content &&
        total == other.total &&
        page == other.page &&
        size == other.size;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductListResponse')
          ..add('content', content)
          ..add('total', total)
          ..add('page', page)
          ..add('size', size))
        .toString();
  }
}

class ProductListResponseBuilder
    implements Builder<ProductListResponse, ProductListResponseBuilder> {
  _$ProductListResponse? _$v;

  ListBuilder<ProductResponse>? _content;
  ListBuilder<ProductResponse> get content =>
      _$this._content ??= ListBuilder<ProductResponse>();
  set content(ListBuilder<ProductResponse>? content) =>
      _$this._content = content;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _size;
  int? get size => _$this._size;
  set size(int? size) => _$this._size = size;

  ProductListResponseBuilder() {
    ProductListResponse._defaults(this);
  }

  ProductListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content?.toBuilder();
      _total = $v.total;
      _page = $v.page;
      _size = $v.size;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductListResponse other) {
    _$v = other as _$ProductListResponse;
  }

  @override
  void update(void Function(ProductListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductListResponse build() => _build();

  _$ProductListResponse _build() {
    _$ProductListResponse _$result;
    try {
      _$result =
          _$v ??
          _$ProductListResponse._(
            content: _content?.build(),
            total: total,
            page: page,
            size: size,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        _content?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ProductListResponse',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

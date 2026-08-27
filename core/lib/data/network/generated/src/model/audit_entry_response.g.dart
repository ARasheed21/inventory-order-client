// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_entry_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditEntryResponse extends AuditEntryResponse {
  @override
  final int? revision;
  @override
  final int? timestamp;
  @override
  final String? author;
  @override
  final String? revisionType;
  @override
  final BuiltMap<String, JsonObject?>? snapshot;

  factory _$AuditEntryResponse([
    void Function(AuditEntryResponseBuilder)? updates,
  ]) => (AuditEntryResponseBuilder()..update(updates))._build();

  _$AuditEntryResponse._({
    this.revision,
    this.timestamp,
    this.author,
    this.revisionType,
    this.snapshot,
  }) : super._();
  @override
  AuditEntryResponse rebuild(
    void Function(AuditEntryResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuditEntryResponseBuilder toBuilder() =>
      AuditEntryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditEntryResponse &&
        revision == other.revision &&
        timestamp == other.timestamp &&
        author == other.author &&
        revisionType == other.revisionType &&
        snapshot == other.snapshot;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, revisionType.hashCode);
    _$hash = $jc(_$hash, snapshot.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditEntryResponse')
          ..add('revision', revision)
          ..add('timestamp', timestamp)
          ..add('author', author)
          ..add('revisionType', revisionType)
          ..add('snapshot', snapshot))
        .toString();
  }
}

class AuditEntryResponseBuilder
    implements Builder<AuditEntryResponse, AuditEntryResponseBuilder> {
  _$AuditEntryResponse? _$v;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  int? _timestamp;
  int? get timestamp => _$this._timestamp;
  set timestamp(int? timestamp) => _$this._timestamp = timestamp;

  String? _author;
  String? get author => _$this._author;
  set author(String? author) => _$this._author = author;

  String? _revisionType;
  String? get revisionType => _$this._revisionType;
  set revisionType(String? revisionType) => _$this._revisionType = revisionType;

  MapBuilder<String, JsonObject?>? _snapshot;
  MapBuilder<String, JsonObject?> get snapshot =>
      _$this._snapshot ??= MapBuilder<String, JsonObject?>();
  set snapshot(MapBuilder<String, JsonObject?>? snapshot) =>
      _$this._snapshot = snapshot;

  AuditEntryResponseBuilder() {
    AuditEntryResponse._defaults(this);
  }

  AuditEntryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _revision = $v.revision;
      _timestamp = $v.timestamp;
      _author = $v.author;
      _revisionType = $v.revisionType;
      _snapshot = $v.snapshot?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditEntryResponse other) {
    _$v = other as _$AuditEntryResponse;
  }

  @override
  void update(void Function(AuditEntryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditEntryResponse build() => _build();

  _$AuditEntryResponse _build() {
    _$AuditEntryResponse _$result;
    try {
      _$result =
          _$v ??
          _$AuditEntryResponse._(
            revision: revision,
            timestamp: timestamp,
            author: author,
            revisionType: revisionType,
            snapshot: _snapshot?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'snapshot';
        _snapshot?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AuditEntryResponse',
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

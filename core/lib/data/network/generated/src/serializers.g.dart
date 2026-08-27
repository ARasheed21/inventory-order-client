// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers =
    (Serializers().toBuilder()
          ..add(ApiError.serializer)
          ..add(AuditEntryResponse.serializer)
          ..add(CartItemRequest.serializer)
          ..add(CartResponse.serializer)
          ..add(CreateOrderItemRequest.serializer)
          ..add(CreateOrderRequest.serializer)
          ..add(CreateProductRequest.serializer)
          ..add(InventoryResponse.serializer)
          ..add(LoginRequest.serializer)
          ..add(OrderResponse.serializer)
          ..add(ProductListResponse.serializer)
          ..add(ProductResponse.serializer)
          ..add(RefreshRequest.serializer)
          ..add(RegisterRequest.serializer)
          ..add(RegisterResponse.serializer)
          ..add(ReservedInventoryItem.serializer)
          ..add(UpdateCartItemRequest.serializer)
          ..add(UpdateProductRequest.serializer)
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(CreateOrderItemRequest),
            ]),
            () => ListBuilder<CreateOrderItemRequest>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(ProductResponse)]),
            () => ListBuilder<ProductResponse>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          ))
        .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:core/data/network/generated/src/date_serializer.dart';
import 'package:core/data/network/generated/src/model/date.dart';

import 'package:core/data/network/generated/src/model/api_error.dart';
import 'package:core/data/network/generated/src/model/audit_entry_response.dart';
import 'package:core/data/network/generated/src/model/cart_item_request.dart';
import 'package:core/data/network/generated/src/model/cart_response.dart';
import 'package:core/data/network/generated/src/model/create_order_item_request.dart';
import 'package:core/data/network/generated/src/model/create_order_request.dart';
import 'package:core/data/network/generated/src/model/create_product_request.dart';
import 'package:core/data/network/generated/src/model/inventory_response.dart';
import 'package:core/data/network/generated/src/model/login_request.dart';
import 'package:core/data/network/generated/src/model/order_response.dart';
import 'package:core/data/network/generated/src/model/product_list_response.dart';
import 'package:core/data/network/generated/src/model/product_response.dart';
import 'package:core/data/network/generated/src/model/refresh_request.dart';
import 'package:core/data/network/generated/src/model/register_request.dart';
import 'package:core/data/network/generated/src/model/register_response.dart';
import 'package:core/data/network/generated/src/model/reserved_inventory_item.dart';
import 'package:core/data/network/generated/src/model/update_cart_item_request.dart';
import 'package:core/data/network/generated/src/model/update_product_request.dart';

part 'serializers.g.dart';

@SerializersFor([
  ApiError,
  AuditEntryResponse,
  CartItemRequest,
  CartResponse,
  CreateOrderItemRequest,
  CreateOrderRequest,
  CreateProductRequest,
  InventoryResponse,
  LoginRequest,
  OrderResponse,
  ProductListResponse,
  ProductResponse,
  RefreshRequest,
  RegisterRequest,
  RegisterResponse,
  ReservedInventoryItem,
  UpdateCartItemRequest,
  UpdateProductRequest,
])
Serializers serializers =
    (_$serializers.toBuilder()
          ..addBuilderFactory(
            const FullType(BuiltList, [FullType(ReservedInventoryItem)]),
            () => ListBuilder<ReservedInventoryItem>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, [FullType(CartResponse)]),
            () => ListBuilder<CartResponse>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, [FullType(CreateOrderItemRequest)]),
            () => ListBuilder<CreateOrderItemRequest>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, [FullType(AuditEntryResponse)]),
            () => ListBuilder<AuditEntryResponse>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, [
              FullType(String),
              FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, [FullType(OrderResponse)]),
            () => ListBuilder<OrderResponse>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, [FullType(ProductResponse)]),
            () => ListBuilder<ProductResponse>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, [FullType(String), FullType(JsonObject)]),
            () => MapBuilder<String, JsonObject>(),
          )
          ..add(const OneOfSerializer())
          ..add(const AnyOfSerializer())
          ..add(const DateSerializer())
          ..add(Iso8601DateTimeSerializer()))
        .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

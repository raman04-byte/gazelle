import 'dart:convert';
import 'dart:io';

import 'gazelle_message.dart';
import 'gazelle_model_provider.dart';

/// Transforms a [GazelleResponse] to a [HttpResponse].
void gazelleResponseToHttpResponse({
  required GazelleResponse gazelleResponse,
  required HttpResponse httpResponse,
  GazelleModelProvider? modelProvider,
}) {
  httpResponse.statusCode = gazelleResponse.statusCode.code;

  for (final header in gazelleResponse.headers.toSet()) {
    httpResponse.headers.add(header.header, header.values);
  }

  if (gazelleResponse.body == null) {
    httpResponse.close();
    return;
  }

  final body = _serialize(gazelleResponse.body, modelProvider);
  dynamic httpBody;

  if (_isPrimitive(body)) {
    httpResponse.headers.add(HttpHeaders.contentTypeHeader.toString(),
        [ContentType.text.toString()]);
    httpBody = body;
  } else {
    httpResponse.headers.add(HttpHeaders.contentTypeHeader.toString(),
        [ContentType.json.toString()]);
    httpBody = jsonEncode(body);
  }

  httpResponse.write(httpBody);
  httpResponse.close();
}

dynamic _serialize(
  dynamic object,
  GazelleModelProvider? modelProvider,
) {
  // When GazelleResponse.body is a Dart primitive type
  if (_isPrimitive(object)) {
    // Simply return it
    return _serializePrimitive(object);
  }

  // When GazelleResponse.body is a List
  if (object is List) {
    final list = object;

    // When the list is empty, return an empty json list
    if (list.isEmpty) {
      return [];
    } else {
      // Serialize every item inside it
      final items =
          list.map((item) => _serialize(item, modelProvider)).toList();

      // And return it
      return items;
    }
  }

  // Whene the body is a Map
  if (object is Map) {
    final map = object;

    // Json map to be returned
    final jsonMap = {};

    // Iterate its entries
    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      // Serialize key and value
      final jsonKey = _serialize(key, modelProvider);
      final jsonValue = _serialize(value, modelProvider);

      // Assign them to the json map
      jsonMap[jsonKey.toString()] = jsonValue;
    }

    // Return the json map
    return jsonMap;
  }

  if (modelProvider == null) {
    return object.toString();
  }

  // When the body is not a primitive not a List and not a Map
  // Get the correct model type
  final modelType = modelProvider.getModelTypeFor(object.runtimeType);

  // Return the relative json map
  return modelType.toJson(object);
}

dynamic _serializePrimitive(dynamic primitive) {
  if (primitive is DateTime) {
    return primitive.toIso8601String();
  }

  if (primitive is Duration) {
    return primitive.inMicroseconds;
  }

  if (primitive is BigInt) {
    return primitive.toString();
  }

  if (primitive is Uri) {
    return primitive.toString();
  }

  return primitive;
}

bool _isPrimitive(dynamic object) =>
    object is String ||
    object is num ||
    object is bool ||
    object is DateTime ||
    object is Duration ||
    object is BigInt ||
    object is Uri;

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/client.dart';
import '../models/client_delete.dart';
import '../models/client_update.dart';
import '../models/clients.dart';

part 'clients_api.g.dart';

@RestApi()
abstract class ClientsApi {
  factory ClientsApi(Dio dio, {String? baseUrl}) = _ClientsApi;

  /// Get information about configured clients
  @GET('/clients')
  Future<Clients> clientsStatus();

  /// Add a new client
  @POST('/clients/add')
  Future<void> clientsAdd({@Body() required Client body});

  /// Remove a client
  @POST('/clients/delete')
  Future<void> clientsDelete({@Body() required ClientDelete body});

  /// Update client information
  @POST('/clients/update')
  Future<void> clientsUpdate({@Body() required ClientUpdate body});
}

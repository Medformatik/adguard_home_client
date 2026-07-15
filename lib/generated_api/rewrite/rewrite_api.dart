// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/rewrite_entry.dart';
import '../models/rewrite_list.dart';
import '../models/rewrite_update.dart';

part 'rewrite_api.g.dart';

@RestApi()
abstract class RewriteApi {
  factory RewriteApi(Dio dio, {String? baseUrl}) = _RewriteApi;

  /// Get list of Rewrite rules
  @GET('/rewrite/list')
  Future<RewriteList> rewriteList();

  /// Add a new Rewrite rule
  @POST('/rewrite/add')
  Future<void> rewriteAdd({@Body() required RewriteEntry body});

  /// Remove a Rewrite rule
  @POST('/rewrite/delete')
  Future<void> rewriteDelete({@Body() required RewriteEntry body});

  /// Update a Rewrite rule
  @PUT('/rewrite/update')
  Future<void> rewriteUpdate({@Body() required RewriteUpdate body});
}

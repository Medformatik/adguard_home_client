// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dns_answer.dart';
import 'dns_question.dart';
import 'filtering_reason.dart';
import 'query_log_item_client.dart';
import 'query_log_item_client_proto.dart';
import 'result_rule.dart';

part 'query_log_item.g.dart';

/// Query log item
@JsonSerializable()
class QueryLogItem {
  const QueryLogItem({
    this.answer,
    this.originalAnswer,
    this.cached,
    this.upstream,
    this.answerDnssec,
    this.client,
    this.clientId,
    this.clientInfo,
    this.clientProto,
    this.ecs,
    this.elapsedMs,
    this.question,
    this.filterId,
    this.rule,
    this.rules,
    this.reason,
    this.serviceName,
    this.status,
    this.time,
  });

  factory QueryLogItem.fromJson(Map<String, Object?> json) =>
      _$QueryLogItemFromJson(json);

  final List<DnsAnswer>? answer;

  /// Answer from upstream server (optional)
  @JsonKey(name: 'original_answer')
  final List<DnsAnswer>? originalAnswer;

  /// Defines if the response has been served from cache.
  ///
  final bool? cached;

  /// Upstream URL starting with tcp://, tls://, https://, or with an IP address.
  ///
  final String? upstream;

  /// If true, the response had the Authenticated Data (AD) flag set.
  ///
  @JsonKey(name: 'answer_dnssec')
  final bool? answerDnssec;

  /// The client's IP address.
  ///
  final String? client;

  /// The ClientID, if provided in DoH, DoQ, or DoT.
  ///
  @JsonKey(name: 'client_id')
  final String? clientId;
  @JsonKey(name: 'client_info')
  final QueryLogItemClient? clientInfo;
  @JsonKey(name: 'client_proto')
  final QueryLogItemClientProto? clientProto;

  /// The IP network defined by an EDNS Client-Subnet option in the request message if any.
  ///
  final String? ecs;
  final String? elapsedMs;
  final DnsQuestion? question;

  /// In case if there's a rule applied to this DNS request, this is ID of the filter list that the rule belongs to.
  /// Deprecated: use `rules[*].filter_list_id` instead.
  ///
  final int? filterId;

  /// Filtering rule applied to the request (if any).
  /// Deprecated: use `rules[*].text` instead.
  ///
  final String? rule;

  /// Applied rules.
  final List<ResultRule>? rules;
  final FilteringReason? reason;

  /// Set if reason=FilteredBlockedService
  @JsonKey(name: 'service_name')
  final String? serviceName;

  /// DNS response status
  final String? status;

  /// DNS request processing start time
  final String? time;

  Map<String, Object?> toJson() => _$QueryLogItemToJson(this);
}

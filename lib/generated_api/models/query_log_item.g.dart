// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_log_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueryLogItem _$QueryLogItemFromJson(Map<String, dynamic> json) => QueryLogItem(
  answer: (json['answer'] as List<dynamic>?)
      ?.map((e) => DnsAnswer.fromJson(e as Map<String, dynamic>))
      .toList(),
  originalAnswer: (json['original_answer'] as List<dynamic>?)
      ?.map((e) => DnsAnswer.fromJson(e as Map<String, dynamic>))
      .toList(),
  cached: json['cached'] as bool?,
  upstream: json['upstream'] as String?,
  answerDnssec: json['answer_dnssec'] as bool?,
  client: json['client'] as String?,
  clientId: json['client_id'] as String?,
  clientInfo: json['client_info'] == null
      ? null
      : QueryLogItemClient.fromJson(
          json['client_info'] as Map<String, dynamic>,
        ),
  clientProto: json['client_proto'] == null
      ? null
      : QueryLogItemClientProto.fromJson(json['client_proto'] as String),
  ecs: json['ecs'] as String?,
  elapsedMs: json['elapsedMs'] as String?,
  question: json['question'] == null
      ? null
      : DnsQuestion.fromJson(json['question'] as Map<String, dynamic>),
  filterId: (json['filterId'] as num?)?.toInt(),
  rule: json['rule'] as String?,
  rules: (json['rules'] as List<dynamic>?)
      ?.map((e) => ResultRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  reason: json['reason'] == null
      ? null
      : FilteringReason.fromJson(json['reason'] as String),
  serviceName: json['service_name'] as String?,
  status: json['status'] as String?,
  time: json['time'] as String?,
);

Map<String, dynamic> _$QueryLogItemToJson(QueryLogItem instance) =>
    <String, dynamic>{
      'answer': instance.answer,
      'original_answer': instance.originalAnswer,
      'cached': instance.cached,
      'upstream': instance.upstream,
      'answer_dnssec': instance.answerDnssec,
      'client': instance.client,
      'client_id': instance.clientId,
      'client_info': instance.clientInfo,
      'client_proto': _$QueryLogItemClientProtoEnumMap[instance.clientProto],
      'ecs': instance.ecs,
      'elapsedMs': instance.elapsedMs,
      'question': instance.question,
      'filterId': instance.filterId,
      'rule': instance.rule,
      'rules': instance.rules,
      'reason': _$FilteringReasonEnumMap[instance.reason],
      'service_name': instance.serviceName,
      'status': instance.status,
      'time': instance.time,
    };

const _$QueryLogItemClientProtoEnumMap = {
  QueryLogItemClientProto.dot: 'dot',
  QueryLogItemClientProto.doh: 'doh',
  QueryLogItemClientProto.doq: 'doq',
  QueryLogItemClientProto.dnscrypt: 'dnscrypt',
  QueryLogItemClientProto.empty: '',
  QueryLogItemClientProto.$unknown: r'$unknown',
};

const _$FilteringReasonEnumMap = {
  FilteringReason.notFilteredNotFound: 'NotFilteredNotFound',
  FilteringReason.notFilteredWhiteList: 'NotFilteredWhiteList',
  FilteringReason.notFilteredError: 'NotFilteredError',
  FilteringReason.filteredBlackList: 'FilteredBlackList',
  FilteringReason.filteredSafeBrowsing: 'FilteredSafeBrowsing',
  FilteringReason.filteredParental: 'FilteredParental',
  FilteringReason.filteredInvalid: 'FilteredInvalid',
  FilteringReason.filteredSafeSearch: 'FilteredSafeSearch',
  FilteringReason.filteredBlockedService: 'FilteredBlockedService',
  FilteringReason.rewrite: 'Rewrite',
  FilteringReason.rewriteEtcHosts: 'RewriteEtcHosts',
  FilteringReason.rewriteRule: 'RewriteRule',
  FilteringReason.$unknown: r'$unknown',
};

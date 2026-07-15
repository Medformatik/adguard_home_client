import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/generated_api/models/blocked_service.dart'
    as api;
import 'package:adguard_home_client/generated_api/models/blocked_services_schedule.dart';
import 'package:adguard_home_client/generated_api/models/schedule.dart';

class BlockedService {
  final String id;
  final String name;
  final String? groupId;
  final String? groupName;
  final String? iconSvg;

  BlockedService({
    required this.id,
    required this.name,
    this.groupId,
    this.groupName,
    this.iconSvg,
  });

  factory BlockedService.fromJson(
    dynamic json, [
    Map<String, String>? groupNames,
  ]) {
    if (json is String) {
      final id = json;
      return BlockedService(
        id: id,
        name: _formatServiceName(id, id),
        groupId: null,
        groupName: null,
        iconSvg: null,
      );
    }
    if (json is Map) {
      final id = json['id'] as String? ?? '';
      final rawName = json['name'] as String? ?? id;
      final groupId =
          json['group_id'] as String? ?? json['category'] as String?;
      final iconSvg = json['icon_svg'] as String? ?? json['icon'] as String?;
      final groupName = (groupId != null && groupNames != null)
          ? groupNames[groupId]
          : null;
      return BlockedService(
        id: id,
        name: _formatServiceName(rawName, id),
        groupId: groupId,
        groupName: groupName,
        iconSvg: iconSvg,
      );
    }
    return BlockedService(id: '', name: '');
  }
}

String _formatServiceName(String rawName, String id) {
  // 1. Predefined map of known brand names for perfect casing
  final knownBrands = {
    'youtube': 'YouTube',
    'tiktok': 'TikTok',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'twitter': 'Twitter / X',
    'discord': 'Discord',
    'steam': 'Steam',
    'roblox': 'Roblox',
    'telegram': 'Telegram',
    'netflix': 'Netflix',
    'reddit': 'Reddit',
    'twitch': 'Twitch',
    'whatsapp': 'WhatsApp',
    'wechat': 'WeChat',
    'vimeo': 'Vimeo',
    'dailymotion': 'Dailymotion',
    'pinterest': 'Pinterest',
    'leagueoflegends': 'League of Legends',
    'onlyfans': 'OnlyFans',
    'epic_games': 'Epic Games',
    'epicgames': 'Epic Games',
    'riot_games': 'Riot Games',
    'riotgames': 'Riot Games',
    'origin': 'Origin',
    'minecraft': 'Minecraft',
    'playstation': 'PlayStation',
    'nintendoswitch': 'Nintendo Switch',
    'battlenet': 'Battle.net',
    'apple': 'Apple',
    'amazon': 'Amazon',
    'google': 'Google',
    'skype': 'Skype',
    'viber': 'Viber',
    'snapchat': 'Snapchat',
    'tinder': 'Tinder',
    'badoo': 'Badoo',
    'okcupid': 'OkCupid',
    'grindr': 'Grindr',
    'tumblr': 'Tumblr',
    'flickr': 'Flickr',
    'linkedin': 'LinkedIn',
    'vk': 'VK',
    'odnoklassniki': 'Odnoklassniki',
    'mail_ru': 'Mail.ru',
    'yandex': 'Yandex',
    'qzone': 'Qzone',
    'weibo': 'Weibo',
    'line': 'Line',
    'kakaotalk': 'KakaoTalk',
    'icq': 'ICQ',
    'teamspeak': 'TeamSpeak',
    'ventrilode': 'Ventrilo',
    'mumble': 'Mumble',
    'slack': 'Slack',
    'microsoft_teams': 'Microsoft Teams',
    'zoom': 'Zoom',
    'webex': 'Webex',
    'gotomeeting': 'GoToMeeting',
    'uplay': 'Uplay',
    'gog': 'GOG',
    'itch_io': 'Itch.io',
    'patreon': 'Patreon',
    'substack': 'Substack',
    'medium': 'Medium',
    'deviantart': 'DeviantArt',
    'quora': 'Quora',
    'stumbleupon': 'StumbleUpon',
    'soundcloud': 'SoundCloud',
    'spotify': 'Spotify',
    'deezer': 'Deezer',
    'pandora': 'Pandora',
    'tidal': 'Tidal',
    'applemusic': 'Apple Music',
    'googleplaymusic': 'Google Play Music',
    'youtube_music': 'YouTube Music',
    'tunein': 'TuneIn',
    'shazam': 'Shazam',
    'lastfm': 'Last.fm',
    'rakuten_viki': 'Rakuten Viki',
    'pluto_tv': 'Pluto TV',
    'disneyplus': 'Disney+',
    'hulu': 'Hulu',
    'amazonprime': 'Amazon Prime Video',
    'peacock': 'Peacock',
    'paramountplus': 'Paramount+',
    'appletvplus': 'Apple TV+',
    'hbomax': 'HBO Max',
    'crunchyroll': 'Crunchyroll',
    'funimation': 'Funimation',
    'dazn': 'DAZN',
    'espnplus': 'ESPN+',
    'xboxlive': 'Xbox Live',
  };

  final normalizedId = id.toLowerCase().replaceAll('_', '').replaceAll('-', '');

  if (knownBrands.containsKey(id.toLowerCase())) {
    return knownBrands[id.toLowerCase()]!;
  }
  if (knownBrands.containsKey(normalizedId)) {
    return knownBrands[normalizedId]!;
  }

  // 2. Generic fallback cleaning
  String formatted = rawName.replaceAll('_', ' ').replaceAll('-', ' ');

  final words = formatted.split(' ').where((w) => w.isNotEmpty).map((word) {
    if (word.toLowerCase() == 'tv') {
      return 'TV';
    }
    return word[0].toUpperCase() + word.substring(1);
  });

  return words.join(' ');
}

class AdGuardHomeBlockedServices {
  final AdGuardHome _client;
  AdGuardHomeBlockedServices(this._client);

  /// Fetch all available services that can be blocked.
  Future<List<BlockedService>> getAvailableServices() async {
    if (_client.isDemo) {
      return _demoServices;
    }
    final response = await _client.restClient.blockedServices
        .blockedServicesAll();
    return response.blockedServices.map(_fromApi).toList(growable: false);
  }

  /// Fetch the list of currently blocked service IDs.
  Future<List<String>> getBlockedServices() async {
    if (_client.isDemo) {
      return _client.demoBlockedServiceIds;
    }
    final response = await _client.restClient.blockedServices
        .blockedServicesSchedule();
    return response.ids ?? [];
  }

  Future<BlockedServicesSchedule> getSchedule() async {
    if (_client.isDemo) {
      return BlockedServicesSchedule(
        ids: List<String>.from(_client.demoBlockedServiceIds),
        schedule: _client.demoBlockedServicesSchedule,
      );
    }
    return _client.restClient.blockedServices.blockedServicesSchedule();
  }

  /// Update the list of currently blocked service IDs.
  Future<void> updateBlockedServices(List<String> serviceIds) async {
    if (_client.isDemo) {
      _client.demoBlockedServiceIds = List<String>.from(serviceIds);
      return;
    }
    final current = await _client.restClient.blockedServices
        .blockedServicesSchedule();
    await _client.restClient.blockedServices.blockedServicesScheduleUpdate(
      body: BlockedServicesSchedule(
        schedule: current.schedule,
        ids: serviceIds,
      ),
    );
  }

  Future<void> updateSchedule(Schedule schedule) async {
    if (_client.isDemo) {
      _client.demoBlockedServicesSchedule = schedule;
      return;
    }
    final current = await getSchedule();
    await _client.restClient.blockedServices.blockedServicesScheduleUpdate(
      body: BlockedServicesSchedule(schedule: schedule, ids: current.ids),
    );
  }

  BlockedService _fromApi(api.BlockedService service) => BlockedService(
    id: service.id,
    name: _formatServiceName(service.name, service.id),
    groupId: service.groupId,
    iconSvg: service.iconSvg,
  );

  static final List<BlockedService> _demoServices = [
    BlockedService(id: 'youtube', name: 'YouTube'),
    BlockedService(id: 'tiktok', name: 'TikTok'),
    BlockedService(id: 'facebook', name: 'Facebook'),
    BlockedService(id: 'instagram', name: 'Instagram'),
    BlockedService(id: 'twitter', name: 'Twitter / X'),
    BlockedService(id: 'discord', name: 'Discord'),
    BlockedService(id: 'steam', name: 'Steam'),
    BlockedService(id: 'roblox', name: 'Roblox'),
    BlockedService(id: 'telegram', name: 'Telegram'),
    BlockedService(id: 'netflix', name: 'Netflix'),
    BlockedService(id: 'reddit', name: 'Reddit'),
    BlockedService(id: 'twitch', name: 'Twitch'),
  ];
}

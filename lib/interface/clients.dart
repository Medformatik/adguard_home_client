import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/generated_api/export.dart';

class AdGuardHomeClients {
  final AdGuardHome _client;

  AdGuardHomeClients(this._client);

  /// Fetch all configured clients
  Future<Clients> getClients() async {
    if (_client.isDemo) {
      return _demoClientsData;
    }
    return _client.restClient.clients.clientsStatus();
  }

  /// Add a client
  Future<void> addClient(Client newClient) async {
    if (_client.isDemo) {
      _demoClientsData.clients!.add(newClient);
      return;
    }
    await _client.restClient.clients.clientsAdd(body: newClient);
  }

  /// Update a client configuration
  Future<void> updateClient(String originalName, Client updatedClient) async {
    if (_client.isDemo) {
      final idx = _demoClientsData.clients!.indexWhere(
        (c) => c.name == originalName,
      );
      if (idx != -1) {
        _demoClientsData.clients![idx] = updatedClient;
      }
      return;
    }
    await _client.restClient.clients.clientsUpdate(
      body: ClientUpdate(name: originalName, data: updatedClient),
    );
  }

  /// Delete a client
  Future<void> deleteClient(String name) async {
    if (_client.isDemo) {
      _demoClientsData.clients!.removeWhere((c) => c.name == name);
      return;
    }
    await _client.restClient.clients.clientsDelete(
      body: ClientDelete(name: name),
    );
  }

  static final Clients _demoClientsData = Clients(
    clients: [
      const Client(
        name: 'Kids iPad',
        ids: ['192.168.1.15'],
        useGlobalSettings: false,
        filteringEnabled: true,
        parentalEnabled: true,
        safebrowsingEnabled: true,
        useGlobalBlockedServices: false,
        blockedServices: ['tiktok', 'instagram'],
      ),
      const Client(
        name: 'Work Laptop',
        ids: ['192.168.1.20', 'work-laptop.local'],
        useGlobalSettings: true,
        filteringEnabled: true,
        parentalEnabled: false,
        safebrowsingEnabled: true,
        useGlobalBlockedServices: true,
      ),
      const Client(
        name: 'Smart TV',
        ids: ['192.168.1.55', 'AA:BB:CC:DD:EE:FF'],
        useGlobalSettings: true,
        filteringEnabled: false,
        parentalEnabled: false,
        safebrowsingEnabled: false,
        useGlobalBlockedServices: true,
      ),
    ],
    autoClients: [],
    supportedTags: ['user', 'family', 'device'],
  );
}

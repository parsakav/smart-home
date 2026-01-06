import 'package:flutter/material.dart';
import 'package:smart_home/services/api_service.dart';
// ... تمام importها بدون تغییر بماند ...

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  Map<String, dynamic> _status = {};
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final status = await ApiService.getStatus();
      setState(() {
        _status = _convertToMap(status);
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _status = {};
        _isLoading = false;
        _isRefreshing = false;
      });
      _showErrorSnackbar('Failed to load status: $e');
    }
  }

  Map<String, dynamic> _convertToMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _toggleMode(String modeKey) async {
    try {
      final currentValue = _status['status']?[modeKey] ?? false;
      await ApiService.sendConfig({modeKey: !currentValue});
      await _fetchStatus();
    } catch (e) {
      _showErrorSnackbar('Failed to toggle $modeKey: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final status = _convertToMap(_status['status']);
    final sensors = _convertToMap(_status['sensors']);
    final lights = _convertToMap(status['lights']);
    final fans = _convertToMap(status['fans']);

    final bool isAutoMode = status['auto_mode'] ?? false;
    final bool isPartyMode = status['party_mode'] ?? false;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSystemStatus(status, sensors),
            const SizedBox(height: 20),
            _buildLightsControl(lights, isAutoMode || isPartyMode),
            const SizedBox(height: 20),
            _buildFansControl(fans, isAutoMode),
            const SizedBox(height: 20),
            _buildSecurityControls(status, isAutoMode),
            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus(Map<String, dynamic> status, Map<String, dynamic> sensors) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Auto Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Switch(
                  value: status['auto_mode'] ?? false,
                  onChanged: (_) => _toggleMode('auto_mode'),
                ),
              ],
            ),
            // Party Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Party Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Switch(
                  value: status['party_mode'] ?? false,
                  onChanged: (_) => _toggleMode('party_mode'),
                ),
              ],
            ),
            const Divider(),
            _buildStatusRow('Time', _status['time']?.toString() ?? '--:--:--'),
            _buildStatusRow('Date', _status['date']?.toString() ?? '----/--/--'),
            _buildStatusRow('Temperature', '${sensors['temperature']?.toString() ?? '--'}°C'),
            _buildStatusRow('Humidity', '${sensors['humidity']?.toString() ?? '--'}%'),
            _buildStatusRow('Light Level', '${sensors['light_lux']?.toString() ?? '--'} lux'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildLightsControl(Map<String, dynamic> lights, bool isDisabled) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lights Control', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildLightControl('Main Room', lights['main_room']?.toString() ?? 'OFF', (v) => _updateLight('main_room', v), isDisabled),
            _buildLightControl('Room 1', lights['room_1']?.toString() ?? 'OFF', (v) => _updateLight('room_1', v), isDisabled),
            _buildLightControl('Room 2', lights['room_2']?.toString() ?? 'OFF', (v) => _updateLight('room_2', v), isDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildLightControl(String title, String currentMode, Function(String) onChanged, bool isDisabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          DropdownButton<String>(
            value: currentMode,
            items: const [
              DropdownMenuItem(value: 'ON', child: Text('ON')),
              DropdownMenuItem(value: 'OFF', child: Text('OFF')),
              DropdownMenuItem(value: 'SLEEP', child: Text('SLEEP')),
            ],
            onChanged: isDisabled ? null : (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFansControl(Map<String, dynamic> fans, bool isDisabled) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fans Control', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildFanSwitch('Main Fan', fans['main_fan'] ?? false, (v) => _updateFan('main_fan', v), isDisabled),
            _buildFanSwitch('Room 1 Fan', fans['room_1_fan'] ?? false, (v) => _updateFan('room_1_fan', v), isDisabled),
            _buildFanSwitch('Room 2 Fan', fans['room_2_fan'] ?? false, (v) => _updateFan('room_2_fan', v), isDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildFanSwitch(String title, bool isActive, Function(bool) onChanged, bool isDisabled) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: isActive,
      onChanged: isDisabled ? null : onChanged,
    );
  }

  Widget _buildSecurityControls(Map<String, dynamic> status, bool isDisabled) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Security Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildSecuritySwitch('Child Lock', status['child_lock'] ?? false, (v) => _updateSecurity('child_lock', v), isDisabled),
            _buildSecuritySwitch('Child Protect', status['child_protect'] ?? false, (v) => _updateSecurity('child_protect', v), isDisabled),
            _buildSecuritySwitch('Door', status['door_is_open'] ?? false, (v) => _updateSecurity('door_is_open', v), isDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySwitch(String title, bool isActive, Function(bool) onChanged, bool isDisabled) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: isActive,
      onChanged: isDisabled ? null : onChanged,
    );
  }

  Future<void> _updateLight(String lightName, String value) async {
    try {
      await ApiService.sendConfig({'lights': {lightName: value}});
      await _fetchStatus();
    } catch (e) {
      _showErrorSnackbar('Failed to update light: $e');
    }
  }

  Future<void> _updateFan(String fanName, bool value) async {
    try {
      await ApiService.sendConfig({'fans': {fanName: value}});
      await _fetchStatus();
    } catch (e) {
      _showErrorSnackbar('Failed to update fan: $e');
    }
  }

  Future<void> _updateSecurity(String setting, bool value) async {
    try {
      await ApiService.sendConfig({setting: value});
      await _fetchStatus();
    } catch (e) {
      _showErrorSnackbar('Failed to update security: $e');
    }
  }
}

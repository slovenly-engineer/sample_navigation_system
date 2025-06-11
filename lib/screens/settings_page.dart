import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_data.dart';
import '../services/navigation_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final SettingsData? initialData;
  final SettingsTab? initialTab;

  const SettingsPage({super.key, this.initialData, this.initialTab});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late SettingsData _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialData ?? const SettingsData();
  }

  @override
  Widget build(BuildContext context) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final confirmed = await nav.showDialogWidget<bool>(
                dialog: AlertDialog(
                  title: const Text('設定の保存'),
                  content: const Text('現在の設定を保存しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                nav.showSnackBar(
                  message: '設定を保存しました',
                );
                nav.pop(_settings);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.initialData != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'extraデータを受け取りました',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ダークモード: ${widget.initialData!.darkMode}\n'
                      '言語: ${widget.initialData!.language}\n'
                      '通知: ${widget.initialData!.notificationsEnabled}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '一般設定',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('ダークモード'),
                    subtitle: const Text('アプリのテーマをダークモードに切り替えます'),
                    value: _settings.darkMode,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(darkMode: value);
                      });
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('言語'),
                    subtitle: Text(_getLanguageName(_settings.language)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final selected = await _showLanguageDialog();
                      if (selected != null) {
                        setState(() {
                          _settings = _settings.copyWith(language: selected);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '通知設定',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('通知を有効にする'),
                    subtitle: const Text('アプリからの通知を受け取ります'),
                    value: _settings.notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(notificationsEnabled: value);
                      });
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: _settings.notificationsEnabled,
                    title: const Text('通知音'),
                    subtitle: const Text('デフォルト'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _settings.notificationsEnabled
                        ? () {
                            nav.showSnackBar(
                              message: '通知音の設定',
                            );
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: _settings.notificationsEnabled,
                    title: const Text('バイブレーション'),
                    subtitle: const Text('有効'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _settings.notificationsEnabled
                        ? () {
                            nav.showSnackBar(
                              message: 'バイブレーションの設定',
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await nav.showDialogWidget<bool>(
                        dialog: AlertDialog(
                          title: const Text('リセット確認'),
                          content: const Text('すべての設定をデフォルトに戻しますか？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('リセット'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true) {
                        setState(() {
                          _settings = const SettingsData();
                        });
                        nav.showSnackBar(
                          message: '設定をリセットしました',
                        );
                      }
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('設定をリセット'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      nav.showDialogWidget(
                        dialog: AlertDialog(
                          title: const Text('現在の設定'),
                          content: Text(
                            'ダークモード: ${_settings.darkMode}\n'
                            '言語: ${_getLanguageName(_settings.language)}\n'
                            '通知: ${_settings.notificationsEnabled ? "有効" : "無効"}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('現在の設定を確認'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ja':
        return '日本語';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      default:
        return code;
    }
  }

  Future<String?> _showLanguageDialog() async {
    final nav = ref.read(navigationServiceProvider);
    
    return await nav.showDialogWidget<String>(
      dialog: AlertDialog(
        title: const Text('言語を選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('日本語'),
              value: 'ja',
              groupValue: _settings.language,
              onChanged: (value) => nav.pop(value),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _settings.language,
              onChanged: (value) => nav.pop(value),
            ),
            RadioListTile<String>(
              title: const Text('中文'),
              value: 'zh',
              groupValue: _settings.language,
              onChanged: (value) => nav.pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
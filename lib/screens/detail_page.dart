import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/router_provider.dart';

class DetailPage extends ConsumerStatefulWidget {
  final String id;
  final String? initialTab;

  const DetailPage({
    super.key,
    required this.id,
    this.initialTab,
  });

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab == 'comments' ? 1 : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('詳細 #${widget.id}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '情報', icon: Icon(Icons.info)),
            Tab(text: 'コメント', icon: Icon(Icons.comment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 情報タブ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'アイテム #${widget.id}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'これは詳細画面のサンプルです。\nパラメータとクエリパラメータを受け取ることができます。',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'パラメータ情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow('ID', widget.id),
                        const Divider(),
                        _buildInfoRow('初期タブ', widget.initialTab ?? 'なし'),
                        const Divider(),
                        _buildInfoRow('タイムスタンプ', DateTime.now().toIso8601String()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final action = await nav.showBottomSheet<String>(
                          sheet: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'アクションを選択',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.share),
                                  title: const Text('共有'),
                                  onTap: () => nav.pop('share'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.favorite),
                                  title: const Text('お気に入り'),
                                  onTap: () => nav.pop('favorite'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.download),
                                  title: const Text('ダウンロード'),
                                  onTap: () => nav.pop('download'),
                                ),
                              ],
                            ),
                          ),
                        );
                        
                        if (action != null) {
                          await nav.showSnackBar(
                            message: '$actionを実行しました',
                          );
                        }
                      },
                      icon: const Icon(Icons.more_horiz),
                      label: const Text('アクション'),
                    ),
                    
                    ElevatedButton.icon(
                      onPressed: () {
                        nav.pop('詳細画面からの戻り値');
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('完了'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // コメントタブ
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text('コメント ${index + 1}'),
                  subtitle: Text('これはサンプルコメントです。ID: ${widget.id}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.reply),
                    onPressed: () {
                      nav.showSnackBar(
                        message: 'コメント ${index + 1}に返信',
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await nav.showDialogWidget<bool>(
            dialog: AlertDialog(
              title: const Text('確認'),
              content: const Text('この画面を閉じますか？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          );
          
          if (result == true) {
            nav.pop();
          }
        },
        child: const Icon(Icons.close),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
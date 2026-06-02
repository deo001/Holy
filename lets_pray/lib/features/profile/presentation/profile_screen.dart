import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Faithful Servant';
  List<Map<String, dynamic>> _annotations = [];
  bool _isLoading = true;
  bool _hapticsEnabled = true;
  bool _dailyReflectionsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAnnotations();
  }

  Future<void> _loadAnnotations() async {
    final list = await DatabaseHelper.instance.getAnnotations();
    setState(() {
      _annotations = list;
      _isLoading = false;
    });
  }

  Future<void> _deleteAnnotation(int id) async {
    await DatabaseHelper.instance.deleteAnnotation(id);
    HapticFeedback.lightImpact();
    _loadAnnotations();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Highlight cleared')),
      );
    }
  }

  void _editName() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('Update Profile Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter name',
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.surfaceLightDark)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.liturgicalGold)),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.liturgicalGold,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _userName = controller.text.trim();
                  });
                  HapticFeedback.lightImpact();
                }
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY PRAYER SPACE'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.liturgicalGold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppTheme.liturgicalGold.withOpacity(0.1),
                          child: const Icon(
                            Icons.account_circle,
                            size: 80,
                            color: AppTheme.liturgicalGold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _userName,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: AppTheme.liturgicalGold),
                              onPressed: _editName,
                            ),
                          ],
                        ),
                        const Text(
                          'Local Device Account',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. Settings Section
                  Text(
                    'APP CONFIGURATION',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceLightDark),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Tactile Haptic Feedback'),
                          subtitle: const Text('Vibrate as you advance Rosary beads'),
                          value: _hapticsEnabled,
                          activeColor: AppTheme.liturgicalGold,
                          onChanged: (val) {
                            setState(() {
                              _hapticsEnabled = val;
                            });
                          },
                        ),
                        const Divider(height: 1, color: AppTheme.surfaceLightDark),
                        SwitchListTile(
                          title: const Text('Daily Gospel Reflections'),
                          subtitle: const Text('Receive quiet daily prayer alerts'),
                          value: _dailyReflectionsEnabled,
                          activeColor: AppTheme.liturgicalGold,
                          onChanged: (val) {
                            setState(() {
                              _dailyReflectionsEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. User Bible Highlights Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SAVED BIBLE VERSES (${_annotations.length})',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18, color: AppTheme.textSecondary),
                        onPressed: _loadAnnotations,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _annotations.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.surfaceLightDark),
                          ),
                          child: const Center(
                            child: Text(
                              'Long-press a verse in the Bible tab to highlight and save it here.',
                              style: TextStyle(color: AppTheme.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _annotations.length,
                          itemBuilder: (context, index) {
                            final annotation = _annotations[index];
                            final int id = annotation['id'] as int;
                            final String book = annotation['book_name'] as String;
                            final int ch = annotation['chapter'] as int;
                            final int vs = annotation['verse'] as int;
                            final String text = annotation['verse_text'] as String;
                            final String? colorHex = annotation['highlight_color'] as String?;

                            Color highlightColor = AppTheme.liturgicalGold;
                            if (colorHex == '#FF6495ED') highlightColor = Colors.blue;
                            if (colorHex == '#FFFF6B6B') highlightColor = Colors.redAccent;
                            if (colorHex == '#FF4CAF50') highlightColor = Colors.green;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: highlightColor.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: highlightColor.withOpacity(0.2)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(
                                  '"$text"',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Lora',
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    '$book $ch:$vs',
                                    style: const TextStyle(
                                      color: AppTheme.liturgicalGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.textMuted),
                                  onPressed: () => _deleteAnnotation(id),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 24),
                  
                  // 4. Privacy Footer
                  Center(
                    child: Text(
                      'All scripture notes and intentions are saved directly on this local device. Your prayer intentions are private to you.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _intentions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIntentions();
  }

  Future<void> _loadIntentions() async {
    final list = await DatabaseHelper.instance.getIntentions();
    setState(() {
      _intentions = list;
      _isLoading = false;
    });
  }

  Future<void> _toggleAnswered(int id, int currentVal, String title) async {
    final nextVal = currentVal == 0 ? 1 : 0;
    await DatabaseHelper.instance.updateIntention(id, {'is_answered': nextVal});
    HapticFeedback.mediumImpact();
    _loadIntentions();

    if (nextVal == 1 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Praise God! "$title" marked as answered.'),
          backgroundColor: AppTheme.liturgicalGreen,
        ),
      );
    }
  }

  Future<void> _deleteIntention(int id) async {
    await DatabaseHelper.instance.deleteIntention(id);
    // Also cancel notification matching the DB id
    await NotificationService.instance.cancelNotification(id);
    HapticFeedback.lightImpact();
    _loadIntentions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intention deleted')),
      );
    }
  }

  void _showAddIntentionDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              title: Text(
                'Add Prayer Intention',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'What are you praying for?',
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.surfaceLightDark)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.liturgicalGold)),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Details (Optional)',
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.surfaceLightDark)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.liturgicalGold)),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  
                  // Reminder scheduler row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTime == null
                            ? 'Set daily reminder?'
                            : 'Reminder: ${selectedTime!.format(context)}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.alarm, color: AppTheme.liturgicalGold),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
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
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    String? reminderString;
                    if (selectedTime != null) {
                      reminderString = '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                    }

                    // Save to database
                    final dbId = await DatabaseHelper.instance.addIntention(
                      title,
                      descController.text.trim().isEmpty ? null : descController.text.trim(),
                      reminderString,
                    );

                    // If reminder selected, schedule local notification with database ID
                    if (selectedTime != null) {
                      await NotificationService.instance.requestPermissions();
                      await NotificationService.instance.scheduleDailyNotification(
                        id: dbId,
                        title: 'Daily Prayer Intention Reminder',
                        body: 'Remember to pray for: $title',
                        hour: selectedTime!.hour,
                        minute: selectedTime!.minute,
                      );
                    }

                    HapticFeedback.heavyImpact();
                    if (mounted) {
                      Navigator.pop(context);
                      _loadIntentions();
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRAYER JOURNAL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_off, color: AppTheme.textSecondary),
            onPressed: () async {
              await NotificationService.instance.cancelAllNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All reminders disabled')),
                );
              }
            },
            tooltip: 'Disable all reminders',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.liturgicalGold))
          : _intentions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border, size: 64, color: AppTheme.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          'Your prayer journal is empty.',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add intentions you want to offer in prayer. You can schedule daily local alerts to help build your discipline.',
                          style: TextStyle(color: AppTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _intentions.length,
                  itemBuilder: (context, index) {
                    final item = _intentions[index];
                    final int id = item['id'] as int;
                    final String title = item['title'] as String;
                    final String? desc = item['description'] as String?;
                    final int isAnswered = item['is_answered'] as int;
                    final String? reminder = item['reminder_time'] as String?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isAnswered == 1
                          ? AppTheme.liturgicalGreen.withOpacity(0.08)
                          : AppTheme.surfaceDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isAnswered == 1
                              ? AppTheme.liturgicalGreen.withOpacity(0.3)
                              : AppTheme.surfaceLightDark,
                          width: 1.0,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: IconButton(
                          icon: Icon(
                            isAnswered == 1 ? Icons.check_circle : Icons.favorite_border,
                            color: isAnswered == 1 ? AppTheme.liturgicalGreen : AppTheme.textMuted,
                            size: 28,
                          ),
                          onPressed: () => _toggleAnswered(id, isAnswered, title),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            color: isAnswered == 1 ? AppTheme.textSecondary : AppTheme.textPrimary,
                            decoration: isAnswered == 1 ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (desc != null && desc.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                desc,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ],
                            if (reminder != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.alarm, color: AppTheme.liturgicalGold, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Daily at $reminder',
                                    style: const TextStyle(color: AppTheme.liturgicalGold, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.textMuted),
                          onPressed: () => _deleteIntention(id),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.liturgicalGold,
        foregroundColor: Colors.black,
        onPressed: _showAddIntentionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

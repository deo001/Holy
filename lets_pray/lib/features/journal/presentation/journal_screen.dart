import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  List<Map<String, dynamic>> _intentions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIntentions();
  }

  Future<void> _loadIntentions() async {
    try {
      final list = await DatabaseHelper.instance.getIntentions();
      if (mounted) {
        setState(() {
          _intentions = list;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _intentions = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleAnswered(int id, int currentVal, String title) async {
    final nextVal = currentVal == 0 ? 1 : 0;
    await DatabaseHelper.instance.updateIntention(id, {'is_answered': nextVal});
    HapticFeedback.mediumImpact();
    _loadIntentions();

    if (nextVal == 1 && mounted) {
      final locale = ref.read(localeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locale == 'sw'
                ? 'Mshukuru Mungu! "$title" imewekwa alama kama imejibiwa.'
                : 'Praise God! "$title" marked as answered.',
          ),
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
      final locale = ref.read(localeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale == 'sw' ? 'Nia imefutwa' : 'Intention deleted'),
        ),
      );
    }
  }

  void _showEditIntentionDialog(Map<String, dynamic> item) {
    final int id = item['id'] as int;
    final titleController = TextEditingController(
      text: item['title'] as String? ?? '',
    );
    final descController = TextEditingController(
      text: item['description'] as String? ?? '',
    );
    final String? reminder = item['reminder_time'] as String?;
    TimeOfDay? selectedTime;
    final locale = ref.read(localeProvider);

    if (reminder != null && reminder.contains(':')) {
      final parts = reminder.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              title: Text(
                locale == 'sw' ? 'Hariri Nia ya Sala' : 'Edit Prayer Intention',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: locale == 'sw'
                          ? 'Je, unazisalia nini?'
                          : 'What are you praying for?',
                      labelStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.surfaceLightDark,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.liturgicalGold),
                      ),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: locale == 'sw'
                          ? 'Maelezo / Nyongeza (Hiari)'
                          : 'Notes / Details (Optional)',
                      labelStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.surfaceLightDark,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.liturgicalGold),
                      ),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTime == null
                            ? (locale == 'sw'
                                  ? 'Hakuna kikumbusho'
                                  : 'No reminder')
                            : '${locale == 'sw' ? 'Kikumbusho' : 'Reminder'}: ${selectedTime!.format(context)}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.alarm,
                              color: AppTheme.liturgicalGold,
                            ),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedTime = picked;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.alarm_off,
                              color: AppTheme.textMuted,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                selectedTime = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    locale == 'sw' ? 'GHAIRI' : 'CANCEL',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.liturgicalGold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final reminderString = selectedTime == null
                        ? null
                        : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

                    await DatabaseHelper.instance.updateIntention(id, {
                      'title': title,
                      'description': descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                      'reminder_time': reminderString,
                    });

                    if (selectedTime != null) {
                      await NotificationService.instance.requestPermissions();
                      await NotificationService.instance
                          .scheduleDailyNotification(
                            id: id,
                            title: locale == 'sw'
                                ? 'Kikumbusho cha Nia ya Sala'
                                : 'Daily Prayer Intention Reminder',
                            body: locale == 'sw'
                                ? 'Kumbuka kusali kwa ajili ya: $title'
                                : 'Remember to pray for: $title',
                            hour: selectedTime!.hour,
                            minute: selectedTime!.minute,
                          );
                    } else {
                      await NotificationService.instance.cancelNotification(id);
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      _loadIntentions();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            locale == 'sw'
                                ? 'Nia imehaririwa'
                                : 'Intention updated',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(locale == 'sw' ? 'HIFADHI' : 'SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddIntentionDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay? selectedTime;
    final locale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              title: Text(
                locale == 'sw' ? 'Weka Nia ya Sala' : 'Add Prayer Intention',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: locale == 'sw'
                          ? 'Je, unazisalia nini?'
                          : 'What are you praying for?',
                      labelStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.surfaceLightDark,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.liturgicalGold),
                      ),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: locale == 'sw'
                          ? 'Maelezo / Nyongeza (Hiari)'
                          : 'Notes / Details (Optional)',
                      labelStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.surfaceLightDark,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.liturgicalGold),
                      ),
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
                            ? (locale == 'sw'
                                  ? 'Weka kikumbusho?'
                                  : 'Set daily reminder?')
                            : '${locale == 'sw' ? 'Kikumbusho' : 'Reminder'}: ${selectedTime!.format(context)}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.alarm,
                          color: AppTheme.liturgicalGold,
                        ),
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
                  child: Text(
                    locale == 'sw' ? 'GHAIRI' : 'CANCEL',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
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
                      reminderString =
                          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                    }

                    // Save to database
                    final dbId = await DatabaseHelper.instance.addIntention(
                      title,
                      descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                      reminderString,
                    );

                    // If reminder selected, schedule local notification with database ID
                    if (selectedTime != null) {
                      await NotificationService.instance.requestPermissions();
                      await NotificationService.instance
                          .scheduleDailyNotification(
                            id: dbId,
                            title: locale == 'sw'
                                ? 'Kikumbusho cha Nia ya Sala'
                                : 'Daily Prayer Intention Reminder',
                            body: locale == 'sw'
                                ? 'Kumbuka kusali kwa ajili ya: $title'
                                : 'Remember to pray for: $title',
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
                  child: Text(locale == 'sw' ? 'HIFADHI' : 'SAVE'),
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
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(ref, 'journal_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_off, color: AppTheme.textSecondary),
            onPressed: () async {
              await NotificationService.instance.cancelAllNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      locale == 'sw'
                          ? 'Vikumbusho vyote vimezimwa'
                          : 'All reminders disabled',
                    ),
                  ),
                );
              }
            },
            tooltip: locale == 'sw'
                ? 'Zima vikumbusho vyote'
                : 'Disable all reminders',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.liturgicalGold),
            )
          : _intentions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      locale == 'sw'
                          ? 'Shajara yako ya sala haina kitu.'
                          : 'Your prayer journal is empty.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locale == 'sw'
                          ? 'Weka nia unazotaka kuomba. Unaweza kupanga vikumbusho vya kila siku ili kukusaidia kujenga nidhamu.'
                          : 'Add intentions you want to offer in prayer. You can schedule daily local alerts to help build your discipline.',
                      style: const TextStyle(color: AppTheme.textMuted),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () => _showEditIntentionDialog(item),
                    leading: IconButton(
                      icon: Icon(
                        isAnswered == 1
                            ? Icons.check_circle
                            : Icons.favorite_border,
                        color: isAnswered == 1
                            ? AppTheme.liturgicalGreen
                            : AppTheme.textMuted,
                        size: 28,
                      ),
                      onPressed: () => _toggleAnswered(id, isAnswered, title),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        color: isAnswered == 1
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        decoration: isAnswered == 1
                            ? TextDecoration.lineThrough
                            : null,
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
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (reminder != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.alarm,
                                color: AppTheme.liturgicalGold,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                locale == 'sw'
                                    ? 'Kila siku saa $reminder'
                                    : 'Daily at $reminder',
                                style: const TextStyle(
                                  color: AppTheme.liturgicalGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.textMuted,
                      ),
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

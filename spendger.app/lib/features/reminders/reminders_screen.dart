import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  void _showAddReminderDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
    String reminderType = 'custom';
    String repeatFrequency = 'monthly';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setState) => AlertDialog(
          title: const Text('Add Payment Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(6),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Reminder Title',
                    hintText: 'e.g. Credit Card Bill, House Rent, SIP Due',
                    prefixIcon: Icon(Icons.alarm),
                  ),
                ),
                const Gap(10),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (Optional ₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
                const Gap(10),
                DropdownButtonFormField<String>(
                  initialValue: repeatFrequency,
                  decoration: const InputDecoration(labelText: 'Repeat Schedule'),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('One-time Only')),
                    DropdownMenuItem(value: 'monthly', child: Text('Every Month')),
                    DropdownMenuItem(value: 'weekly', child: Text('Every Week')),
                    DropdownMenuItem(value: 'yearly', child: Text('Every Year')),
                  ],
                  onChanged: (val) => setState(() => repeatFrequency = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                final amount = double.tryParse(amountController.text.trim());

                final db = ref.read(databaseProvider);
                const uuid = Uuid();

                await db.into(db.reminders).insert(
                  RemindersCompanion.insert(
                    id: uuid.v4(),
                    title: title,
                    reminderType: reminderType,
                    dueDate: selectedDate,
                    repeatFrequency: drift.Value(repeatFrequency),
                    amount: drift.Value(amount),
                    notificationId: DateTime.now().millisecondsSinceEpoch % 100000,
                  ),
                );

                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment reminder saved!')),
                  );
                }
              },
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersStreamProvider);
    final reminders = remindersAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders & Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLight, size: 28),
            onPressed: () => _showAddReminderDialog(context, ref),
          ),
        ],
      ),
      body: reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off_outlined, size: 54, color: Colors.grey.withValues(alpha: 0.4)),
                  const Gap(12),
                  const Text('No active reminders', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const Gap(8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    onPressed: () => _showAddReminderDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Reminder'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final rem = reminders[index];
                return Dismissible(
                  key: Key(rem.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.expense,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(databaseProvider).delete(ref.read(databaseProvider).reminders).delete(rem);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: const Icon(Icons.alarm, color: AppColors.primaryLight),
                      ),
                      title: Text(rem.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Due: ${DateFormat('MMM dd, yyyy').format(rem.dueDate)} • ${rem.repeatFrequency.toUpperCase()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: rem.amount != null
                          ? Text(
                              CurrencyFormatter.format(rem.amount!),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_reminders',
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddReminderDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

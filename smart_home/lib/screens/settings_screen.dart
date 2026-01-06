// lib/screens/settings_screen.dart (نسخه کامل و اصلاح شده)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_home/services/api_service.dart';
import 'package:smart_home/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _setDateTime() async {
    setState(() => _isLoading = true);
    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      await ApiService.setTime(dateTime);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rebootSystem() async {
    // نمایش یک دیالوگ برای تایید گرفتن از کاربر
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reboot'),
        content: const Text('Are you sure you want to reboot the system?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reboot'),
          ),
        ],
      ),
    );

    if (confirm != true) return; // اگر کاربر تایید نکرد، خارج شو

    setState(() => _isLoading = true);
    try {
      await ApiService.reboot();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System reboot initiated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // خواندن ThemeProvider برای دسترسی به وضعیت تم
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: FadeInUp( // انیمیشن برای کل صفحه
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت جدید برای مدیریت تم
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    themeProvider.isDarkMode ? Iconsax.moon5 : Iconsax.sun_15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text('Dark Mode', style: textTheme.titleMedium),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      // تغییر تم با استفاده از Provider
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme(value);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // کارت تنظیمات تاریخ و زمان
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Date & Time', style: textTheme.titleLarge),
                    const Divider(),
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text(
                          '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                      trailing: const Icon(Iconsax.calendar_1), // آیکون جدید
                      onTap: () => _selectDate(context),
                    ),
                    ListTile(
                      title: const Text('Time'),
                      subtitle: Text('${_selectedTime.hour}:${_selectedTime.minute}'),
                      trailing: const Icon(Iconsax.clock), // آیکون جدید
                      onTap: () => _selectTime(context),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Iconsax.send_1),
                        onPressed: _isLoading ? null : _setDateTime,
                        label: _isLoading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : const Text('Set Date & Time'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // کارت اقدامات سیستمی
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System Actions', style: textTheme.titleLarge),
                    const Divider(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Iconsax.refresh),
                        onPressed: _isLoading ? null : _rebootSystem,
                        // استفاده از رنگ خطای تم برای هماهنگی
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                        ),
                        label: _isLoading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : const Text('Reboot System'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Screen background wrapper (mirrors <Screen>).
class ShopScreen extends StatelessWidget {
  final Widget child;
  const ShopScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.background, child: SafeArea(child: child));
  }
}

/// Page header with title/subtitle and an optional trailing action
/// (mirrors <Header>). Laid out RTL: title on the right, action on the left.
class ShopHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  const ShopHeader({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 24, height: 1.3, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Small circular icon button (mirrors <IconButton>).
enum IconTone { light, green, danger }

class ShopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final IconTone tone;
  const ShopIconButton({super.key, required this.icon, required this.onPressed, this.label, this.tone = IconTone.light});

  @override
  Widget build(BuildContext context) {
    final bg = tone == IconTone.green
        ? AppColors.primary
        : tone == IconTone.danger
            ? const Color(0xFFFFF0EF)
            : AppColors.secondary;
    final fg = tone == IconTone.green
        ? AppColors.primaryForeground
        : tone == IconTone.danger
            ? AppColors.destructive
            : AppColors.primary;
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 18, color: fg)),
        ),
      ),
    );
  }
}

/// Full-width filled action button (mirrors <PrimaryButton>).
class ShopPrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final IconData? icon;
  const ShopPrimaryButton({super.key, required this.title, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.45),
          foregroundColor: AppColors.primaryForeground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

/// Section title row with optional trailing action (mirrors <SectionTitle>).
class ShopSectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;
  const ShopSectionTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

enum StatTone { green, dark, soft, amber }

/// Small metric card (mirrors <StatCard>).
class ShopStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final StatTone tone;
  const ShopStatCard({super.key, required this.label, required this.value, required this.icon, this.tone = StatTone.green});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    switch (tone) {
      case StatTone.dark:
        bg = AppColors.foreground;
        text = Colors.white;
        break;
      case StatTone.soft:
        bg = AppColors.softBg;
        text = AppColors.foreground;
        break;
      case StatTone.amber:
        bg = AppColors.amberBg;
        text = AppColors.foreground;
        break;
      case StatTone.green:
        bg = AppColors.primary;
        text = Colors.white;
        break;
    }
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD8D0BF))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(7)),
              child: Icon(icon, size: 17, color: text),
            ),
            const SizedBox(height: 7),
            Text(value, textAlign: TextAlign.right, style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 17)),
            Text(label, textAlign: TextAlign.right, style: TextStyle(color: text.withOpacity(0.82), fontWeight: FontWeight.w500, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

/// Labeled text field (mirrors <Field>).
class ShopField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final TextInputType keyboardType;
  final bool multiline;
  const ShopField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
          const SizedBox(height: 7),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: multiline ? 4 : 1,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 14, color: AppColors.foreground),
            decoration: InputDecoration(
              hintText: placeholder,
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(color: AppColors.mutedForeground),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.input)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.input)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tap-to-open picker field (mirrors <SelectField>).
class ShopSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final String placeholder;
  const ShopSelectField({super.key, required this.label, this.value, required this.onTap, this.placeholder = 'اختر من القائمة'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
          const SizedBox(height: 7),
          Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(border: Border.all(color: AppColors.input), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.mutedForeground),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        value ?? placeholder,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: value != null ? AppColors.foreground : AppColors.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickerItem {
  final String id;
  final String name;
  final double? quantity;
  const PickerItem({required this.id, required this.name, this.quantity});
}

/// Bottom-sheet product picker (mirrors <ProductPicker>).
Future<void> showProductPicker({
  required BuildContext context,
  required List<PickerItem> items,
  required String? selectedId,
  required ValueChanged<String> onSelect,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Expanded(
                    child: Text('اختر الصنف',
                        textAlign: TextAlign.right, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                  ),
                  ShopIconButton(icon: Icons.close, label: 'إغلاق', onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item.id == selectedId;
                    return Material(
                      color: selected ? AppColors.secondary : AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          onSelect(item.id);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.foreground)),
                              if (item.quantity != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('${_trimNum(item.quantity!)} متوفر',
                                      style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _trimNum(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();

/// Empty-state placeholder (mirrors <EmptyState>).
class ShopEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const ShopEmptyState({super.key, required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            margin: const EdgeInsets.only(bottom: 11),
            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.foreground)),
          const SizedBox(height: 5),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

/// Confirm-delete dialog (mirrors <ConfirmDeleteModal>).
Future<void> showConfirmDelete({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(bottom: 13),
            decoration: BoxDecoration(color: const Color(0xFFF8E8E5), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.delete_outline, size: 21, color: AppColors.destructive),
          ),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.foreground)),
          const SizedBox(height: 7),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.mutedForeground)),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.foreground, side: const BorderSide(color: AppColors.border)),
            child: const Text('إلغاء'),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive, foregroundColor: Colors.white),
            child: const Text('حذف'),
          ),
        ),
      ],
    ),
  );
}

/// Loading spinner (mirrors <LoadingState>).
class ShopLoadingState extends StatelessWidget {
  const ShopLoadingState({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}

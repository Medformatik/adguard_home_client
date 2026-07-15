import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';

class CustomRulesPage extends StatefulWidget {
  const CustomRulesPage({super.key});

  @override
  State<CustomRulesPage> createState() => _CustomRulesPageState();
}

class _CustomRulesPageState extends State<CustomRulesPage> {
  final _rulesController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rules = await dataSource!.getUserRules();
      if (!mounted) return;
      setState(() {
        _rulesController.text = rules.join('\n');
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });
    try {
      // Split by newlines, keep all non-empty formatted lines
      final rules = _rulesController.text
          .split('\n')
          .map((line) => line.trim())
          .toList();

      await dataSource!.setUserRules(rules);
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      showMessage(context, 'Custom rules saved successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      showMessage(context, 'Failed to save rules: $e', error: true);
    }
  }

  void _insertTemplate(String template) {
    final text = _rulesController.text;
    final selection = _rulesController.selection;

    String newText;
    int newCursorPosition;

    if (selection.start >= 0 && selection.end >= 0) {
      newText = text.replaceRange(selection.start, selection.end, template);
      newCursorPosition = selection.start + template.length;
    } else {
      // Append at the end if no active selection
      newText = text.isEmpty ? template : '$text\n$template';
      newCursorPosition = newText.length;
    }

    _rulesController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Rules'),
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load rules: $_error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  // Template insert chips
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8.0,
                        children: [
                          ActionChip(
                            label: const Text('+ Block Domain'),
                            onPressed: () => _insertTemplate('||domain.com^'),
                          ),
                          ActionChip(
                            label: const Text('+ Whitelist'),
                            onPressed: () => _insertTemplate('@@||domain.com^'),
                          ),
                          ActionChip(
                            label: const Text('+ Comment'),
                            onPressed: () => _insertTemplate('! Comment here'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Code area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: _rulesController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.4,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          hintText:
                              '# Write your custom rules here\n||badsite.com^\n@@||goodsite.com^',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

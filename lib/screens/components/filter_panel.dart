import 'package:flutter/material.dart';

/// Widget bộ lọc tối giản cho conversations
class FilterPanel extends StatefulWidget {
  final String? appNameFilter;
  final List<String>? flowTitleFilter;
  final Function(String? appName, List<String>? flowTitle) onFilterChanged;

  const FilterPanel({super.key, this.appNameFilter, this.flowTitleFilter, required this.onFilterChanged});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  bool _isExpanded = false;
  late TextEditingController _appNameController;

  // Dummy flow title options
  final List<String> _flowTitleOptions = ['theory', 'question'];

  final Set<String> _selectedFlowTitles = {};

  @override
  void initState() {
    super.initState();
    _appNameController = TextEditingController(text: widget.appNameFilter);

    // Parse initial selected flow titles if any
    if (widget.flowTitleFilter != null && widget.flowTitleFilter!.isNotEmpty) {
      _selectedFlowTitles.addAll(widget.flowTitleFilter!);
    }
  }

  @override
  void dispose() {
    _appNameController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final appName = _appNameController.text.trim().isEmpty ? null : _appNameController.text.trim();
    final flowTitle = _selectedFlowTitles.isEmpty ? null : _selectedFlowTitles.toList();
    widget.onFilterChanged(appName, flowTitle);
  }

  void _clearFilter() {
    setState(() {
      _appNameController.clear();
      _selectedFlowTitles.clear();
    });
    widget.onFilterChanged(null, null);
  }

  bool get _hasActiveFilters => (_appNameController.text.trim().isNotEmpty || _selectedFlowTitles.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - luôn hiển thị
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _hasActiveFilters ? const Color(0xFF3B82F6).withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.filter_list_rounded, size: 16, color: _hasActiveFilters ? const Color(0xFF3B82F6) : const Color(0xFF6B7280)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filter',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                    ),
                  ),
                  if (_hasActiveFilters)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(10)),
                      child: const Text(
                        'Active',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(_isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),

          // Nội dung filter - hiển thị khi expand
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Name Filter
                  _buildFilterField(label: 'App Name', controller: _appNameController, hintText: 'Enter app name...', icon: Icons.apps_rounded),
                  const SizedBox(height: 16),

                  // Flow Title Filter (Checkboxes)
                  _buildFlowTitleCheckboxes(),
                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilter,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilter,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: const Color(0xFF3B82F6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterField({required String label, required TextEditingController controller, required String hintText, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, size: 16, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlowTitleCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label_outline_rounded, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              'Flow Title',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _flowTitleOptions.map((option) {
              final isSelected = _selectedFlowTitles.contains(option);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFlowTitles.remove(option);
                    } else {
                      _selectedFlowTitles.add(option);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 16,
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

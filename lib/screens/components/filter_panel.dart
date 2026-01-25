import 'package:flutter/material.dart';

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
  final List<String> _flowTitleOptions = ['theory', 'question', 'initially_analyze_progress'];

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
        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD32F2F), width: 2.5),
        boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - luôn hiển thị
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: _hasActiveFilters ? const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]) : null,
                      color: _hasActiveFilters ? null : const Color(0xFFFFE082),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _hasActiveFilters ? const Color(0xFFFFC107) : const Color(0xFFD32F2F), width: 2),
                    ),
                    child: Text('🎯', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB71C1C),
                        shadows: [Shadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 4)],
                      ),
                    ),
                  ),
                  if (_hasActiveFilters)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFB300)]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
                      ),
                      child: const Text('✨', style: TextStyle(fontSize: 12)),
                    ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE082),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
                    ),
                    child: Icon(_isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18, color: const Color(0xFFD32F2F)),
                  ),
                ],
              ),
            ),
          ),

          // Nội dung filter - hiển thị khi expand
          if (_isExpanded) ...[
            Container(
              height: 2,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFFC107), Color(0xFFD32F2F)])),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Name Filter
                  _buildFilterField(label: 'App Name', controller: _appNameController, hintText: 'Enter app name...', icon: Icons.apps_rounded),
                  const SizedBox(height: 16),

                  // Flow Title Filter (Checkboxes)
                  _buildFlowTitleCheckboxes(),
                  const SizedBox(height: 14),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilter,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Color(0xFFD32F2F), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Clear Filter',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFC107), width: 2),
                            boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: ElevatedButton(
                            onPressed: _applyFilter,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Áp dụng',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
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
        Row(
          children: [
            Text('🏷️', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFFB71C1C)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D4037)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 12, color: const Color(0xFFD32F2F).withValues(alpha: 0.4)),
            prefixIcon: Container(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: 18, color: const Color(0xFFD32F2F)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFFFF8E1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFFE082), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFFE082), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2.5),
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
            Text('🎭', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              'Flow Type',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFFB71C1C)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFE082), width: 2),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
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
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected ? const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]) : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFD32F2F), width: 2),
                    boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, size: 18, color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFD32F2F)),
                      const SizedBox(width: 6),
                      Text(
                        option,
                        style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFFD32F2F)),
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

import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_template_service.dart';

/// Widget to showcase available reminder templates by category
class TemplateShowcase extends StatefulWidget {
  final Function(ReminderTemplate) onTemplateSelected;
  final bool showSearch;
  final bool showCategories;

  const TemplateShowcase({
    super.key,
    required this.onTemplateSelected,
    this.showSearch = true,
    this.showCategories = true,
  });

  @override
  State<TemplateShowcase> createState() => _TemplateShowcaseState();
}

class _TemplateShowcaseState extends State<TemplateShowcase>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'Recommended';

  final List<String> _tabCategories = [
    'Recommended',
    'Office Work',
    'Quick Breaks',
    'Home Workout',
    'Mental Health',
    'All Categories',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showSearch) _buildSearchBar(),
        if (widget.showCategories) _buildCategoryTabs(),
        Expanded(child: _buildTemplateGrid()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search exercises, stretches, wellness...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: Theme.of(context).primaryColor,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedCategory = _tabCategories[index];
        });
      },
      tabs: _tabCategories.map((category) => Tab(text: category)).toList(),
    );
  }

  Widget _buildTemplateGrid() {
    final templates = _getFilteredTemplates();

    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No templates found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'No templates in this category',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  List<ReminderTemplate> _getFilteredTemplates() {
    List<ReminderTemplate> templates;

    // First filter by category
    switch (_selectedCategory) {
      case 'Recommended':
        templates =
            ReminderTemplateService.getBuiltInTemplates().take(3).toList();
        break;
      case 'Office Work':
        templates =
            ReminderTemplateService.getBuiltInTemplates()
                .where(
                  (t) => t.name.contains('Eye') || t.name.contains('Stand'),
                )
                .toList();
        break;
      case 'Quick Breaks':
        templates =
            ReminderTemplateService.getBuiltInTemplates()
                .where(
                  (t) => t.name.contains('Eye') || t.name.contains('Stretch'),
                )
                .toList();
        break;
      case 'Home Workout':
        templates =
            ReminderTemplateService.getBuiltInTemplates()
                .where(
                  (t) => t.name.contains('Pull') || t.name.contains('Push'),
                )
                .toList();
        break;
      case 'Mental Health':
        templates =
            ReminderTemplateService.getBuiltInTemplates()
                .where(
                  (t) => t.name.contains('Water') || t.name.contains('Stretch'),
                )
                .toList();
        break;
      case 'All Categories':
        templates = ReminderTemplateService.getBuiltInTemplates();
        break;
      default:
        templates = ReminderTemplateService.getBuiltInTemplates();
    }

    // Then filter by search query
    if (_searchQuery.isNotEmpty) {
      templates =
          templates
              .where(
                (template) =>
                    template.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    template.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return templates;
  }

  Widget _buildTemplateCard(ReminderTemplate template) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => widget.onTemplateSelected(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and color
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: template.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(template.icon, color: template.color, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Expanded(
                child: Text(
                  template.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Footer with interval and range info
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    Icons.schedule,
                    _formatInterval(template.defaultInterval),
                    Colors.blue,
                  ),
                  _buildInfoChip(
                    Icons.fitness_center,
                    '${template.minQuantity}-${template.maxQuantity} ${template.unit}',
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatInterval(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inDays}d';
    }
  }
}

/// Simple template preview card for lists
class TemplatePreviewCard extends StatelessWidget {
  final ReminderTemplate template;
  final VoidCallback? onTap;
  final bool showDescription;

  const TemplatePreviewCard({
    super.key,
    required this.template,
    this.onTap,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: template.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(template.icon, color: template.color),
        ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle:
            showDescription
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Every ${_formatInterval(template.defaultInterval)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.minQuantity}-${template.maxQuantity} ${template.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                : null,
        trailing: const Icon(Icons.add_circle_outline),
        onTap: onTap,
      ),
    );
  }

  String _formatInterval(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inDays} days';
    }
  }
}

/// Quick action buttons for common templates
class QuickTemplateActions extends StatelessWidget {
  final Function(ReminderTemplate) onTemplateSelected;

  const QuickTemplateActions({super.key, required this.onTemplateSelected});

  @override
  Widget build(BuildContext context) {
    final quickTemplates = [
      ReminderTemplateService.getTemplate(ReminderType.water)!,
      ReminderTemplateService.getTemplate(ReminderType.eyeRest)!,
      ReminderTemplateService.getTemplate(ReminderType.standUp)!,
      ReminderTemplateService.getTemplate(ReminderType.stretch)!,
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            quickTemplates.map((template) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildQuickActionButton(context, template),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    ReminderTemplate template,
  ) {
    return ElevatedButton(
      onPressed: () => onTemplateSelected(template),
      style: ElevatedButton.styleFrom(
        backgroundColor: template.color.withValues(alpha: 0.1),
        foregroundColor: template.color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(template.icon, size: 24),
          const SizedBox(height: 4),
          Text(
            template.name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

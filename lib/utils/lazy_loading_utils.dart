import 'package:flutter/material.dart';

/// Lazy loading utilities for performance optimization
class LazyLoadingUtils {
  /// Creates a lazy-loaded widget that only builds when visible
  static Widget createLazyWidget({
    required Widget Function() builder,
    Widget? placeholder,
    double threshold = 100.0,
  }) {
    return _LazyWidget(
      builder: builder,
      placeholder: placeholder,
      threshold: threshold,
    );
  }

  /// Creates a lazy-loaded list for large datasets
  static Widget createLazyList<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    Widget? emptyState,
    int? initialItemCount,
    ScrollController? controller,
  }) {
    if (items.isEmpty && emptyState != null) {
      return emptyState;
    }

    final visibleItemCount = initialItemCount ?? (items.length < 20 ? items.length : 20);

    return _LazyListView<T>(
      items: items,
      itemBuilder: itemBuilder,
      initialItemCount: visibleItemCount,
      controller: controller,
    );
  }

  /// Memory-efficient image loading
  static Widget createLazyImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
  }) {
    return _LazyImage(
      imagePath: imagePath,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
    );
  }
}

class _LazyWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;
  final double threshold;

  const _LazyWidget({
    required this.builder,
    this.placeholder,
    this.threshold = 100.0,
  });

  @override
  State<_LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<_LazyWidget> {
  bool _isVisible = false;
  bool _hasBuilt = false;
  Widget? _builtWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _VisibilityDetector(
          threshold: widget.threshold,
          onVisibilityChanged: (isVisible) {
            if (isVisible && !_hasBuilt) {
              setState(() {
                _isVisible = true;
                _hasBuilt = true;
                _builtWidget = widget.builder();
              });
            }
          },
          child: _isVisible && _builtWidget != null
              ? _builtWidget!
              : widget.placeholder ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _LazyListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int initialItemCount;
  final ScrollController? controller;

  const _LazyListView({
    required this.items,
    required this.itemBuilder,
    required this.initialItemCount,
    this.controller,
  });

  @override
  State<_LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<_LazyListView<T>> {
  late ScrollController _scrollController;
  int _visibleItemCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _visibleItemCount = widget.initialItemCount;
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more items when scrolled 80% to bottom
      setState(() {
        _visibleItemCount = (_visibleItemCount + 10)
            .clamp(0, widget.items.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.items.take(_visibleItemCount).toList();

    return ListView.builder(
      controller: _scrollController,
      itemCount: visibleItems.length + (_visibleItemCount < widget.items.length ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= visibleItems.length) {
          // Loading indicator for more items
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, visibleItems[index], index);
      },
    );
  }
}

class _LazyImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;

  const _LazyImage({
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
  });

  @override
  State<_LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<_LazyImage> {
  bool _shouldLoad = false;

  @override
  Widget build(BuildContext context) {
    return _VisibilityDetector(
      onVisibilityChanged: (isVisible) {
        if (isVisible && !_shouldLoad) {
          setState(() => _shouldLoad = true);
        }
      },
      child: _shouldLoad
          ? Image.asset(
              widget.imagePath,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              errorBuilder: (context, error, stackTrace) {
                return widget.placeholder ?? const Icon(Icons.error);
              },
            )
          : widget.placeholder ?? 
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[200],
                child: const Icon(Icons.image),
              ),
    );
  }
}

class _VisibilityDetector extends StatefulWidget {
  final Widget child;
  final void Function(bool isVisible) onVisibilityChanged;
  final double threshold;

  const _VisibilityDetector({
    required this.child,
    required this.onVisibilityChanged,
    this.threshold = 0.0,
  });

  @override
  State<_VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<_VisibilityDetector> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkVisibility();
        });
        return false;
      },
      child: widget.child,
    );
  }

  void _checkVisibility() {
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    final isVisible = position.dy < screenSize.height + widget.threshold &&
        position.dy + size.height > -widget.threshold;

    if (isVisible != _isVisible) {
      _isVisible = isVisible;
      widget.onVisibilityChanged(isVisible);
    }
  }
}
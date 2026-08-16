import 'package:flutter/material.dart';

class SkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.4),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: darkTheme ? Colors.grey[800] : Colors.grey[300],
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}

class InitializationSkeletonScreen extends StatelessWidget {
  const InitializationSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: darkTheme ? const Color(0xFF121212) : const Color(0xFFF5F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SkeletonWidget(
                        width: 36,
                        height: 36,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 10),
                      SkeletonWidget(
                        width: 100,
                        height: 20,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  SkeletonWidget(
                    width: 36,
                    height: 36,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              // Greeting line 1
              SkeletonWidget(
                width: 220,
                height: 28,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              
              // Greeting line 2
              SkeletonWidget(
                width: 160,
                height: 16,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 24),
              
              // Large Welcome BMI Card Placeholder
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkTheme ? Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(darkTheme ? 0.2 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SkeletonWidget(
                      width: 80,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    SkeletonWidget(
                      width: 70,
                      height: 40,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 12),
                    SkeletonWidget(
                      width: 130,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 28),
                    
                    // Concentric Circular layout skeleton
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: darkTheme ? Colors.grey[800]! : Colors.grey[200]!,
                          width: 14,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: darkTheme ? const Color(0xFF163E36) : const Color(0xFFE6F3F0),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFF0F6E5C),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Motivational text line 1
                    SkeletonWidget(
                      width: double.infinity,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    // Motivational text line 2
                    SkeletonWidget(
                      width: 200,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Secondary height & weight cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: darkTheme ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SkeletonWidget(
                                width: 20,
                                height: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(width: 8),
                              SkeletonWidget(
                                width: 50,
                                height: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SkeletonWidget(
                            width: 80,
                            height: 22,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: darkTheme ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SkeletonWidget(
                                width: 20,
                                height: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(width: 8),
                              SkeletonWidget(
                                width: 50,
                                height: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SkeletonWidget(
                            width: 80,
                            height: 22,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

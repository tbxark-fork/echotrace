import 'package:flutter/material.dart';

/// 报告生成进度页面
class GenerationProgressPage extends StatelessWidget {
  final Map<String, String> taskStatus; // 任务名 -> 状态
  final int totalProgress; // 0-100

  const GenerationProgressPage({
    super.key,
    required this.taskStatus,
    required this.totalProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 进度环
              _buildProgressRing(),
              const SizedBox(height: 48),
              
              // 进度文字
              const Text(
                '正在生成年度报告...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // 提示文字
              Text(
                '请稍候，这可能需要一些时间',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing() {
    const wechatGreen = Color(0xFF07C160);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: totalProgress / 100),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆环
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.withOpacity(0.2),
                  ),
                ),
              ),
              // 进度圆环
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 12,
                  valueColor: const AlwaysStoppedAnimation<Color>(wechatGreen),
                  backgroundColor: Colors.transparent,
                ),
              ),
              // 百分比文字
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: wechatGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}


import 'package:flutter/material.dart';
import '../services/dual_report_service.dart';
import '../services/dual_report_cache_service.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';
import 'friend_selector_page.dart';
import 'dual_report_display_page.dart';

/// 双人报告主页面
class DualReportPage extends StatefulWidget {
  const DualReportPage({super.key});

  @override
  State<DualReportPage> createState() => _DualReportPageState();
}

class _DualReportPageState extends State<DualReportPage> {
  int? _selectedYear;
  bool _isGenerating = false;
  String _currentTask = '';

  @override
  void initState() {
    super.initState();
    // 在frame渲染完成后再显示对话框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showYearSelectionDialog();
    });
  }

  Future<void> _showYearSelectionDialog() async {
    // 获取可用年份（这里简化处理，只提供最近几年）
    final currentYear = DateTime.now().year;
    final years = [currentYear, currentYear - 1, currentYear - 2];
    
    if (!mounted) return;
    
    final result = await showDialog<int?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('选择年份'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('生成哪一年的双人报告？'),
            const SizedBox(height: 16),
            ...years.map((year) => ListTile(
              title: Text('$year年'),
              onTap: () => Navigator.pop(context, year),
            )),
            const Divider(),
            ListTile(
              title: const Text('历史以来'),
              subtitle: const Text('所有聊天记录'),
              onTap: () => Navigator.pop(context, null),
            ),
          ],
        ),
      ),
    );
    
    if (result == null && !mounted) {
      // 用户关闭对话框，返回上一页
      Navigator.pop(context);
      return;
    }
    
    setState(() {
      _selectedYear = result;
    });
    
    // 选择好友
    _selectFriend();
  }

  Future<void> _selectFriend() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final databaseService = appState.databaseService;
    final dualReportService = DualReportService(databaseService);
    
    if (!mounted) return;
    
    // 打开好友选择页面
    final selectedFriend = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FriendSelectorPage(
          dualReportService: dualReportService,
          year: _selectedYear,
        ),
      ),
    );
    
    if (selectedFriend == null) {
      // 用户取消选择，返回上一页
      if (mounted) Navigator.pop(context);
      return;
    }
    
    // 生成报告
    await _generateReport(
      dualReportService: dualReportService,
      friendUsername: selectedFriend['username'] as String,
      friendDisplayName: selectedFriend['displayName'] as String,
    );
  }

  Future<void> _generateReport({
    required DualReportService dualReportService,
    required String friendUsername,
    required String friendDisplayName,
  }) async {
    // 检查缓存
    final cachedReport = await DualReportCacheService.loadReport(
      friendUsername,
      _selectedYear,
    );
    
    if (cachedReport != null) {
      // 使用缓存
      if (mounted) {
        _showReport(cachedReport);
      }
      return;
    }
    
    // 生成新报告
    setState(() {
      _isGenerating = true;
      _currentTask = '正在生成报告...';
    });
    
    try {
      final reportData = await dualReportService.generateDualReport(
        friendUsername: friendUsername,
        filterYear: _selectedYear,
      );
      
      // 保存到缓存
      await DualReportCacheService.saveReport(
        friendUsername,
        _selectedYear,
        reportData,
      );
      
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        _showReport(reportData);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成报告失败: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showReport(Map<String, dynamic> reportData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DualReportDisplayPage(reportData: reportData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07C160),
      body: Center(
        child: _isGenerating
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _currentTask,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
      ),
    );
  }
}


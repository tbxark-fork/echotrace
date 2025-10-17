import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../models/advanced_analytics_data.dart';
import '../widgets/annual_report/animated_components.dart';

/// 年度报告展示页面，支持翻页滑动查看各个分析模块
class AnnualReportDisplayPage extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final int? year;

  const AnnualReportDisplayPage({
    super.key,
    required this.reportData,
    required this.year,
  });

  @override
  State<AnnualReportDisplayPage> createState() => _AnnualReportDisplayPageState();
}

class _AnnualReportDisplayPageState extends State<AnnualReportDisplayPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _buildPages() {
    _pages = [
      _buildCoverPage(),
      _buildIntroPage(),
      _buildCoreFriendsPage(),
      _buildConfidantPage(),
      _buildListenersPage(),
      _buildMutualFriendsPage(),
      _buildSocialInitiativePage(),
      _buildPeakDayPage(),
      _buildCheckInPage(),
      _buildMessageTypesPage(),
      _buildMessageLengthPage(),
      _buildActivityPatternPage(),      // 作息规律分析
      _buildMidnightKingPage(),          // 深夜活跃排行
      _buildResponseSpeedPage(),         // 回复速度分析
      _buildEndingPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RawKeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey.keyLabel == 'Arrow Right' || 
                event.logicalKey.keyLabel == 'Arrow Down' ||
                event.logicalKey.keyLabel == 'Page Down') {
              // 下一页
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            } else if (event.logicalKey.keyLabel == 'Arrow Left' || 
                       event.logicalKey.keyLabel == 'Arrow Up' ||
                       event.logicalKey.keyLabel == 'Page Up') {
              // 上一页
              if (_currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          }
        },
        child: Stack(
          children: [
            // 主内容区域，支持鼠标滚轮翻页
            Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  if (pointerSignal.scrollDelta.dy > 0) {
                    // 向下滚动 - 下一页
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (pointerSignal.scrollDelta.dy < 0) {
                    // 向上滚动 - 上一页
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                }
              },
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: _pages,
              ),
            ),
          
          // 页面指示器
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF07C160)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          
          // 关闭按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black87, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
        ),
      ),
    );
  }

  /// 构建年度报告封面页
  Widget _buildCoverPage() {
    final yearText = widget.year != null ? '${widget.year}年' : '历史以来';
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInText(
                text: '时光留痕',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.grey[500],
                  letterSpacing: 8,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 48),
              SlideInCard(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  yearText,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07C160),
                    letterSpacing: 6,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInText(
                text: '聊天年度报告',
                delay: const Duration(milliseconds: 700),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 64),
              Container(
                width: 80,
                height: 1,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 32),
                  FadeInText(
                text: '每一条消息背后',
                delay: const Duration(milliseconds: 1000),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  letterSpacing: 2,
                  height: 1.8,
                ),
              ),
              FadeInText(
                text: '都藏着一段温暖的时光',
                delay: const Duration(milliseconds: 1200),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  letterSpacing: 2,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 100),
              FadeInText(
                text: '滑动鼠标或按方向键开始阅读',
                delay: const Duration(milliseconds: 1500),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              FadeInText(
                text: '←  →',
                delay: const Duration(milliseconds: 1700),
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[350],
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 开场页 - 横屏居中流动设计
  Widget _buildIntroPage() {
    final totalMessages = _getTotalMessages();
    final totalFriends = _getTotalFriends();
    final yearText = widget.year != null ? '${widget.year}年' : '这段时光';
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final textSize = height * 0.04;
            final numberSize = height * 0.12;
            final smallSize = height * 0.028;
            
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.15, vertical: height * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInText(
                        text: '在$yearText里',
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[600],
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          FadeInText(
                            text: '你与 ',
                            delay: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: textSize,
                              color: Colors.black87,
                            ),
                          ),
                          SlideInCard(
                            delay: const Duration(milliseconds: 500),
                            child: AnimatedNumberDisplay(
                              value: totalFriends.toDouble(),
                              suffix: '',
                              style: TextStyle(
                                fontSize: numberSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF07C160),
                                height: 1.0,
                              ),
                            ),
                          ),
                          FadeInText(
                            text: ' 位好友',
                            delay: const Duration(milliseconds: 700),
                            style: TextStyle(
                              fontSize: textSize,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.04),
                      FadeInText(
                        text: '交换了',
                        delay: const Duration(milliseconds: 900),
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: height * 0.04),
                      SlideInCard(
                        delay: const Duration(milliseconds: 1100),
                        child: AnimatedNumberDisplay(
                          value: totalMessages.toDouble(),
                          suffix: ' 条消息',
                          style: TextStyle(
                            fontSize: numberSize * 0.8,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF07C160),
                            height: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.08),
                      FadeInText(
                        text: _getOpeningComment(totalMessages),
                        delay: const Duration(milliseconds: 1400),
                        style: TextStyle(
                          fontSize: smallSize,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                          height: 2.0,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 获取总消息数（从报告的总统计字段读取）
  int _getTotalMessages() {
    return (widget.reportData['totalMessages'] as int?) ?? 0;
  }

  // 获取好友总数（从报告的总统计字段读取）
  int _getTotalFriends() {
    return (widget.reportData['totalFriends'] as int?) ?? 0;
  }

  // 根据消息数生成开场评语
  String _getOpeningComment(int messages) {
    if (messages > 50000) {
      return '像是在屏幕两端，搭建了一座专属的桥梁\n每一个字，都是连接彼此的温度';
    } else if (messages > 20000) {
      return '这些文字记录着你们的喜怒哀乐\n也见证着彼此生活的点点滴滴';
    } else if (messages > 10000) {
      return '看似简单的对话，藏着不简单的情谊\n能说这么多话，是因为心里有彼此';
    } else if (messages > 5000) {
      return '字里行间，都是生活的痕迹\n平凡的日常，因为分享而变得特别';
    } else {
      return '虽然话不多，但句句都是真心\n有些关系，不需要太多语言';
    }
  }

  // 年度挚友榜 - 横屏横向排列
  Widget _buildCoreFriendsPage() {
    final List<dynamic> friendsJson = widget.reportData['coreFriends'] ?? [];
    final friends = friendsJson.map((e) => FriendshipRanking.fromJson(e)).toList();
    
    if (friends.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final friend1 = friends.length > 0 ? friends[0] : null;
    final friend2 = friends.length > 1 ? friends[1] : null;
    final friend3 = friends.length > 2 ? friends[2] : null;
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final titleSize = height * 0.05;
            final nameSize = height * 0.055;
            final numberSize = height * 0.04;
            final descSize = height * 0.028;
            
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: height * 0.1),
                  child: Column(
                    children: [
                      FadeInText(
                        text: '年度挚友榜',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      FadeInText(
                        text: '这一年，你们说了最多的话',
                        delay: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: descSize,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: height * 0.12),
                      
                      // 横向排列三个名次
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 第二名
                          if (friend2 != null)
                            Flexible(
                              child: SlideInCard(
                                delay: const Duration(milliseconds: 400),
                                child: _buildRankCard(
                                  rank: 2,
                                  name: friend2.displayName,
                                  count: friend2.count,
                                  percentage: friend2.percentage,
                                  color: const Color(0xFFC0C0C0),
                                  nameSize: nameSize * 0.85,
                                  numberSize: numberSize * 0.9,
                                  descSize: descSize,
                                  width: width,
                                ),
                              ),
                            ),
                          
                          // 第一名 - 最大
                          if (friend1 != null)
                            Flexible(
                              child: SlideInCard(
                                delay: const Duration(milliseconds: 600),
                                child: _buildRankCard(
                                  rank: 1,
                                  name: friend1.displayName,
                                  count: friend1.count,
                                  percentage: friend1.percentage,
                                  color: const Color(0xFFFFD700),
                                  nameSize: nameSize,
                                  numberSize: numberSize,
                                  descSize: descSize,
                                  width: width,
                                  isFirst: true,
                                ),
                              ),
                            ),
                          
                          // 第三名
                          if (friend3 != null)
                            Flexible(
                              child: SlideInCard(
                                delay: const Duration(milliseconds: 800),
                                child: _buildRankCard(
                                  rank: 3,
                                  name: friend3.displayName,
                                  count: friend3.count,
                                  percentage: friend3.percentage,
                                  color: const Color(0xFFCD7F32),
                                  nameSize: nameSize * 0.75,
                                  numberSize: numberSize * 0.85,
                                  descSize: descSize,
                                  width: width,
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
          },
        ),
      ),
    );
  }
  
  Widget _buildRankCard({
    required int rank,
    required String name,
    required int count,
    required double percentage,
    required Color color,
    required double nameSize,
    required double numberSize,
    required double descSize,
    required double width,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        // 奖牌
        Container(
          width: isFirst ? 48 : 40,
          height: isFirst ? 48 : 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: isFirst ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        // 名字
        Container(
          constraints: BoxConstraints(maxWidth: width * 0.22),
          child: Text(
            name,
            style: TextStyle(
              fontSize: nameSize,
              fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
              color: Colors.black87,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 12),
        // 消息数
        Text(
          '$count 条',
          style: TextStyle(
            fontSize: numberSize,
            color: const Color(0xFF07C160),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        // 百分比
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: descSize,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  // 年度倾诉对象页 - 横屏居中设计
  Widget _buildConfidantPage() {
    final List<dynamic> friendsJson = widget.reportData['confidant'] ?? [];
    final friends = friendsJson.map((e) => FriendshipRanking.fromJson(e)).toList();
    
    if (friends.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final friend1 = friends[0];
    final percentage = friend1.percentage;
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final titleSize = height * 0.05;
            final nameSize = height * 0.08;
            final textSize = height * 0.035;
            final smallSize = height * 0.028;
            
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.15, vertical: height * 0.1),
                  child: Column(
                    children: [
                      FadeInText(
                        text: '年度倾诉对象',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: height * 0.08),
                      FadeInText(
                        text: '这一年，有太多的话',
                        delay: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      FadeInText(
                        text: '最想说给',
                        delay: const Duration(milliseconds: 500),
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      SlideInCard(
                        delay: const Duration(milliseconds: 700),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: width * 0.6),
                          child: Text(
                            friend1.displayName,
                            style: TextStyle(
                              fontSize: nameSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF07C160),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      FadeInText(
                        text: '听',
                        delay: const Duration(milliseconds: 900),
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: height * 0.06),
                      FadeInText(
                        text: '你向TA发送了 ${friend1.count} 条消息',
                        delay: const Duration(milliseconds: 1100),
                        style: TextStyle(
                          fontSize: smallSize,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (percentage > 0) ...[
                        SizedBox(height: height * 0.015),
                        FadeInText(
                          text: '占你所有发送消息的 ${percentage.toStringAsFixed(1)}%',
                          delay: const Duration(milliseconds: 1300),
                          style: TextStyle(
                            fontSize: smallSize * 0.9,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                      SizedBox(height: height * 0.06),
                      FadeInText(
                        text: 'TA总是耐心地听你絮絮叨叨\n无论是开心还是难过，你都想第一时间分享给TA',
                        delay: const Duration(milliseconds: 1500),
                        style: TextStyle(
                          fontSize: smallSize * 0.9,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                          height: 2.0,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 年度最佳听众页 - 横屏居中设计
  Widget _buildListenersPage() {
    final List<dynamic> friendsJson = widget.reportData['listeners'] ?? [];
    final friends = friendsJson.map((e) => FriendshipRanking.fromJson(e)).toList();
    
    if (friends.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final friend1 = friends[0];
    final percentage = friend1.percentage;
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final titleSize = height * 0.05;
            final nameSize = height * 0.08;
            final textSize = height * 0.035;
            final smallSize = height * 0.028;
            
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.15, vertical: height * 0.1),
                  child: Column(
                    children: [
                      FadeInText(
                        text: '年度最佳听众',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: height * 0.12),
                      SlideInCard(
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: width * 0.6),
                          child: Text(
                            friend1.displayName,
                            style: TextStyle(
                              fontSize: nameSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF07C160),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.06),
                      FadeInText(
                        text: '总是主动来找你聊天',
                        delay: const Duration(milliseconds: 600),
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: height * 0.08),
                      FadeInText(
                        text: 'TA给你发了 ${friend1.count} 条消息',
                        delay: const Duration(milliseconds: 800),
                        style: TextStyle(
                          fontSize: smallSize,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (percentage > 0) ...[
                        SizedBox(height: height * 0.015),
                        FadeInText(
                          text: '占你接收所有消息的 ${percentage.toStringAsFixed(1)}%',
                          delay: const Duration(milliseconds: 1000),
                          style: TextStyle(
                            fontSize: smallSize * 0.9,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                      SizedBox(height: height * 0.08),
                      FadeInText(
                        text: 'TA就像一束光，总是主动照亮你的世界\n有TA在，你从不孤单',
                        delay: const Duration(milliseconds: 1200),
                        style: TextStyle(
                          fontSize: smallSize * 0.9,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                          height: 2.0,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 双向奔赴页 - 横屏水平对称设计
  Widget _buildMutualFriendsPage() {
    final List<dynamic> friendsJson = widget.reportData['mutualFriends'] ?? [];
    final friends = friendsJson.map((e) => FriendshipRanking.fromJson(e)).toList();
    
    if (friends.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final friend1 = friends[0];
    final ratio = friend1.details?['ratio'] as String? ?? '1.0';
    final sent = friend1.details?['sentCount'] as int? ?? 0;
    final received = friend1.details?['receivedCount'] as int? ?? 0;
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final titleSize = height * 0.05;
            final nameSize = height * 0.065;
            final numberSize = height * 0.1;
            final textSize = height * 0.03;
            final smallSize = height * 0.026;
            
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: height * 0.1),
                  child: Column(
                    children: [
                      FadeInText(
                        text: '双向奔赴',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: height * 0.015),
                      FadeInText(
                        text: '最好的关系，是相互回应',
                        delay: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: smallSize,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: height * 0.06),
                      SlideInCard(
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: width * 0.5),
                          child: Text(
                            friend1.displayName,
                            style: TextStyle(
                              fontSize: nameSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.08),
                      
                      // 水平排列数据
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 你发
                          Column(
                            children: [
                              FadeInText(
                                text: '你发',
                                delay: const Duration(milliseconds: 600),
                                style: TextStyle(
                                  fontSize: textSize,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              FadeInText(
                                text: '$sent',
                                delay: const Duration(milliseconds: 800),
                                style: TextStyle(
                                  fontSize: numberSize,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF07C160),
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(height: 4),
                              FadeInText(
                                text: '条',
                                delay: const Duration(milliseconds: 900),
                                style: TextStyle(
                                  fontSize: smallSize,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(width: width * 0.15),
                          
                          // 箭头
                          FadeInText(
                            text: '⇄',
                            delay: const Duration(milliseconds: 1000),
                            style: TextStyle(
                              fontSize: numberSize * 0.4,
                              color: Colors.grey[300],
                            ),
                          ),
                          
                          SizedBox(width: width * 0.15),
                          
                          // TA回
                          Column(
                            children: [
                              FadeInText(
                                text: 'TA回',
                                delay: const Duration(milliseconds: 600),
                                style: TextStyle(
                                  fontSize: textSize,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              FadeInText(
                                text: '$received',
                                delay: const Duration(milliseconds: 800),
                                style: TextStyle(
                                  fontSize: numberSize,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF07C160),
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(height: 4),
                              FadeInText(
                                text: '条',
                                delay: const Duration(milliseconds: 900),
                                style: TextStyle(
                                  fontSize: smallSize,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      SizedBox(height: height * 0.08),
                      
                      FadeInText(
                        text: '互动比例 $ratio',
                        delay: const Duration(milliseconds: 1100),
                        style: TextStyle(
                          fontSize: textSize,
                          color: const Color(0xFF07C160),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.04),
                      FadeInText(
                        text: '你来我往，不偏不倚\n这就是最舒服的距离',
                        delay: const Duration(milliseconds: 1300),
                        style: TextStyle(
                          fontSize: smallSize * 0.9,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                          height: 2.0,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 主动社交指数页
  Widget _buildSocialInitiativePage() {
    final socialData = SocialStyleData.fromJson(widget.reportData['socialInitiative']);
    
    if (socialData.initiativeRanking.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final friend1 = socialData.initiativeRanking.first;
    final rate = friend1.percentage;
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;
              final titleSize = height > 700 ? 32.0 : 26.0;
              final nameSize = height > 700 ? 38.0 : 32.0;
              final descSize = height > 700 ? 18.0 : 16.0;
              
              String story;
              if (rate > 0.7) {
                story = '与 ${friend1.displayName} 的聊天\n你总是那个主动开启话题的人\n\n因为在乎，所以主动\n这份心意，值得被珍惜';
              } else if (rate > 0.5) {
                story = '你和 ${friend1.displayName}\n谁先开口都一样\n\n聊得来的两个人\n永远不缺话题';
              } else {
                story = '${friend1.displayName}\n更常主动找你聊天\n\nTA在意你的生活\n想要参与你的喜怒哀乐';
              }
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.1, 
                  vertical: height * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeInText(
                      text: '社交主动性',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF07C160),
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.06),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: FadeInText(
                        text: story,
                        delay: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: descSize - 1,
                          color: Colors.grey[700],
                          height: 1.9,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: height * 0.06),
                    SlideInCard(
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        '${(rate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    FadeInText(
                      text: '的对话由你发起',
                      delay: const Duration(milliseconds: 800),
                      style: TextStyle(
                        fontSize: descSize - 2,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
            ),
    );
  }

  // 聊天巅峰日页
  Widget _buildPeakDayPage() {
    final peakDay = ChatPeakDay.fromJson(widget.reportData['peakDay']);
    
    return Container(
      color: Colors.white,
      child: SafeArea(
      child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;
              final titleSize = height > 700 ? 32.0 : 26.0;
              final dateSize = height > 700 ? 34.0 : 28.0;
              final numberSize = height > 700 ? 44.0 : 36.0;
              final descSize = height > 700 ? 18.0 : 16.0;
              final commentSize = height > 700 ? 16.0 : 14.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08, 
                  vertical: height * 0.05,
                ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInText(
                      text: '聊天巅峰日',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF07C160),
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: height * 0.06),
                    SlideInCard(
              delay: const Duration(milliseconds: 300),
                      child: Text(
                        peakDay.formattedDate,
                        style: TextStyle(
                          fontSize: dateSize,
                fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    FadeInText(
                      text: '这一天，你们说了',
                      delay: const Duration(milliseconds: 500),
                      style: TextStyle(
                        fontSize: descSize,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: height * 0.025),
            AnimatedNumberDisplay(
              value: peakDay.messageCount.toDouble(),
              suffix: ' 条消息',
                      style: TextStyle(
                        fontSize: numberSize,
                        fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (peakDay.topFriendDisplayName != null) ...[
                      SizedBox(height: height * 0.05),
              FadeInText(
                        text: '那天和 ${peakDay.topFriendDisplayName}',
                        delay: const Duration(milliseconds: 700),
                        style: TextStyle(
                          fontSize: descSize,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.015),
              FadeInText(
                        text: '聊了 ${peakDay.topFriendMessageCount} 条',
                        delay: const Duration(milliseconds: 900),
                style: TextStyle(
                          fontSize: descSize + 2,
                          color: const Color(0xFF07C160),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                        child: FadeInText(
                          text: _getPeakDayComment(peakDay.messageCount),
                          delay: const Duration(milliseconds: 1100),
                          style: TextStyle(
                            fontSize: commentSize,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                ),
              ),
            ],
          ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getPeakDayComment(int count) {
    if (count > 1000) return '这么多话，一定发生了很重要的事\n或许是开心，或许是难过\n但你们陪伴着彼此度过';
    if (count > 500) return '那一天的你，话匣子停不下来\n有人愿意听你说话\n是一件多么幸福的事';
    if (count > 200) return '一定是个特别的日子\n因为你们聊了好久好久\n时间仿佛都变慢了';
    return '有些日子，就是想多说说话\n而TA刚好也有时间\n这就是最好的陪伴';
  }

  // 连续打卡页
  Widget _buildCheckInPage() {
    final checkIn = widget.reportData['checkIn'] as Map<String, dynamic>;
    final days = checkIn['days'] ?? 0;
    final displayName = checkIn['displayName'] ?? '未知';
    final startDateStr = checkIn['startDate'] as String?;
    final endDateStr = checkIn['endDate'] as String?;
    
    // 格式化日期，只保留年月日
    String? startDate;
    String? endDate;
    if (startDateStr != null) {
      startDate = startDateStr.split('T').first;
    }
    if (endDateStr != null) {
      endDate = endDateStr.split('T').first;
    }
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final titleSize = height > 700 ? 28.0 : 24.0;
            final numberSize = height > 700 ? 68.0 : 56.0;
            final descSize = height > 700 ? 16.0 : 14.0;
            final smallSize = height > 700 ? 13.0 : 11.0;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1, 
                vertical: height * 0.08,
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                  FadeInText(
                    text: '最长连续打卡记录',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF07C160),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.02),
                  FadeInText(
                    text: '那些天，每天都有TA的消息',
                    delay: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: titleSize - 12,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.04),
                  FadeInText(
                    text: displayName,
                    delay: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: descSize + 4,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.08),
                  SlideInCard(
                    delay: const Duration(milliseconds: 600),
                    child: AnimatedNumberDisplay(
              value: days.toDouble(),
              suffix: ' 天',
                      style: TextStyle(
                        fontSize: numberSize,
                fontWeight: FontWeight.bold,
                        color: const Color(0xFF07C160),
              ),
            ),
                  ),
                  if (startDate != null && endDate != null) ...[
                    SizedBox(height: height * 0.05),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.06,
                        vertical: height * 0.025,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
            FadeInText(
                      text: '$startDate 至 $endDate',
                      delay: const Duration(milliseconds: 900),
                      style: TextStyle(
                        fontSize: smallSize,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.015),
                          FadeInText(
                            text: '那段时光，TA的陪伴从未缺席\n每一天的问候，都是默契的约定',
                            delay: const Duration(milliseconds: 1100),
                            style: TextStyle(
                              fontSize: smallSize,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                              height: 1.8,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  // 消息类型页
  Widget _buildMessageTypesPage() {
    final List<dynamic> typesJson = widget.reportData['messageTypes'] ?? [];
    final types = typesJson.map((e) => MessageTypeStats.fromJson(e)).toList();
    
    if (types.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final topType = types.first;
    final type2 = types.length > 1 ? types[1] : null;
    final type3 = types.length > 2 ? types[2] : null;
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;
              final titleSize = height > 700 ? 32.0 : 26.0;
              final percentSize = height > 700 ? 50.0 : 42.0;
              final descSize = height > 700 ? 18.0 : 16.0;
              final commentSize = height > 700 ? 16.0 : 14.0;
              final numberSize = height > 700 ? 15.0 : 13.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08, 
                  vertical: height * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    FadeInText(
                      text: '沟通方式',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF07C160),
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: height * 0.06),
                    
                    FadeInText(
                      text: '你最常用的是',
                      delay: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: descSize,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    SlideInCard(
                      delay: const Duration(milliseconds: 500),
                          child: Text(
                        topType.typeName,
                        style: TextStyle(
                          fontSize: descSize + 4,
                          fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                    SizedBox(height: height * 0.035),
                    AnimatedNumberDisplay(
                      value: topType.percentage * 100,
                      suffix: '%',
                      style: TextStyle(
                        fontSize: percentSize,
                            fontWeight: FontWeight.bold,
                        color: const Color(0xFF07C160),
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    FadeInText(
                      text: _getMessageTypeStory(topType),
                      delay: const Duration(milliseconds: 900),
                      style: TextStyle(
                        fontSize: commentSize,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (type2 != null && type3 != null) ...[
                      SizedBox(height: height * 0.04),
                      FadeInText(
                        text: '其次是 ${type2.typeName} 和 ${type3.typeName}',
                        delay: const Duration(milliseconds: 1100),
                        style: TextStyle(
                          fontSize: numberSize,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      FadeInText(
                        text: '各占 ${(type2.percentage * 100).toStringAsFixed(1)}% 和 ${(type3.percentage * 100).toStringAsFixed(1)}%',
                        delay: const Duration(milliseconds: 1300),
                        style: TextStyle(
                          fontSize: numberSize,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
            ),
    );
  }

  String _getMessageTypeStory(MessageTypeStats type) {
    if (type.typeName.contains('文本')) {
      return '你是个喜欢用文字表达的人\n一字一句，都是认真组织过的话语\n文字让情感沉淀，也让思念有迹可循';
    } else if (type.typeName.contains('图片')) {
      return '你喜欢用图片说话\n一张图，胜过千言万语\n那些美好的瞬间，值得被看见';
    } else if (type.typeName.contains('语音')) {
      return '你更习惯用声音交流\n语气里的情绪，文字表达不出来\n声音让距离变得不再遥远';
    } else if (type.typeName.contains('视频')) {
      return '你喜欢发视频\n动态的画面更生动\n分享生活的方式有很多种，你选择了最直接的';
    } else if (type.typeName.contains('表情')) {
      return '表情包是你的社交语言\n有时候不需要多说什么\n一个表情就能心领神会';
    }
    return '每种表达方式都有它的温度\n而你找到了最适合自己的方式';
  }

  // 表达欲分析页
  Widget _buildMessageLengthPage() {
    final lengthData = MessageLengthData.fromJson(widget.reportData['messageLength']);
    
    return Container(
      color: Colors.white,
      child: SafeArea(
      child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;
              final titleSize = height > 700 ? 32.0 : 26.0;
              final numberSize = height > 700 ? 48.0 : 40.0;
              final descSize = height > 700 ? 18.0 : 16.0;
              final commentSize = height > 700 ? 16.0 : 14.0;
              final smallNumberSize = height > 700 ? 15.0 : 13.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08, 
                  vertical: height * 0.05,
                ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInText(
                      text: '表达欲指数',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF07C160),
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: height * 0.06),
                    FadeInText(
                      text: '平均每条消息',
              delay: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: descSize,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    SlideInCard(
                      delay: const Duration(milliseconds: 500),
                      child: AnimatedNumberDisplay(
              value: lengthData.averageLength,
              suffix: ' 字',
                        style: TextStyle(
                          fontSize: numberSize,
                fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.035),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: FadeInText(
                        text: _getAverageLengthComment(lengthData.averageLength),
                        delay: const Duration(milliseconds: 700),
                        style: TextStyle(
                          fontSize: commentSize,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    if (lengthData.longestLength > 0) ...[
                      SizedBox(height: height * 0.05),
            FadeInText(
                        text: '你写过最长的一条消息',
                        delay: const Duration(milliseconds: 900),
                        style: TextStyle(
                          fontSize: descSize - 2,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: height * 0.015),
                      FadeInText(
                        text: '${lengthData.longestLength} 字',
                        delay: const Duration(milliseconds: 1100),
                        style: TextStyle(
                          fontSize: descSize + 4,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (lengthData.longestSentToDisplayName != null) ...[
                        SizedBox(height: height * 0.015),
              FadeInText(
                          text: '发给 ${lengthData.longestSentToDisplayName}',
                          delay: const Duration(milliseconds: 1300),
                style: TextStyle(
                            fontSize: smallNumberSize,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                ),
              ),
                      ],
            ],
          ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getAverageLengthComment(double avgLength) {
    if (avgLength > 50) return '你是个爱长篇大论的人\n因为总有说不完的话\n想要分享的心情太多，一句两句装不下';
    if (avgLength > 30) return '话不算多，但都说在点子上\n你知道什么该说，什么不该说\n恰到好处的表达，是一种智慧';
    if (avgLength > 15) return '简洁明了，这就是你的风格\n不拖泥带水，不绕弯子\n几个字就能把意思说清楚';
    return '惜字如金，言简意赅\n你的每一个字都经过思考\n简单的话语，往往最有力量';
  }


  // 作息图谱页
  Widget _buildActivityPatternPage() {
    final activityJson = widget.reportData['activityPattern'];
    if (activityJson == null) {
      return Container(
        color: Colors.white,
        child: const Center(child: Text('暂无数据')),
      );
    }
    
    final activity = ActivityHeatmap.fromJson(activityJson);
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final titleSize = height > 700 ? 28.0 : 24.0;
            final textSize = height > 700 ? 18.0 : 16.0;
            final numberSize = height > 700 ? 32.0 : 28.0;
            
            // 找出最活跃时段
            int maxHour = 0;
            int maxValue = 0;
            for (int hour = 0; hour < 24; hour++) {
              int hourTotal = 0;
              for (int day = 1; day <= 7; day++) {
                hourTotal += activity.getCount(hour, day);
              }
              if (hourTotal > maxValue) {
                maxValue = hourTotal;
                maxHour = hour;
              }
            }
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1,
                vertical: height * 0.08,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInText(
                    text: '生活节奏',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF07C160),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.02),
                  FadeInText(
                    text: '你的活跃时刻',
                    delay: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: titleSize - 12,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.06),
                  FadeInText(
                    text: '每天的这个时候',
                    delay: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: textSize,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.04),
                  SlideInCard(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      '${maxHour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        fontSize: numberSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF07C160),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: FadeInText(
                      text: '你总是特别想聊天\n或许这就是你的黄金时刻\n灵感涌现，话语滔滔不绝',
                    delay: const Duration(milliseconds: 900),
                    style: TextStyle(
                      fontSize: textSize - 2,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                        height: 1.9,
                        letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 深夜密友页
  Widget _buildMidnightKingPage() {
    final midnightKing = widget.reportData['midnightKing'];
    if (midnightKing == null || midnightKing['count'] == 0) {
      return Container(
        color: Colors.white,
        child: const Center(child: Text('暂无深夜聊天数据')),
      );
    }
    
    final displayName = midnightKing['displayName'] as String? ?? '未知';
    final count = midnightKing['count'] as int;
    final percentage = midnightKing['percentage'] as String? ?? '0';
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final titleSize = height > 700 ? 28.0 : 24.0;
            final nameSize = height > 700 ? 42.0 : 36.0;
            final numberSize = height > 700 ? 24.0 : 20.0;
            final textSize = height > 700 ? 16.0 : 14.0;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1,
                vertical: height * 0.08,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInText(
                    text: '深夜密友',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5C6BC0),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.02),
                  FadeInText(
                    text: '夜深人静时的温暖陪伴',
                    delay: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: titleSize - 12,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.04),
                  FadeInText(
                    text: '在深夜 0:00 - 6:00',
                    delay: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: textSize,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.06),
                  SlideInCard(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: nameSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C6BC0),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: height * 0.06),
                  FadeInText(
                    text: '陪你聊了',
                    delay: const Duration(milliseconds: 900),
                    style: TextStyle(
                      fontSize: textSize,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInText(
                        text: '$count',
                        delay: const Duration(milliseconds: 1100),
                        style: TextStyle(
                          fontSize: numberSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C6BC0),
                        ),
                      ),
                      SizedBox(width: 8),
                      FadeInText(
                        text: '条消息',
                        delay: const Duration(milliseconds: 1100),
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  FadeInText(
                    text: '占深夜消息的 $percentage%',
                    delay: const Duration(milliseconds: 1300),
                    style: TextStyle(
                      fontSize: textSize - 2,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.04),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: FadeInText(
                      text: '当世界安静下来\nTA的消息就像星光\n温柔地照亮你的深夜',
                      delay: const Duration(milliseconds: 1500),
                      style: TextStyle(
                        fontSize: textSize - 2,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                        height: 1.9,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 响应速度页（合并最快响应和我回复最快）
  Widget _buildResponseSpeedPage() {
    final whoRepliesFastest = widget.reportData['whoRepliesFastest'] as List?;
    final myFastestReplies = widget.reportData['myFastestReplies'] as List?;
    
    if ((whoRepliesFastest == null || whoRepliesFastest.isEmpty) &&
        (myFastestReplies == null || myFastestReplies.isEmpty)) {
      return Container(
        color: Colors.white,
        child: const Center(child: Text('暂无数据')),
      );
    }
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final titleSize = height > 700 ? 28.0 : 24.0;
            final nameSize = height > 700 ? 24.0 : 20.0;
            final textSize = height > 700 ? 16.0 : 14.0;
            
            // 获取第一名
            final fastestPerson = whoRepliesFastest != null && whoRepliesFastest.isNotEmpty
                ? whoRepliesFastest.first
                : null;
            final myFastest = myFastestReplies != null && myFastestReplies.isNotEmpty
                ? myFastestReplies.first
                : null;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1,
                vertical: height * 0.08,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInText(
                    text: '秒回速度',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF07C160),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.02),
                  FadeInText(
                    text: '在乎的人，总是回得很快',
                    delay: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: titleSize - 12,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.06),
                  
                  // 谁回复我最快
                  if (fastestPerson != null) ...[
                    FadeInText(
                      text: '回复你最快的人',
                      delay: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: textSize,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.03),
                    SlideInCard(
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        fastestPerson['displayName'] as String,
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    FadeInText(
                      text: _formatResponseTime(fastestPerson['avgResponseTimeMinutes'] as num),
                      delay: const Duration(milliseconds: 800),
                      style: TextStyle(
                        fontSize: textSize - 2,
                        color: const Color(0xFF07C160),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: FadeInText(
                        text: 'TA总是第一时间回应你\n这份在意，让人心安',
                        delay: const Duration(milliseconds: 900),
                        style: TextStyle(
                          fontSize: textSize - 3,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          height: 1.8,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  
                  if (fastestPerson != null && myFastest != null)
                    SizedBox(height: height * 0.08),
                  
                  // 我回复最快的人
                  if (myFastest != null) ...[
                    FadeInText(
                      text: '你回复最快的人',
                      delay: const Duration(milliseconds: 1000),
                      style: TextStyle(
                        fontSize: textSize,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.03),
                    SlideInCard(
                      delay: const Duration(milliseconds: 1300),
                      child: Text(
                        myFastest['displayName'] as String,
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF07C160),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    FadeInText(
                      text: _formatResponseTime(myFastest['avgResponseTimeMinutes'] as num),
                      delay: const Duration(milliseconds: 1500),
                      style: TextStyle(
                        fontSize: textSize - 2,
                        color: const Color(0xFF07C160),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: FadeInText(
                        text: '面对TA的消息，你总是秒回\n因为这个人，值得你放下一切',
                        delay: const Duration(milliseconds: 1600),
                        style: TextStyle(
                          fontSize: textSize - 3,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          height: 1.8,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatResponseTime(num minutes) {
    if (minutes < 1) {
      return '平均 ${(minutes * 60).toStringAsFixed(0)} 秒';
    } else if (minutes < 60) {
      return '平均 ${minutes.toStringAsFixed(1)} 分钟';
    } else {
      final hours = minutes / 60;
      return '平均 ${hours.toStringAsFixed(1)} 小时';
    }
  }

  // 结束页 - 简约排版，修复溢出
  Widget _buildEndingPage() {
    final yearText = widget.year != null ? '${widget.year}年' : '这段时光';
    final totalMessages = _getTotalMessages();
    final totalFriends = _getTotalFriends();
    
    return Container(
      color: Colors.white,
      child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;
              final titleSize = height > 700 ? 32.0 : 28.0;
            final numberSize = height > 700 ? 56.0 : 48.0;
            final textSize = height > 700 ? 17.0 : 15.0;
            final smallSize = height > 700 ? 14.0 : 13.0;
            
            return Stack(
              children: [
                // 顶部标题
                Positioned(
                  left: width * 0.08,
                  top: height * 0.1,
                  right: width * 0.08,
          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInText(
                      text: '$yearText的故事',
                      style: TextStyle(
                        fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                        color: const Color(0xFF07C160),
                        letterSpacing: 2,
                ),
              ),
                      SizedBox(height: 8),
              FadeInText(
                        text: '就这样被记录下来了',
                      delay: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: textSize,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 中间数据区域
                Positioned(
                  left: width * 0.12,
                  top: height * 0.32,
                  child: SlideInCard(
                    delay: const Duration(milliseconds: 600),
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        AnimatedNumberDisplay(
                          value: totalMessages.toDouble(),
                          suffix: '',
                              style: TextStyle(
                            fontSize: numberSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF07C160),
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                            Text(
                          '条消息',
                              style: TextStyle(
                            fontSize: textSize - 2,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Positioned(
                  right: width * 0.12,
                  top: height * 0.48,
                  child: SlideInCard(
                    delay: const Duration(milliseconds: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedNumberDisplay(
                          value: totalFriends.toDouble(),
                          suffix: '',
                          style: TextStyle(
                            fontSize: numberSize * 0.7,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF07C160),
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                            Text(
                          '位好友',
                              style: TextStyle(
                            fontSize: textSize - 3,
                            color: Colors.grey[600],
                          ),
                            ),
                          ],
                        ),
                      ),
                    ),
                
                // 中间分隔线
                Positioned(
                  left: width * 0.3,
                  right: width * 0.3,
                  top: height * 0.58,
                  child: SlideInCard(
                    delay: const Duration(milliseconds: 1000),
                    child: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                
                // 底部温暖寄语
                Positioned(
                  left: width * 0.1,
                  right: width * 0.1,
                  bottom: height * 0.08,
                  child: Column(
                    children: [
                    FadeInText(
                        text: '每一条消息\n都是你们关系的见证',
                        delay: const Duration(milliseconds: 1200),
                      style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[700],
                          height: 1.9,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.04),
                    FadeInText(
                        text: '愿你珍惜那些愿意陪你聊天的人\n未来的日子里，继续用心记录',
                        delay: const Duration(milliseconds: 1400),
                      style: TextStyle(
                          fontSize: smallSize,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                          height: 2.0,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.03),
                      FadeInText(
                        text: '♡',
                        delay: const Duration(milliseconds: 1600),
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.grey[350],
            ),
          ),
        ],
                ),
                ),
              ],
              );
            },
        ),
      ),
    );
  }
}

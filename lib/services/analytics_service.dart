import '../models/message.dart';
import '../models/analytics_data.dart';
import 'database_service.dart';

/// 数据分析服务
class AnalyticsService {
  final DatabaseService _databaseService;

  AnalyticsService(this._databaseService);

  /// 分析私聊数据
  /// 
  /// [sessionId] 会话ID（username）
  /// [includeWordFrequency] 是否包含词频分析（可能比较耗时）
  Future<PrivateChatAnalytics> analyzePrivateChat(
    String sessionId, {
    bool includeWordFrequency = false,
  }) async {
    // 1. 获取该会话的所有消息
    final messages = await getAllMessagesForSession(sessionId);
    
    // 2. 过滤出私聊消息（排除群聊）
    if (sessionId.contains('@chatroom')) {
      throw Exception('此功能仅支持私聊分析');
    }

    // 3. 计算基础统计
    final statistics = _calculateStatistics(messages);

    // 4. 分析时间分布
    final timeDistribution = _analyzeTimeDistribution(messages);

    // 5. 词频分析（可选）
    WordFrequency? wordFrequency;
    if (includeWordFrequency) {
      wordFrequency = _analyzeWordFrequency(messages);
    }

    // 6. 联系人排名（这里只有一个联系人）
    final contactRankings = await _getContactRankings([sessionId]);

    return PrivateChatAnalytics(
      statistics: statistics,
      timeDistribution: timeDistribution,
      wordFrequency: wordFrequency,
      contactRankings: contactRankings,
    );
  }

  /// 获取所有私聊联系人的排名
  Future<List<ContactRanking>> getAllPrivateChatsRanking({int limit = 20}) async {
    // 1. 获取所有会话
    final sessions = await _databaseService.getSessions();
    
    // 2. 过滤出私聊会话
    final privateSessions = sessions.where((s) => !s.isGroup).toList();
    
    // 3. 获取排名
    final rankings = await _getContactRankings(
      privateSessions.map((s) => s.username).toList(),
    );
    
    // 4. 排序并限制数量
    rankings.sort((a, b) => b.messageCount.compareTo(a.messageCount));
    
    return rankings.take(limit).toList();
  }

  /// 分析全部私聊的总体统计
  Future<ChatStatistics> analyzeAllPrivateChats() async {
    // 1. 获取所有私聊会话
    final sessions = await _databaseService.getSessions();
    final privateSessions = sessions.where((s) => !s.isGroup).toList();
    
    // 2. 收集所有私聊消息
    final allMessages = <Message>[];
    for (final session in privateSessions) {
      try {
        final messages = await getAllMessagesForSession(session.username);
        allMessages.addAll(messages);
      } catch (e) {
        // 某个会话读取失败，跳过
      }
    }
    
    // 3. 计算统计
    return _calculateStatistics(allMessages);
  }

  /// 获取指定时间范围内的消息
  Future<List<Message>> getMessagesByDateRange(
    String sessionId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final messages = await getAllMessagesForSession(sessionId);
    
    final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;
    
    return messages.where((msg) {
      return msg.createTime >= startTimestamp && msg.createTime <= endTimestamp;
    }).toList();
  }

  /// 搜索包含特定关键词的消息
  Future<List<Message>> searchKeywordInSession(
    String sessionId,
    String keyword,
  ) async {
    final messages = await getAllMessagesForSession(sessionId);
    
    return messages.where((msg) {
      return msg.displayContent.contains(keyword);
    }).toList();
  }

  // ==================== 公开方法 ====================

  /// 获取会话的所有消息（分批加载）
  Future<List<Message>> getAllMessagesForSession(String sessionId) async {
    final allMessages = <Message>[];
    const batchSize = 500;
    int offset = 0;
    
    while (true) {
      final batch = await _databaseService.getMessages(
        sessionId,
        limit: batchSize,
        offset: offset,
      );
      
      if (batch.isEmpty) break;
      
      allMessages.addAll(batch);
      offset += batchSize;
      
      // 安全限制：最多加载10万条消息
      if (offset >= 100000) break;
    }
    
    return allMessages;
  }

  /// 计算基础统计
  ChatStatistics _calculateStatistics(List<Message> messages) {
    int totalMessages = messages.length;
    int textMessages = 0;
    int imageMessages = 0;
    int voiceMessages = 0;
    int videoMessages = 0;
    int otherMessages = 0;
    int sentMessages = 0;
    int receivedMessages = 0;

    DateTime? firstMessageTime;
    DateTime? lastMessageTime;
    final activeDaysSet = <String>{};

    for (final msg in messages) {
      // 消息类型统计
      switch (msg.localType) {
        case 1:
        case 244813135921: // 引用消息也算文本
          textMessages++;
          break;
        case 3:
          imageMessages++;
          break;
        case 34:
          voiceMessages++;
          break;
        case 43:
          videoMessages++;
          break;
        default:
          otherMessages++;
      }

      // 发送/接收统计
      if (msg.isSend == 1) {
        sentMessages++;
      } else {
        receivedMessages++;
      }

      // 时间统计
      final msgTime = DateTime.fromMillisecondsSinceEpoch(msg.createTime * 1000);
      if (firstMessageTime == null || msgTime.isBefore(firstMessageTime)) {
        firstMessageTime = msgTime;
      }
      if (lastMessageTime == null || msgTime.isAfter(lastMessageTime)) {
        lastMessageTime = msgTime;
      }

      // 活跃天数
      final dateKey = '${msgTime.year}-${msgTime.month}-${msgTime.day}';
      activeDaysSet.add(dateKey);
    }

    return ChatStatistics(
      totalMessages: totalMessages,
      textMessages: textMessages,
      imageMessages: imageMessages,
      voiceMessages: voiceMessages,
      videoMessages: videoMessages,
      otherMessages: otherMessages,
      sentMessages: sentMessages,
      receivedMessages: receivedMessages,
      firstMessageTime: firstMessageTime,
      lastMessageTime: lastMessageTime,
      activeDays: activeDaysSet.length,
    );
  }

  /// 分析时间分布
  TimeDistribution _analyzeTimeDistribution(List<Message> messages) {
    final hourlyDistribution = <int, int>{};
    final weekdayDistribution = <int, int>{};
    final monthlyDistribution = <String, int>{};

    // 初始化小时分布 (0-23)
    for (int i = 0; i < 24; i++) {
      hourlyDistribution[i] = 0;
    }

    // 初始化星期分布 (1-7)
    for (int i = 1; i <= 7; i++) {
      weekdayDistribution[i] = 0;
    }

    for (final msg in messages) {
      final msgTime = DateTime.fromMillisecondsSinceEpoch(msg.createTime * 1000);

      // 小时分布
      hourlyDistribution[msgTime.hour] = (hourlyDistribution[msgTime.hour] ?? 0) + 1;

      // 星期分布
      weekdayDistribution[msgTime.weekday] = (weekdayDistribution[msgTime.weekday] ?? 0) + 1;

      // 月份分布
      final monthKey = '${msgTime.year}-${msgTime.month.toString().padLeft(2, '0')}';
      monthlyDistribution[monthKey] = (monthlyDistribution[monthKey] ?? 0) + 1;
    }

    return TimeDistribution(
      hourlyDistribution: hourlyDistribution,
      weekdayDistribution: weekdayDistribution,
      monthlyDistribution: monthlyDistribution,
    );
  }

  /// 分析词频（简单的分词统计）
  WordFrequency _analyzeWordFrequency(List<Message> messages) {
    final wordCount = <String, int>{};
    int totalWords = 0;

    for (final msg in messages) {
      // 只分析文本消息
      if (!msg.isTextMessage && msg.localType != 244813135921) continue;

      final content = msg.displayContent;
      if (content.isEmpty || content.startsWith('[')) continue;

      // 简单分词：按字符分割（中文按字分，英文按词分）
      final words = _simpleTokenize(content);
      
      for (final word in words) {
        if (word.isEmpty || word.length < 2) continue; // 过滤单字和空字符
        
        wordCount[word] = (wordCount[word] ?? 0) + 1;
        totalWords++;
      }
    }

    return WordFrequency(
      wordCount: wordCount,
      totalWords: totalWords,
    );
  }

  /// 简单分词（中文按双字分，英文按空格分）
  List<String> _simpleTokenize(String text) {
    final words = <String>[];
    
    // 分离中英文
    final chinesePattern = RegExp(r'[\u4e00-\u9fa5]+');
    final englishPattern = RegExp(r'[a-zA-Z]+');
    
    // 提取中文词（双字组合）
    final chineseMatches = chinesePattern.allMatches(text);
    for (final match in chineseMatches) {
      final chinese = match.group(0)!;
      // 双字组合
      for (int i = 0; i < chinese.length - 1; i++) {
        words.add(chinese.substring(i, i + 2));
      }
    }
    
    // 提取英文词
    final englishMatches = englishPattern.allMatches(text);
    for (final match in englishMatches) {
      final word = match.group(0)!.toLowerCase();
      if (word.length >= 2) {
        words.add(word);
      }
    }
    
    return words;
  }

  /// 获取联系人排名
  Future<List<ContactRanking>> _getContactRankings(List<String> usernames) async {
    final rankings = <ContactRanking>[];
    
    // 批量获取显示名称
    final displayNames = await _databaseService.getDisplayNames(usernames);
    
    for (final username in usernames) {
      try {
        final messages = await getAllMessagesForSession(username);
        if (messages.isEmpty) continue;

        final messageCount = messages.length;
        final sentCount = messages.where((m) => m.isSend == 1).length;
        final receivedCount = messages.where((m) => m.isSend != 1).length;
        
        final lastMessage = messages.isNotEmpty 
            ? messages.reduce((a, b) => a.createTime > b.createTime ? a : b)
            : null;
        
        final lastMessageTime = lastMessage != null
            ? DateTime.fromMillisecondsSinceEpoch(lastMessage.createTime * 1000)
            : null;

        rankings.add(ContactRanking(
          username: username,
          displayName: displayNames[username] ?? username,
          messageCount: messageCount,
          sentCount: sentCount,
          receivedCount: receivedCount,
          lastMessageTime: lastMessageTime,
        ));
      } catch (e) {
        // 读取失败，跳过
      }
    }
    
    return rankings;
  }

  /// 导出聊天数据为文本格式
  Future<String> exportChatAsText(String sessionId) async {
    final messages = await getAllMessagesForSession(sessionId);
    final displayNames = await _databaseService.getDisplayNames([sessionId]);
    final contactName = displayNames[sessionId] ?? sessionId;
    
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('聊天记录导出');
    buffer.writeln('联系人: $contactName');
    buffer.writeln('消息数量: ${messages.length}');
    buffer.writeln('导出时间: ${DateTime.now()}');
    buffer.writeln('========================================\n');
    
    // 按时间正序排列
    messages.sort((a, b) => a.createTime.compareTo(b.createTime));
    
    for (final msg in messages) {
      final time = DateTime.fromMillisecondsSinceEpoch(msg.createTime * 1000);
      final sender = msg.isSend == 1 ? '我' : contactName;
      final timeStr = '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      
      buffer.writeln('[$timeStr] $sender');
      buffer.writeln('  ${msg.displayContent}');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
}


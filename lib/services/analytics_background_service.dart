import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../services/database_service.dart';
import '../services/advanced_analytics_service.dart';
import '../services/response_time_analyzer.dart';
import '../services/logger_service.dart';
import '../models/advanced_analytics_data.dart';

/// Isolate 通信消息
class _AnalyticsMessage {
  final String type; // 'progress' | 'error' | 'done' | 'log'
  final String? stage; // 当前分析阶段
  final int? current;
  final int? total;
  final String? detail; // 详细信息
  final int? elapsedSeconds; // 已用时间（秒）
  final int? estimatedRemainingSeconds; // 预估剩余时间（秒）
  final dynamic result;
  final String? error;
  final String? logMessage; // 日志消息
  final String? logLevel; // 日志级别: 'info' | 'warning' | 'error' | 'debug'

  _AnalyticsMessage({
    required this.type,
    this.stage,
    this.current,
    this.total,
    this.detail,
    this.elapsedSeconds,
    this.estimatedRemainingSeconds,
    this.result,
    this.error,
    this.logMessage,
    this.logLevel,
  });
}

/// 分析任务参数
class _AnalyticsTask {
  final String dbPath;
  final String? filterUsername; // 如果指定，只分析特定用户
  final int? filterYear;
  final String analysisType;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  _AnalyticsTask({
    required this.dbPath,
    this.filterUsername,
    this.filterYear,
    required this.analysisType,
    required this.sendPort,
    required this.rootIsolateToken,
  });
}

/// 分析进度回调函数类型
/// 用来实时报告分析进度和状态信息
///
/// 参数说明：
/// - [stage]: 当前分析阶段的描述（如"加载数据"、"处理用户"等）
/// - [current]: 当前进度值
/// - [total]: 总进度值
/// - [detail]: 详细信息，比如当前正在处理哪个用户
/// - [elapsedSeconds]: 已经用去的时间（秒）
/// - [estimatedRemainingSeconds]: 预计还需的时间（秒）
typedef AnalyticsProgressCallback = void Function(
  String stage,
  int current,
  int total, {
  String? detail,
  int? elapsedSeconds,
  int? estimatedRemainingSeconds,
});

/// 后台分析服务（使用独立Isolate）
/// 通过独立的Isolate执行数据库操作，避免阻塞主线程
/// 所有分析任务都在后台运行，只返回最终结果
class AnalyticsBackgroundService {
  final String dbPath;

  AnalyticsBackgroundService(this.dbPath);
  /// 在后台分析作息规律
  Future<ActivityHeatmap> analyzeActivityPatternInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'activity',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return ActivityHeatmap.fromJson(result);
  }

  /// 在后台分析语言风格
  Future<LinguisticStyle> analyzeLinguisticStyleInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'linguistic',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return LinguisticStyle.fromJson(result);
  }

  /// 在后台分析哈哈哈报告
  Future<Map<String, dynamic>> analyzeHahaReportInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    return await _runAnalysisInIsolate(
      analysisType: 'haha',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
  }

  /// 在后台查找深夜密谈之王
  Future<Map<String, dynamic>> findMidnightChatKingInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    return await _runAnalysisInIsolate(
      analysisType: 'midnight',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
  }

  /// 在后台生成亲密度日历
  Future<IntimacyCalendar> generateIntimacyCalendarInBackground(
    String username,
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'intimacy',
      filterUsername: username,
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    
    // 反序列化 DateTime
    final dailyMessages = <DateTime, int>{};
    final dailyMessagesRaw = result['dailyMessages'] as Map<String, dynamic>;
    dailyMessagesRaw.forEach((key, value) {
      dailyMessages[DateTime.parse(key)] = value as int;
    });
    
    return IntimacyCalendar(
      username: result['username'] as String,
      dailyMessages: dailyMessages,
      startDate: DateTime.parse(result['startDate'] as String),
      endDate: DateTime.parse(result['endDate'] as String),
      maxDailyCount: result['maxDailyCount'] as int,
    );
  }

  /// 在后台分析对话天平
  Future<ConversationBalance> analyzeConversationBalanceInBackground(
    String username,
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'balance',
      filterUsername: username,
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    
    return ConversationBalance(
      username: result['username'] as String,
      sentCount: result['sentCount'] as int,
      receivedCount: result['receivedCount'] as int,
      sentWords: result['sentWords'] as int,
      receivedWords: result['receivedWords'] as int,
      initiatedByMe: result['initiatedByMe'] as int,
      initiatedByOther: result['initiatedByOther'] as int,
      conversationSegments: result['conversationSegments'] as int,
      segmentsInitiatedByMe: result['segmentsInitiatedByMe'] as int,
      segmentsInitiatedByOther: result['segmentsInitiatedByOther'] as int,
    );
  }

  /// 在后台分析谁回复我最快
  Future<List<Map<String, dynamic>>> analyzeWhoRepliesFastestInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'who_replies_fastest',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    
    return (result['results'] as List).cast<Map<String, dynamic>>();
  }

  /// 在后台分析我回复谁最快
  Future<List<Map<String, dynamic>>> analyzeMyFastestRepliesInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'my_fastest_replies',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    
    return (result['results'] as List).cast<Map<String, dynamic>>();
  }

  /// 通用 Isolate 分析执行器
  Future<dynamic> _runAnalysisInIsolate({
    required String analysisType,
    String? filterUsername,
    int? filterYear,
    required AnalyticsProgressCallback progressCallback,
  }) async {
    ReceivePort? receivePort;
    try {
      await logger.info('RunAnalysis', '开始准备Isolate任务: $analysisType');
      
      receivePort = ReceivePort();
      final task = _AnalyticsTask(
        dbPath: dbPath,
        filterUsername: filterUsername,
        filterYear: filterYear,
        analysisType: analysisType,
        sendPort: receivePort.sendPort,
        rootIsolateToken: ServicesBinding.rootIsolateToken!,
      );

      await logger.info('RunAnalysis', '准备启动Isolate: $analysisType');
      
      // 添加错误和退出监听
      final errorPort = ReceivePort();
      final exitPort = ReceivePort();
      
      // 启动 Isolate
      final isolate = await Isolate.spawn(
        _analyzeInIsolate, 
        task, 
        debugName: 'Analytics-$analysisType',
        onError: errorPort.sendPort,
        onExit: exitPort.sendPort,
      );
      
      await logger.info('RunAnalysis', 'Isolate已启动: $analysisType, ID: ${isolate.debugName}');
      
      // 监听错误
      errorPort.listen((errorData) async {
        await logger.error('RunAnalysis', 'Isolate错误: $analysisType', errorData);
      });
      
      // 监听退出
      exitPort.listen((exitData) async {
        await logger.info('RunAnalysis', 'Isolate退出: $analysisType, 退出数据: $exitData');
      });
      
      await logger.info('RunAnalysis', '开始监听消息: $analysisType');

      // 监听进度消息
      dynamic result;
      int messageCount = 0;
      await for (final message in receivePort) {
        messageCount++;
        await logger.debug('RunAnalysis', '收到消息 #$messageCount: $analysisType, 类型: ${message.runtimeType}');
        
        if (message is _AnalyticsMessage) {
          if (message.type == 'log') {
            final logMsg = message.logMessage ?? '';
            final level = message.logLevel ?? 'info';
            switch (level) {
              case 'error':
                await logger.error('Isolate-$analysisType', logMsg);
                break;
              case 'warning':
                await logger.warning('Isolate-$analysisType', logMsg);
                break;
              case 'debug':
                await logger.debug('Isolate-$analysisType', logMsg);
                break;
              default:
                await logger.info('Isolate-$analysisType', logMsg);
            }
          } else if (message.type == 'progress') {
            progressCallback(
              message.stage ?? '', 
              message.current ?? 0, 
              message.total ?? 100,
              detail: message.detail,
              elapsedSeconds: message.elapsedSeconds,
              estimatedRemainingSeconds: message.estimatedRemainingSeconds,
            );
          } else if (message.type == 'done') {
            await logger.info('RunAnalysis', '收到完成消息: $analysisType');
            result = message.result;
            receivePort.close();
            break;
          } else if (message.type == 'error') {
            await logger.error('RunAnalysis', '收到错误消息: $analysisType, 错误: ${message.error}');
            receivePort.close();
            throw Exception(message.error);
          }
        } else {
          await logger.warning('RunAnalysis', '收到未知类型的消息: ${message.runtimeType}');
        }
      }

      await logger.info('RunAnalysis', '消息监听结束: $analysisType, 共收到 $messageCount 条消息');
      
      // 清理监听
      errorPort.close();
      exitPort.close();
      
      return result;
    } catch (e) {
      await logger.error('RunAnalysis', '捕获异常: $analysisType, 错误: $e');
      // 确保receivePort被关闭
      receivePort?.close();
      rethrow;
    }
  }

  /// 后台 Isolate 分析入口函数
  static Future<void> _analyzeInIsolate(_AnalyticsTask task) async {
    if (!logger.isInIsolateMode) {
      logger.enableIsolateMode();
    }

    runZonedGuarded(() async {
      // 辅助函数：发送日志到主线程
      void sendLog(String message, {String level = 'info'}) {
        if (message.isEmpty) return;
        task.sendPort.send(_AnalyticsMessage(
          type: 'log',
          logMessage: message,
          logLevel: level,
        ));
      }

      DatabaseService? dbService;
      try {
        sendLog('开始执行任务: ${task.analysisType}, filterYear: ${task.filterYear}');

        // 不需要初始化 BackgroundIsolateBinaryMessenger，因为我们不使用平台通道
        // 避免在release模式下stdout写入导致的错误
        sendLog('跳过 BackgroundIsolateBinaryMessenger 初始化（Isolate中不需要）');

          sqfliteFfiInit();
          sendLog('sqflite_ffi 初始化完成');

          final startTime = DateTime.now();

          task.sendPort.send(_AnalyticsMessage(
            type: 'progress',
            stage: '正在打开数据库...',
            current: 0,
            total: 100,
            elapsedSeconds: 0,
            estimatedRemainingSeconds: 60,
          ));

          sendLog('创建 DatabaseService');
          dbService = DatabaseService();

          sendLog('初始化 DatabaseService');
          await dbService.initialize(factory: databaseFactoryFfi).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              sendLog('初始化 DatabaseService 超时', level: 'error');
              throw TimeoutException('初始化 DatabaseService 超时');
            },
          );
          sendLog('DatabaseService 初始化完成');

          sendLog('开始连接数据库: ${task.dbPath}');
          sendLog('即将调用 connectDecryptedDatabase');
          try {
            await dbService.connectDecryptedDatabase(task.dbPath, factory: databaseFactoryFfi).timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                sendLog('连接数据库超时', level: 'error');
                throw TimeoutException('连接数据库超时，可能数据库文件被占用');
              },
            );
            sendLog('connectDecryptedDatabase 调用返回');
          } catch (e) {
            sendLog('connectDecryptedDatabase 调用失败: $e', level: 'error');
            rethrow;
          }
          sendLog('数据库连接成功');

          task.sendPort.send(_AnalyticsMessage(
            type: 'progress',
            stage: '正在分析数据...',
            current: 30,
            total: 100,
            elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
            estimatedRemainingSeconds: _estimateRemainingTime(30, 100, startTime),
          ));

          sendLog('创建 AdvancedAnalyticsService');
          final analyticsService = AdvancedAnalyticsService(dbService);
          if (task.filterYear != null) {
            analyticsService.setYearFilter(task.filterYear);
            sendLog('设置年份过滤: ${task.filterYear}');
          }

          dynamic result;
          sendLog('开始执行分析类型: ${task.analysisType}');

          switch (task.analysisType) {
            case 'activity':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在分析作息规律...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final data = await analyticsService.analyzeActivityPattern();
              result = data.toJson();
              break;

            case 'linguistic':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在分析语言风格...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final data = await analyticsService.analyzeLinguisticStyle();
              result = data.toJson();
              break;

            case 'haha':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在统计快乐指数...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              result = await analyticsService.analyzeHahaReport();
              break;

            case 'midnight':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在寻找深夜密谈之王...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              result = await analyticsService.findMidnightChatKing();
              break;

            case 'intimacy':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在生成亲密度日历...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final data = await analyticsService.generateIntimacyCalendar(task.filterUsername!);
              // 转换 DateTime 为 String 以便传递
              result = {
                'username': data.username,
                'dailyMessages': data.dailyMessages.map((k, v) => MapEntry(k.toIso8601String(), v)),
                'startDate': data.startDate.toIso8601String(),
                'endDate': data.endDate.toIso8601String(),
                'maxDailyCount': data.maxDailyCount,
              };
              break;

            case 'balance':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在分析对话天平...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final data = await analyticsService.analyzeConversationBalance(task.filterUsername!);
              result = {
                'username': data.username,
                'sentCount': data.sentCount,
                'receivedCount': data.receivedCount,
                'sentWords': data.sentWords,
                'receivedWords': data.receivedWords,
                'initiatedByMe': data.initiatedByMe,
                'initiatedByOther': data.initiatedByOther,
                'conversationSegments': data.conversationSegments,
                'segmentsInitiatedByMe': data.segmentsInitiatedByMe,
                'segmentsInitiatedByOther': data.segmentsInitiatedByOther,
              };
              break;

            case 'who_replies_fastest':
              final analyzer = ResponseTimeAnalyzer(dbService);
              if (task.filterYear != null) {
                analyzer.setYearFilter(task.filterYear);
              }
              
              final results = await analyzer.analyzeWhoRepliesFastest(
                onProgress: (current, total, username) {
                  final elapsed = DateTime.now().difference(startTime).inSeconds;
                  task.sendPort.send(_AnalyticsMessage(
                    type: 'progress',
                    stage: '正在分析响应速度...',
                    current: current,
                    total: total,
                    detail: username,
                    elapsedSeconds: elapsed,
                    estimatedRemainingSeconds: _estimateRemainingTime(current, total, startTime),
                  ));
                },
              );
              
              result = {
                'results': results.map((r) => r.toJson()).toList(),
              };
              break;

            case 'my_fastest_replies':
              final analyzer = ResponseTimeAnalyzer(dbService);
              if (task.filterYear != null) {
                analyzer.setYearFilter(task.filterYear);
              }
              
              final results = await analyzer.analyzeMyFastestReplies(
                onProgress: (current, total, username) {
                  final elapsed = DateTime.now().difference(startTime).inSeconds;
                  task.sendPort.send(_AnalyticsMessage(
                    type: 'progress',
                    stage: '正在分析我的响应速度...',
                    current: current,
                    total: total,
                    detail: username,
                    elapsedSeconds: elapsed,
                    estimatedRemainingSeconds: _estimateRemainingTime(current, total, startTime),
                  ));
                },
              );
              
              result = {
                'results': results.map((r) => r.toJson()).toList(),
              };
              break;

            case 'absoluteCoreFriends':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在统计绝对核心好友...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              // 获取所有好友统计以计算总数
              final allCoreFriends = await analyticsService.getAbsoluteCoreFriends(999999);
              // 只取前3名用于展示
              final top3 = allCoreFriends.take(3).toList();
              // 计算总消息数和总好友数
              int totalMessages = 0;
              for (var friend in allCoreFriends) {
                totalMessages += friend.count;
              }
              result = {
                'top3': top3.map((e) => e.toJson()).toList(),
                'totalMessages': totalMessages,
                'totalFriends': allCoreFriends.length,
              };
              break;

            case 'confidantObjects':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在统计年度倾诉对象...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final confidants = await analyticsService.getConfidantObjects(3);
              result = confidants.map((e) => e.toJson()).toList();
              break;

            case 'bestListeners':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在统计年度最佳听众...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final listeners = await analyticsService.getBestListeners(3);
              result = listeners.map((e) => e.toJson()).toList();
              break;

            case 'mutualFriends':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在统计双向奔赴好友...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final mutual = await analyticsService.getMutualFriendsRanking(3);
              result = mutual.map((e) => e.toJson()).toList();
              break;

            case 'socialInitiative':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在分析主动社交指数...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final socialStyle = await analyticsService.analyzeSocialInitiativeRate();
              result = socialStyle.toJson();
              break;

            case 'peakChatDay':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在统计聊天巅峰日...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final peakDay = await analyticsService.analyzePeakChatDay();
              result = peakDay.toJson();
              break;

            case 'longestCheckIn':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在统计连续打卡记录...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final checkIn = await analyticsService.findLongestCheckInRecord();
              result = {
                'username': checkIn['username'],
                'displayName': checkIn['displayName'],
                'days': checkIn['days'],
                'startDate': (checkIn['startDate'] as DateTime?)?.toIso8601String(),
                'endDate': (checkIn['endDate'] as DateTime?)?.toIso8601String(),
              };
              break;

            case 'messageTypes':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在统计消息类型分布...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final typeStats = await analyticsService.analyzeMessageTypeDistribution();
              result = typeStats.map((e) => e.toJson()).toList();
              break;

            case 'messageLength':
              task.sendPort.send(_AnalyticsMessage(
                type: 'progress',
                stage: '正在分析消息长度...',
                current: 50,
                total: 100,
                elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
                estimatedRemainingSeconds: _estimateRemainingTime(50, 100, startTime),
              ));
              final lengthData = await analyticsService.analyzeMessageLength();
              result = lengthData.toJson();
              break;

            default:
              throw Exception('未知的分析类型: ${task.analysisType}');
          }

          sendLog('分析完成，准备发送结果');
          task.sendPort.send(_AnalyticsMessage(
            type: 'progress',
            stage: '分析完成',
            current: 100,
            total: 100,
            elapsedSeconds: DateTime.now().difference(startTime).inSeconds,
            estimatedRemainingSeconds: 0,
          ));

          sendLog('发送完成消息');
          task.sendPort.send(_AnalyticsMessage(
            type: 'done',
            result: result,
          ));
          sendLog('任务完成: ${task.analysisType}');
        } catch (e, stackTrace) {
          task.sendPort.send(_AnalyticsMessage(
            type: 'error',
            error: e.toString(),
          ));
          sendLog('任务失败: ${task.analysisType}, 错误: $e', level: 'error');
          sendLog('堆栈: $stackTrace', level: 'error');
        } finally {
          sendLog('开始清理资源');
          if (dbService != null) {
            try {
              sendLog('关闭数据库连接');
              await dbService.close();
              sendLog('数据库连接已关闭');
            } catch (e) {
              sendLog('关闭数据库失败: $e', level: 'error');
            }
          }
          sendLog('Isolate 退出: ${task.analysisType}');
        }
    }, (error, stackTrace) {
      task.sendPort.send(_AnalyticsMessage(
        type: 'error',
        error: error.toString(),
      ));
      task.sendPort.send(_AnalyticsMessage(
        type: 'log',
        logMessage: 'runZonedGuarded 捕获错误: $error',
        logLevel: 'error',
      ));
      task.sendPort.send(_AnalyticsMessage(
        type: 'log',
        logMessage: '堆栈: $stackTrace',
        logLevel: 'error',
      ));
    }, zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        task.sendPort.send(_AnalyticsMessage(
          type: 'log',
          logMessage: line,
          logLevel: 'debug',
        ));
      },
    ));
  }

  /// 估计剩余时间（秒）
  static int _estimateRemainingTime(int current, int total, DateTime startTime) {
    if (current == 0) return 60;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    if (elapsed == 0) return 60;
    final totalEstimated = (elapsed * total) ~/ current;
    final remaining = totalEstimated - elapsed;
    return remaining.clamp(1, 3600); // 最少1秒，最多1小时
  }

  /// 绝对核心好友（后台版本）
  Future<Map<String, dynamic>> getAbsoluteCoreFriendsInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'absoluteCoreFriends',
      filterYear: filterYear,
      progressCallback: progressCallback,
    ) as Map<String, dynamic>;
    
    return {
      'top3': (result['top3'] as List).cast<Map<String, dynamic>>()
          .map((e) => FriendshipRanking.fromJson(e))
          .toList(),
      'totalMessages': result['totalMessages'],
      'totalFriends': result['totalFriends'],
    };
  }

  /// 年度倾诉对象（后台版本）
  Future<List<FriendshipRanking>> getConfidantObjectsInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'confidantObjects',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return (result as List).cast<Map<String, dynamic>>()
        .map((e) => FriendshipRanking.fromJson(e))
        .toList();
  }

  /// 年度最佳听众（后台版本）
  Future<List<FriendshipRanking>> getBestListenersInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'bestListeners',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return (result as List).cast<Map<String, dynamic>>()
        .map((e) => FriendshipRanking.fromJson(e))
        .toList();
  }

  /// 双向奔赴好友（后台版本）
  Future<List<FriendshipRanking>> getMutualFriendsRankingInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'mutualFriends',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return (result as List).cast<Map<String, dynamic>>()
        .map((e) => FriendshipRanking.fromJson(e))
        .toList();
  }

  /// 主动社交指数（后台版本）
  Future<SocialStyleData> analyzeSocialInitiativeRateInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'socialInitiative',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return SocialStyleData.fromJson(result);
  }

  /// 年度聊天巅峰日（后台版本）
  Future<ChatPeakDay> analyzePeakChatDayInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'peakChatDay',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return ChatPeakDay.fromJson(result);
  }

  /// 连续打卡记录（后台版本）
  Future<Map<String, dynamic>> findLongestCheckInRecordInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'longestCheckIn',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return result;
  }

  /// 消息类型分布（后台版本）
  Future<List<MessageTypeStats>> analyzeMessageTypeDistributionInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'messageTypes',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return (result as List).cast<Map<String, dynamic>>()
        .map((e) => MessageTypeStats.fromJson(e))
        .toList();
  }

  /// 消息长度分析（后台版本）
  Future<MessageLengthData> analyzeMessageLengthInBackground(
    int? filterYear,
    AnalyticsProgressCallback progressCallback,
  ) async {
    final result = await _runAnalysisInIsolate(
      analysisType: 'messageLength',
      filterYear: filterYear,
      progressCallback: progressCallback,
    );
    return MessageLengthData.fromJson(result);
  }

  /// 生成完整年度报告（并行执行所有任务）
  Future<Map<String, dynamic>> generateFullAnnualReport(
    int? filterYear,
    void Function(String taskName, String status, int progress) progressCallback,
  ) async {
    await logger.info('AnnualReport', '开始生成年度报告, filterYear: $filterYear, dbPath: $dbPath');
    
    final taskProgress = <String, int>{};
    final taskStatus = <String, String>{};
    
    // 初始化任务状态
    final taskNames = [
      '绝对核心好友',
      '年度倾诉对象',
      '年度最佳听众',
      '双向奔赴好友',
      '主动社交指数',
      '聊天巅峰日',
      '连续打卡记录',
      '作息图谱',
      '深夜密友',
      '最快响应好友',
      '我回复最快',
    ];
    
    await logger.info('AnnualReport', '初始化 ${taskNames.length} 个任务');
    for (final name in taskNames) {
      taskProgress[name] = 0;
      taskStatus[name] = '等待中';
    }
    
    // 创建进度回调包装器
    AnalyticsProgressCallback createProgressCallback(String taskName) {
      return (
        String stage,
        int current,
        int total, {
        String? detail,
        int? elapsedSeconds,
        int? estimatedRemainingSeconds,
      }) {
        taskProgress[taskName] = (current / total * 100).toInt();
        taskStatus[taskName] = current >= total ? '已完成' : '进行中';
        
        // 计算总体进度
        final totalProgress = taskProgress.values.reduce((a, b) => a + b) ~/ taskNames.length;
        progressCallback(taskName, taskStatus[taskName]!, totalProgress);
      };
    }
    
    // 串行执行所有任务，避免数据库锁定（一次只执行一个Isolate）
    // 每个任务都有5分钟超时保护
    final timeout = const Duration(minutes: 5);
    
    await logger.info('AnnualReport', '开始任务 1/11: 绝对核心好友');
    final coreFriendsData = await getAbsoluteCoreFriendsInBackground(
      filterYear,
      createProgressCallback('绝对核心好友'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 绝对核心好友');
      throw TimeoutException('分析绝对核心好友超时，数据量可能过大');
    });
    await logger.info('AnnualReport', '完成任务 1/11: 绝对核心好友');
    
    await logger.info('AnnualReport', '开始任务 2/11: 年度倾诉对象');
    final confidant = await getConfidantObjectsInBackground(
      filterYear,
      createProgressCallback('年度倾诉对象'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 年度倾诉对象');
      throw TimeoutException('分析年度倾诉对象超时');
    });
    await logger.info('AnnualReport', '完成任务 2/11: 年度倾诉对象');
    
    await logger.info('AnnualReport', '开始任务 3/11: 年度最佳听众');
    final listeners = await getBestListenersInBackground(
      filterYear,
      createProgressCallback('年度最佳听众'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 年度最佳听众');
      throw TimeoutException('分析年度最佳听众超时');
    });
    await logger.info('AnnualReport', '完成任务 3/11: 年度最佳听众');
    
    await logger.info('AnnualReport', '开始任务 4/11: 双向奔赴好友');
    final mutualFriends = await getMutualFriendsRankingInBackground(
      filterYear,
      createProgressCallback('双向奔赴好友'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 双向奔赴好友');
      throw TimeoutException('分析双向奔赴好友超时');
    });
    await logger.info('AnnualReport', '完成任务 4/11: 双向奔赴好友');
    
    await logger.info('AnnualReport', '开始任务 5/11: 主动社交指数');
    final socialInitiative = await analyzeSocialInitiativeRateInBackground(
      filterYear,
      createProgressCallback('主动社交指数'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 主动社交指数');
      throw TimeoutException('分析主动社交指数超时');
    });
    await logger.info('AnnualReport', '完成任务 5/11: 主动社交指数');
    
    await logger.info('AnnualReport', '开始任务 6/11: 聊天巅峰日');
    final peakDay = await analyzePeakChatDayInBackground(
      filterYear,
      createProgressCallback('聊天巅峰日'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 聊天巅峰日');
      throw TimeoutException('分析聊天巅峰日超时');
    });
    await logger.info('AnnualReport', '完成任务 6/11: 聊天巅峰日');
    
    await logger.info('AnnualReport', '开始任务 7/11: 连续打卡记录');
    final checkIn = await findLongestCheckInRecordInBackground(
      filterYear,
      createProgressCallback('连续打卡记录'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 连续打卡记录');
      throw TimeoutException('分析连续打卡记录超时');
    });
    await logger.info('AnnualReport', '完成任务 7/11: 连续打卡记录');
    
    await logger.info('AnnualReport', '开始任务 8/11: 作息图谱');
    final activityPattern = await analyzeActivityPatternInBackground(
      filterYear,
      createProgressCallback('作息图谱'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 作息图谱');
      throw TimeoutException('分析作息图谱超时');
    });
    await logger.info('AnnualReport', '完成任务 8/11: 作息图谱');
    
    await logger.info('AnnualReport', '开始任务 9/11: 深夜密友');
    final midnightKing = await findMidnightChatKingInBackground(
      filterYear,
      createProgressCallback('深夜密友'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 深夜密友');
      throw TimeoutException('分析深夜密友超时');
    });
    await logger.info('AnnualReport', '完成任务 9/11: 深夜密友');
    
    await logger.info('AnnualReport', '开始任务 10/11: 最快响应好友');
    final whoRepliesFastest = await analyzeWhoRepliesFastestInBackground(
      filterYear,
      createProgressCallback('最快响应好友'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 最快响应好友');
      throw TimeoutException('分析最快响应好友超时，可能因为好友数量过多');
    });
    await logger.info('AnnualReport', '完成任务 10/11: 最快响应好友');
    
    await logger.info('AnnualReport', '开始任务 11/11: 我回复最快');
    final myFastestReplies = await analyzeMyFastestRepliesInBackground(
      filterYear,
      createProgressCallback('我回复最快'),
    ).timeout(timeout, onTimeout: () {
      logger.error('AnnualReport', '任务超时: 我回复最快');
      throw TimeoutException('分析我回复最快超时，可能因为好友数量过多');
    });
    await logger.info('AnnualReport', '完成任务 11/11: 我回复最快');
    
    // 组装结果
    await logger.info('AnnualReport', '所有任务完成，开始组装结果');
    return {
      'coreFriends': (coreFriendsData['top3'] as List<FriendshipRanking>).map((e) => e.toJson()).toList(),
      'totalMessages': coreFriendsData['totalMessages'],
      'totalFriends': coreFriendsData['totalFriends'],
      'confidant': confidant.map((e) => e.toJson()).toList(),
      'listeners': listeners.map((e) => e.toJson()).toList(),
      'mutualFriends': mutualFriends.map((e) => e.toJson()).toList(),
      'socialInitiative': socialInitiative.toJson(),
      'peakDay': peakDay.toJson(),
      'checkIn': checkIn,
      'activityPattern': activityPattern.toJson(),
      'midnightKing': midnightKing,
      'whoRepliesFastest': whoRepliesFastest,
      'myFastestReplies': myFastestReplies,
    };
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../services/database_service.dart';
import '../services/config_service.dart';

/// 应用状态管理
class AppState extends ChangeNotifier {
  final DatabaseService databaseService = DatabaseService();
  final ConfigService configService = ConfigService();

  bool _isConfigured = false;
  String _currentPage = 'welcome';
  bool _isLoading = false;
  String? _errorMessage;
  
  // 解密进度
  bool _isDecrypting = false;
  String _decryptingDatabase = '';
  int _decryptProgress = 0;
  int _decryptTotal = 0;

  bool get isConfigured => _isConfigured;
  String get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // 解密进度 getters
  bool get isDecrypting => _isDecrypting;
  String get decryptingDatabase => _decryptingDatabase;
  int get decryptProgress => _decryptProgress;
  int get decryptTotal => _decryptTotal;
  
  /// 获取解密进度百分比
  double get decryptProgressPercent {
    if (_decryptTotal == 0) return 0;
    return _decryptProgress / _decryptTotal;
  }
  
  /// 获取当前数据库模式
  DatabaseMode get currentDatabaseMode => databaseService.mode;

  /// 初始化应用状态
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 初始化数据库服务
      await databaseService.initialize();

      // 检查配置状态
      _isConfigured = await configService.isConfigured();

      // 启动时始终显示欢迎页面，让用户手动选择
      _currentPage = 'welcome';
      
      // 如果已配置，自动连接已解密的数据库
      if (_isConfigured) {
        await _tryConnectDecryptedDatabase();
      }
    } catch (e) {
      _errorMessage = '初始化失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 设置配置状态
  void setConfigured(bool configured) {
    _isConfigured = configured;
    configService.setConfigured(configured);
    notifyListeners();
  }

  /// 设置当前页面
  void setCurrentPage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误消息
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 重新连接数据库（公开方法，用于配置更改后重新连接）
  Future<void> reconnectDatabase() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _tryConnectDecryptedDatabase();
    } catch (e) {
      _errorMessage = '重新连接数据库失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 尝试连接数据库（仅使用备份模式）
  Future<void> _tryConnectDecryptedDatabase() async {
    try {
      // 仅使用备份模式连接解密后的数据库
      await _connectDecryptedBackupDatabase();
    } catch (e) {
    }
  }
  
  
  /// 连接解密后的备份数据库
  Future<void> _connectDecryptedBackupDatabase() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final documentsPath = documentsDir.path;
      
      // 查找所有 wxid 目录
      final echoTraceDir = Directory('$documentsPath${Platform.pathSeparator}EchoTrace');
      if (!await echoTraceDir.exists()) {
        return;
      }
      
      final wxidDirs = await echoTraceDir.list().where((entity) {
        return entity is Directory && 
               entity.path.split(Platform.pathSeparator).last.startsWith('wxid_');
      }).toList();
      
      // 遍历每个 wxid 目录，查找所有已解密的数据库
      for (final wxidEntity in wxidDirs) {
        final wxidDir = wxidEntity as Directory;
        
        
        // 获取目录下所有 .db 文件
        final dbFiles = await wxidDir.list().where((entity) {
          return entity is File &&
                 entity.path.endsWith('.db');
        }).toList();
        
        
        // 优先查找 session.db（包含会话列表）
        for (final dbFile in dbFiles) {
          final fileName = dbFile.path.split(Platform.pathSeparator).last;
          
          // 优先尝试 session.db
          if (fileName.contains('session')) {
            try {
              await databaseService.connectDecryptedDatabase(dbFile.path);
              final tables = await databaseService.getAllTableNames();
              
              // 检查是否包含 SessionTable
              if (tables.contains('SessionTable')) {
                return; // 成功找到并连接
              }
            } catch (e) {
              // 连接失败
            }
          }
        }
        
        // 如果没找到 session.db，尝试其他数据库
        for (final dbFile in dbFiles) {
          final fileName = dbFile.path.split(Platform.pathSeparator).last;
          if (fileName.contains('session')) continue; // 已经尝试过
          
          try {
            await databaseService.connectDecryptedDatabase(dbFile.path);
            final tables = await databaseService.getAllTableNames();
          
            
            // 检查是否包含会话或消息相关的表
            final hasSessionTable = tables.contains('SessionTable');
            final hasMsgTable = tables.any((t) => t.startsWith('Msg_'));
            final hasContactTable = tables.contains('contact') || tables.contains('Contact');
            final hasFMessageTable = tables.contains('FMessageTable');
            
            if (hasSessionTable || hasMsgTable || hasContactTable || hasFMessageTable) {
              if (kDebugMode) {
                // 找到相关数据库
              }
              return; // 成功找到并连接
            }
          } catch (e) {
            // 连接失败
          }
        }
      }
      
    } catch (e) {
      rethrow;
    }
  }
}

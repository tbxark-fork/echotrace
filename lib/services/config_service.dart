import 'package:shared_preferences/shared_preferences.dart';

/// 配置服务 - 用于持久化存储应用配置
class ConfigService {
  static const String _keyDecryptKey = 'decrypt_key';
  static const String _keyDatabasePath = 'database_path';
  static const String _keyIsConfigured = 'is_configured';
  static const String _keyUseRealtimeMode = 'use_realtime_mode'; // 废弃，仅用于兼容性清理

  /// 保存解密密钥
  Future<void> saveDecryptKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDecryptKey, key);
  }

  /// 获取解密密钥
  Future<String?> getDecryptKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDecryptKey);
  }

  /// 保存数据库路径
  Future<void> saveDatabasePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDatabasePath, path);
  }

  /// 获取数据库路径
  Future<String?> getDatabasePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDatabasePath);
  }

  /// 设置配置状态
  Future<void> setConfigured(bool configured) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsConfigured, configured);
  }

  /// 获取配置状态
  Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsConfigured) ?? false;
  }

  /// 移除实时模式设置（不再支持实时模式）
  Future<void> removeUseRealtimeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUseRealtimeMode);
  }

  /// 清除所有配置
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDecryptKey);
    await prefs.remove(_keyDatabasePath);
    await prefs.remove(_keyIsConfigured);
    await prefs.remove(_keyUseRealtimeMode); // 兼容性：移除旧的实时模式设置
  }
}

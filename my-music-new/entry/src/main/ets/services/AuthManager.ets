import { User, LoginRequest, RegisterRequest, LoginResponse } from '../models/User';
import { UserService } from './UserService';
import { HttpClient } from './HttpClient';
import AppConstants from '../constants/AppConstants';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

// 定义preferences选项接口
interface PreferencesOptions {
  name: string;
}

/**
 * 认证状态管理器
 * 负责用户登录状态、token存储和管理
 */
export class AuthManager {
  private static instance: AuthManager | null = null;
  private userService: UserService;
  private currentUser: User | null = null;
  private isLoggedIn: boolean = false;
  private context: common.UIAbilityContext | null = null;
  
  // 状态变化监听器
  private authStateListeners: ((isLoggedIn: boolean, user: User | null) => void)[] = [];

  private constructor() {
    this.userService = new UserService();
  }

  static getInstance(): AuthManager {
    if (!AuthManager.instance) {
      AuthManager.instance = new AuthManager();
    }
    return AuthManager.instance;
  }

  /**
   * 设置应用上下文
   */
  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  /**
   * 初始化认证管理器（向后兼容）
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.setContext(context);
    await this.loadAuthState();
  }

  /**
   * 从本地存储加载认证状态
   */
  async loadAuthState(): Promise<void> {
    try {
      if (!this.context) return;
      
      const options: PreferencesOptions = { name: 'auth_preferences' };
      const dataPreferences = preferences.getPreferencesSync(this.context, options);
      
      const token = dataPreferences.getSync(AppConstants.STORAGE_KEYS.USER_TOKEN, '') as string;
      const userInfo = dataPreferences.getSync(AppConstants.STORAGE_KEYS.USER_INFO, '') as string;
      
      if (token && userInfo) {
        this.currentUser = JSON.parse(userInfo) as User;
        this.isLoggedIn = true;
        
        // 设置token到HttpClient
        const httpClient = HttpClient.getInstance();
        httpClient.setToken(token);
        
        // 验证token是否有效
        try {
          const user = await this.userService.getCurrentUser();
          this.currentUser = user;
          this.notifyAuthStateChange();
        } catch (error) {
          console.error('Token validation failed:', error);
          // token无效，清除本地存储
          await this.clearAuthState();
        }
      }
    } catch (error) {
      console.error('Failed to load auth state:', error);
    }
  }

  /**
   * 保存认证状态到本地存储
   */
  private async saveAuthState(user: User, token: string, refreshToken?: string): Promise<void> {
    try {
      if (!this.context) return;
      
      const options: PreferencesOptions = { name: 'auth_preferences' };
      const dataPreferences = preferences.getPreferencesSync(this.context, options);
      
      dataPreferences.putSync(AppConstants.STORAGE_KEYS.USER_TOKEN, token);
      dataPreferences.putSync(AppConstants.STORAGE_KEYS.USER_INFO, JSON.stringify(user));
      
      if (refreshToken) {
        dataPreferences.putSync(AppConstants.STORAGE_KEYS.REFRESH_TOKEN, refreshToken);
      }
      
      dataPreferences.flush();
    } catch (error) {
      console.error('Failed to save auth state:', error);
    }
  }

  /**
   * 清除认证状态
   */
  private async clearAuthState(): Promise<void> {
    try {
      if (!this.context) return;
      
      const options: PreferencesOptions = { name: 'auth_preferences' };
      const dataPreferences = preferences.getPreferencesSync(this.context, options);
      
      dataPreferences.deleteSync(AppConstants.STORAGE_KEYS.USER_TOKEN);
      dataPreferences.deleteSync(AppConstants.STORAGE_KEYS.USER_INFO);
      dataPreferences.deleteSync(AppConstants.STORAGE_KEYS.REFRESH_TOKEN);
      
      dataPreferences.flush();
      
      // 清除HttpClient中的token
      const httpClient = HttpClient.getInstance();
      httpClient.setToken('');
      
      this.currentUser = null;
      this.isLoggedIn = false;
      this.notifyAuthStateChange();
    } catch (error) {
      console.error('Failed to clear auth state:', error);
    }
  }

  /**
   * 用户登录
   */
  async login(loginData: LoginRequest): Promise<LoginResponse> {
    try {
      const response = await this.userService.login(loginData);
      
      const user = response.user;
      const token = response.token;
      const refreshToken = response.refreshToken;
      
      this.currentUser = user;
      this.isLoggedIn = true;
      
      await this.saveAuthState(user, token, refreshToken);
      this.notifyAuthStateChange();
      
      return response;
    } catch (error) {
      await this.clearAuthState();
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new Error(`Login failed: ${errorMessage}`);
    }
  }

  /**
   * 用户注册
   */
  async register(registerData: RegisterRequest): Promise<LoginResponse> {
    try {
      const response = await this.userService.register(registerData);
      
      const user = response.user;
      const token = response.token;
      const refreshToken = response.refreshToken;
      
      this.currentUser = user;
      this.isLoggedIn = true;
      
      await this.saveAuthState(user, token, refreshToken);
      this.notifyAuthStateChange();
      
      return response;
    } catch (error) {
      await this.clearAuthState();
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new Error(`Register failed: ${errorMessage}`);
    }
  }

  /**
   * 用户退出登录
   */
  async logout(): Promise<void> {
    try {
      await this.userService.logout();
    } catch (error) {
      console.warn('Logout API call failed:', error);
    } finally {
      await this.clearAuthState();
    }
  }

  /**
   * 刷新令牌
   */
  async refreshToken(): Promise<boolean> {
    try {
      if (!this.context) return false;
      
      const options: PreferencesOptions = { name: 'auth_preferences' };
      const dataPreferences = preferences.getPreferencesSync(this.context, options);
      
      const refreshToken = dataPreferences.getSync(AppConstants.STORAGE_KEYS.REFRESH_TOKEN, '') as string;
      
      if (!refreshToken) {
        await this.clearAuthState();
        return false;
      }
      
      const response = await this.userService.refreshToken(refreshToken);
      
      const user = response.user;
      const token = response.token;
      const newRefreshToken = response.refreshToken;
      
      this.currentUser = user;
      await this.saveAuthState(user, token, newRefreshToken);
      
      return true;
    } catch (error) {
      console.error('Failed to refresh token:', error);
      await this.clearAuthState();
      return false;
    }
  }

  /**
   * 获取当前用户信息
   */
  getCurrentUser(): User | null {
    return this.currentUser;
  }

  /**
   * 获取登录状态
   */
  getIsLoggedIn(): boolean {
    return this.isLoggedIn;
  }

  /**
   * 更新用户信息
   */
  updateUserInfo(user: User): void {
    this.currentUser = user;
    this.notifyAuthStateChange();
  }

  /**
   * 添加认证状态监听器
   */
  addAuthStateListener(listener: (isLoggedIn: boolean, user: User | null) => void): void {
    this.authStateListeners.push(listener);
  }

  /**
   * 移除认证状态监听器
   */
  removeAuthStateListener(listener: (isLoggedIn: boolean, user: User | null) => void): void {
    const index = this.authStateListeners.indexOf(listener);
    if (index > -1) {
      this.authStateListeners.splice(index, 1);
    }
  }

  /**
   * 通知认证状态变化
   */
  private notifyAuthStateChange(): void {
    for (const listener of this.authStateListeners) {
      try {
        listener(this.isLoggedIn, this.currentUser);
      } catch (error) {
        console.error('Auth state listener error:', error);
      }
    }
  }
} 
import { AuthManager } from '../../services/AuthManager';
import { LoginRequest, RegisterRequest } from '../../models/User';
import router from '@ohos.router';

@Entry
@Component
struct AuthPage {
  @State currentTab: number = 0; // 0: 登录, 1: 注册
  @State loginField: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State email: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  
  private authManager = AuthManager.getInstance();

  aboutToAppear(): void {
    // 检查是否已经登录
    if (this.authManager.getIsLoggedIn()) {
      router.replaceUrl({
        url: 'pages/Index'
      });
    }
  }

  build() {
    Column() {
      // 背景渐变
      Column() {
        // Logo区域
        this.buildLogoSection()
        
        // 登录/注册表单
        this.buildAuthForm()
        
        // 切换按钮
        this.buildSwitchSection()
      }
      .width('100%')
      .height('100%')
      .padding({ left: 24, right: 24, top: 60, bottom: 40 })
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#7028e4', 0.0], ['#e5b2ca', 1.0]]
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildLogoSection() {
    Column() {
      // Logo图标
      Image($r('app.media.logo2'))
        .width(120)
        .height(120)
        .borderRadius(60)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.3)',
          offsetX: 0,
          offsetY: 8
        })
        .margin({ bottom: 24 })
      
      // 应用标题
      Text('BiuBiu 音乐')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ bottom: 8 })
        .fontFamily('serif')
      
      Text('大音希声 大象无形')
        .fontSize(16)
        .fontColor('rgba(255, 255, 255, 0.4)')
        .margin({ bottom: 48 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildAuthForm() {
    Column() {
      // 标签切换
      Row() {
        Text('登录')
          .fontSize(18)
          .fontWeight(this.currentTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === 0 ? '#FFFFFF' : 'rgba(255, 255, 255, 0.6)')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .borderRadius(20)
          .backgroundColor(this.currentTab === 0 ? 'rgba(255, 255, 255, 0.2)' : 'transparent')
          .onClick(() => {
            this.currentTab = 0;
            this.errorMessage = '';
          })
        
        Text('注册')
          .fontSize(18)
          .fontWeight(this.currentTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === 1 ? '#FFFFFF' : 'rgba(255, 255, 255, 0.6)')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .borderRadius(20)
          .backgroundColor(this.currentTab === 1 ? 'rgba(255, 255, 255, 0.2)' : 'transparent')
          .onClick(() => {
            this.currentTab = 1;
            this.errorMessage = '';
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 32 })

      // 表单内容
      Column() {
        // 用户名/邮箱输入框
        this.buildInputField(
          this.currentTab === 0 ? '用户名' : '用户名',
          this.loginField,
          (value: string) => { this.loginField = value; }
        )

        // 密码输入框
        this.buildPasswordField(
          '密码',
          this.password,
          (value: string) => { this.password = value; }
        )

        // 注册时的确认密码
        if (this.currentTab === 1) {
          this.buildPasswordField(
            '确认密码',
            this.confirmPassword,
            (value: string) => { this.confirmPassword = value; }
          )

          // 邮箱输入框（注册时可选）
          this.buildInputField(
            '邮箱',
            this.email,
            (value: string) => { this.email = value; }
          )
        }

        // 错误信息
        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#FF6B6B')
            .margin({ top: 12 })
            .textAlign(TextAlign.Center)
        }

        // 操作按钮
        Button(this.currentTab === 0 ? '登录' : '注册')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('rgba(255, 255, 255, 0.9)')
          .fontColor('#701e5e')
          .borderRadius(24)
          .margin({ top: 24 })
          .enabled(!this.isLoading)
          .opacity(!this.isLoading ? 1.0 : 0.6)
          .onClick(() => {
            if (this.currentTab === 0) {
              this.handleLogin();
            } else {
              this.handleRegister();
            }
          })

        // 加载指示器
        if (this.isLoading) {
          LoadingProgress()
            .width(24)
            .height(24)
            .color('#FFFFFF')
            .margin({ top: 16 })
        }

      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .borderRadius(16)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .backdropBlur(10)
    }
    .width('100%')
  }

  @Builder
  buildInputField(placeholder: string, value: string, onChange: (value: string) => void) {
    TextInput({ placeholder: placeholder, text: value })
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .placeholderColor('rgba(255, 255, 255, 0.6)')
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .borderRadius(12)
      .border({
        width: 1,
        color: 'rgba(255, 255, 255, 0.3)'
      })
      .margin({ bottom: 8, top: 8 })
      .onChange((value: string) => {
        onChange(value);
        // 只有当用户开始新的输入时才清空错误信息
        if (this.errorMessage && value.trim() !== '') {
          this.errorMessage = '';
        }
      })
  }

  @Builder
  buildPasswordField(placeholder: string, value: string, onChange: (value: string) => void) {
    TextInput({ placeholder: placeholder, text: value })
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .placeholderColor('rgba(255, 255, 255, 0.6)')
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .borderRadius(12)
      .border({
        width: 1,
        color: 'rgba(255, 255, 255, 0.3)'
      })
      .type(InputType.Password)
      .margin({ bottom: 8, top: 8 })
      .onChange((value: string) => {
        onChange(value);
        // 只有当用户开始新的输入时才清空错误信息
        if (this.errorMessage && value.trim() !== '') {
          this.errorMessage = '';
        }
      })
  }

  @Builder
  buildSwitchSection() {
    Row() {
      Text(this.currentTab === 0 ? '还没有账号？' : '已有账号？')
        .fontSize(14)
        .fontColor('rgba(255, 255, 255, 0.8)')
        .margin({ right: 8 })
      
      Text(this.currentTab === 0 ? '立即注册' : '立即登录')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .decoration({ type: TextDecorationType.Underline })
        .onClick(() => {
          this.currentTab = this.currentTab === 0 ? 1 : 0;
          this.errorMessage = '';
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 32 })
  }



  // 清空表单
  private clearForm(): void {
    this.loginField = '';
    this.password = '';
    this.confirmPassword = '';
    this.email = '';
    this.errorMessage = '';
  }

  // 处理登录
  private async handleLogin(): Promise<void> {
    if (this.isLoading) return;
    
    // 基本验证
    if (!this.loginField.trim()) {
      this.errorMessage = '请输入用户名或邮箱';
      return;
    }
    
    if (!this.password.trim()) {
      this.errorMessage = '请输入密码';
      return;
    }
    
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      const loginData: LoginRequest = {
        loginField: this.loginField.trim(),
        password: this.password
      };
      
      await this.authManager.login(loginData);
      
      // 登录成功，跳转到主页
      router.replaceUrl({
        url: 'pages/Index'
      });
      
    } catch (error) {
      console.error('Login error:', error);
      const errorMessage = error instanceof Error ? error.message : '登录失败';
      
      // 根据错误类型提供不同的提示
      if (errorMessage.includes('请求频率过高')) {
        this.errorMessage = '请求过于频繁，请等待30秒后重试';
      } else if (errorMessage.includes('HTTP 401') || errorMessage.includes('HTTP 403')) {
        this.errorMessage = '用户名或密码错误，请重新输入';
      } else if (errorMessage.includes('网络')) {
        this.errorMessage = '网络连接失败，请检查网络设置';
      } else {
        this.errorMessage = '登录失败，请稍后重试';
      }
    } finally {
      this.isLoading = false;
    }
  }

  // 处理注册
  private async handleRegister(): Promise<void> {
    if (this.isLoading) return;
    
    // 注册验证
    if (!this.loginField.trim()) {
      this.errorMessage = '请输入用户名';
      return;
    }
    
    if (!this.password.trim()) {
      this.errorMessage = '请输入密码';
      return;
    }
    
    if (this.password.length < 6) {
      this.errorMessage = '密码长度至少需要6位';
      return;
    }
    
    if (!this.confirmPassword.trim()) {
      this.errorMessage = '请确认密码';
      return;
    }
    
    if (this.password !== this.confirmPassword) {
      this.errorMessage = '两次输入的密码不一致';
      return;
    }
    
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      const registerData: RegisterRequest = {
        username: this.loginField.trim(),
        password: this.password,
        email: this.email.trim() || undefined
      };
      
      await this.authManager.register(registerData);
      
      // 注册成功，跳转到主页
      router.replaceUrl({
        url: 'pages/Index'
      });
      
    } catch (error) {
      console.error('Register error:', error);
      this.errorMessage = '注册失败，用户名可能已存在';
    } finally {
      this.isLoading = false;
    }
  }
} 
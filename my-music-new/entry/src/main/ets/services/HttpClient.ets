import { http } from '@kit.NetworkKit';
import { ApiResponse } from '../models/Common';
import fs from '@ohos.file.fs';
import * as util from '@ohos.util';

/**
 * HTTP请求配置
 */
export interface RequestConfig {
  url: string;
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  params?: Record<string, string | number>;
  data?: Object;
  headers?: Record<string, string>;
  timeout?: number;
}

/**
 * HTTP客户端类
 */
export class HttpClient {
  private static instance: HttpClient;
  private baseURL: string = 'http://10.0.2.2:3000/api/v1';
  private defaultHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  private token: string = '';

  private constructor() {
    // 在构造函数中输出当前配置
    console.log('HttpClient: 初始化, baseURL:', this.baseURL);
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  /**
   * 设置基础URL
   */
  public setBaseURL(url: string): void {
    this.baseURL = url;
  }

  /**
   * 设置认证令牌
   */
  public setToken(token: string): void {
    this.token = token;
    if (token) {
      this.defaultHeaders['Authorization'] = `Bearer ${token}`;
    } else {
      // 创建新的headers对象，不包含Authorization
      const newHeaders: Record<string, string> = {};
      const keys = Object.keys(this.defaultHeaders);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        if (key !== 'Authorization') {
          newHeaders[key] = this.defaultHeaders[key];
        }
      }
      this.defaultHeaders = newHeaders;
    }
  }

  /**
   * 获取当前令牌
   */
  public getToken(): string {
    return this.token;
  }

  /**
   * 发送请求
   */
  public async request<T = Object>(config: RequestConfig): Promise<ApiResponse<T>> {
    try {
      const url = this.buildURL(config.url, config.params);
      console.log('HttpClient: 发送请求 -', config.method || 'GET', url);

      // 合并headers
      const headers: Record<string, string> = {};
      const defaultKeys = Object.keys(this.defaultHeaders);
      for (let i = 0; i < defaultKeys.length; i++) {
        const key = defaultKeys[i];
        headers[key] = this.defaultHeaders[key];
      }
      if (config.headers) {
        const configKeys = Object.keys(config.headers);
        for (let i = 0; i < configKeys.length; i++) {
          const key = configKeys[i];
          headers[key] = config.headers[key];
        }
      }

      const httpRequest = http.createHttp();

      const requestOptions: http.HttpRequestOptions = {
        method: (config.method || 'GET') as http.RequestMethod,
        header: headers,
        extraData: config.data ? JSON.stringify(config.data) : undefined,
        expectDataType: http.HttpDataType.OBJECT,
        usingCache: false,
        priority: 1,
        connectTimeout: config.timeout || 10000,
        readTimeout: config.timeout || 10000
      };

      console.log('HttpClient: 请求选项:', JSON.stringify(requestOptions));
      const response = await httpRequest.request(url, requestOptions);
      console.log('HttpClient: 收到响应 - 状态码:', response.responseCode);
      console.log('HttpClient: 响应数据类型:', typeof response.result);

      if (response.responseCode === 200) {
        let data: Object;

        if (typeof response.result === 'object') {
          data = response.result as Object;
        } else {
          try {
            data = JSON.parse(response.result as string) as Object;
          } catch (parseError) {
            console.error('HttpClient: JSON解析失败:', parseError);
            const error = parseError as Error;
            throw new Error(`JSON Parse Error: ${error.message}`);
          }
        }

        console.log('HttpClient: 解析后的数据:', JSON.stringify(data));
        return data as ApiResponse<T>;
      } else {
        const error = new Error(`HTTP ${response.responseCode}: ${response.result}`);
        console.error('HttpClient: HTTP错误:', error.message);
        throw error;
      }
    } catch (error) {
      console.error('HttpClient: 请求异常:', error);
      console.error('HttpClient: 错误详情:', JSON.stringify(error));
      const errorMessage = (error as Error).message || 'HTTP request failed';
      const httpError = new Error(errorMessage);
      throw httpError;
    }
  }

  /**
   * GET请求
   */
  public async get<T = Object>(url: string, params?: Record<string, string | number>, headers?: Record<string, string>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: 'GET',
      params,
      headers
    });
  }

  /**
   * POST请求
   */
  public async post<T = Object>(url: string, data?: Object, headers?: Record<string, string>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: 'POST',
      data,
      headers
    });
  }

  /**
   * PUT请求
   */
  public async put<T = Object>(url: string, data?: Object, headers?: Record<string, string>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: 'PUT',
      data,
      headers
    });
  }

  /**
   * DELETE请求
   */
  public async delete<T = Object>(url: string, headers?: Record<string, string>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: 'DELETE',
      headers
    });
  }

  /**
   * 文件上传方法
   */
  public async uploadFile<T = Object>(url: string, fileUri: string, fieldName: string = 'avatar', headers?: Record<string, string>): Promise<ApiResponse<T>> {
    try {
      const fullURL = url.startsWith('http') ? url : `${this.baseURL}${url}`;
      console.log('HttpClient: 开始文件上传 - POST', fullURL);
      console.log('HttpClient: 文件路径:', fileUri);

      // 获取文件信息并读取文件内容
      let fileContent: ArrayBuffer;
      let fileName: string;
      try {
        const file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
        const stat = fs.statSync(file.fd);
        const fileSize: number = stat.size;
        
        // 动态分配缓冲区大小
        const buffer = new ArrayBuffer(fileSize);
        const readSize: number = fs.readSync(file.fd, buffer);
        fileContent = buffer.slice(0, readSize);
        fs.closeSync(file);
        
        // 提取文件名
        fileName = fileUri.split('/').pop() || 'upload.jpg';
        
        console.log('HttpClient: 文件读取成功，文件名:', fileName, '大小:', readSize);
      } catch (fileError) {
        console.error('HttpClient: 文件读取失败:', fileError);
        const error = fileError as Error;
        throw new Error(`文件读取失败: ${error.message}`);
      }

      // 构建multipart/form-data格式的数据
      const boundary = '----WebKitFormBoundary' + Date.now().toString(16);
      
      // 手动构建multipart数据 - 使用类的私有方法
      const boundaryStr: string = `--${boundary}\r\n`;
      const dispositionStr: string = `Content-Disposition: form-data; name="${fieldName}"; filename="${fileName}"\r\n`;
      const contentTypeStr: string = `Content-Type: application/octet-stream\r\n\r\n`;
      const endBoundaryStr: string = `\r\n--${boundary}--\r\n`;
      
      const boundaryBytes: Uint8Array = this.stringToUint8Array(boundaryStr);
      const dispositionBytes: Uint8Array = this.stringToUint8Array(dispositionStr);
      const contentTypeBytes: Uint8Array = this.stringToUint8Array(contentTypeStr);
      const endBoundaryBytes: Uint8Array = this.stringToUint8Array(endBoundaryStr);
      
      // 计算总长度
      const totalLength = boundaryBytes.byteLength + dispositionBytes.byteLength + 
                         contentTypeBytes.byteLength + fileContent.byteLength + endBoundaryBytes.byteLength;
      
      // 创建合并后的缓冲区
      const combinedBuffer = new ArrayBuffer(totalLength);
      const combinedView = new Uint8Array(combinedBuffer);
      
      // 按顺序复制数据
      let offset: number = 0;
      combinedView.set(boundaryBytes, offset);
      offset += boundaryBytes.byteLength;
      
      combinedView.set(dispositionBytes, offset);
      offset += dispositionBytes.byteLength;
      
      combinedView.set(contentTypeBytes, offset);
      offset += contentTypeBytes.byteLength;
      
      combinedView.set(new Uint8Array(fileContent), offset);
      offset += fileContent.byteLength;
      
      combinedView.set(endBoundaryBytes, offset);

      // 合并headers
      const uploadHeaders: Record<string, string> = {
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        'Content-Length': combinedBuffer.byteLength.toString()
      };
      
      if (this.token) {
        uploadHeaders['Authorization'] = `Bearer ${this.token}`;
      }
      
      if (headers) {
        const headerKeys = Object.keys(headers);
        for (let i = 0; i < headerKeys.length; i++) {
          const key = headerKeys[i];
          uploadHeaders[key] = headers[key];
        }
      }

      const httpRequest = http.createHttp();

      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: uploadHeaders,
        extraData: combinedBuffer,
        expectDataType: http.HttpDataType.OBJECT,
        usingCache: false,
        priority: 1,
        connectTimeout: 30000, // 文件上传需要更长的超时时间
        readTimeout: 30000
      };

      console.log('HttpClient: 文件上传请求选项:', JSON.stringify({
        method: requestOptions.method,
        header: uploadHeaders,
        extraDataSize: `${combinedBuffer.byteLength} bytes`,
        expectDataType: requestOptions.expectDataType
      }));

      const response = await httpRequest.request(fullURL, requestOptions);
      console.log('HttpClient: 文件上传响应 - 状态码:', response.responseCode);

      // 销毁请求对象
      httpRequest.destroy();

      if (response.responseCode === 200) {
        let data: Object;

        if (typeof response.result === 'object') {
          data = response.result as Object;
        } else {
          try {
            data = JSON.parse(response.result as string) as Object;
          } catch (parseError) {
            console.error('HttpClient: JSON解析失败:', parseError);
            const error = parseError as Error;
            throw new Error(`JSON Parse Error: ${error.message}`);
          }
        }

        console.log('HttpClient: 文件上传成功，解析后的数据:', JSON.stringify(data));
        return data as ApiResponse<T>;
      } else {
        const error = new Error(`HTTP ${response.responseCode}: ${response.result}`);
        console.error('HttpClient: 文件上传HTTP错误:', error.message);
        throw error;
      }
    } catch (error) {
      console.error('HttpClient: 文件上传异常:', error);
      console.error('HttpClient: 错误详情:', JSON.stringify(error));
      const errorMessage = (error as Error).message || 'File upload failed';
      const uploadError = new Error(errorMessage);
      throw uploadError;
    }
  }

  /**
   * 字符串转字节数组的辅助方法
   */
  private stringToUint8Array(str: string): Uint8Array {
    const bytes: number[] = [];
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      if (char < 128) {
        bytes.push(char);
      } else {
        // 简单的UTF-8编码处理
        bytes.push(0xC0 | (char >> 6));
        bytes.push(0x80 | (char & 0x3F));
      }
    }
    return new Uint8Array(bytes);
  }

  /**
   * 构建完整URL
   */
  private buildURL(url: string, params?: Record<string, string | number>): string {
    let fullURL = url.startsWith('http') ? url : `${this.baseURL}${url}`;

    if (params) {
      // 手动构建查询参数字符串
      const queryParts: string[] = [];
      const keys = Object.keys(params);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const value = params[key];
        if (value !== undefined && value !== null) {
          queryParts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
        }
      }

      if (queryParts.length > 0) {
        const queryString = queryParts.join('&');
        fullURL += (fullURL.includes('?') ? '&' : '?') + queryString;
      }
    }

    return fullURL;
  }
} 
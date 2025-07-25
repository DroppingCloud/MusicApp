 /**
 * 时间工具类
 */
export class TimeUtils {
  
  /**
   * 将秒数转换为 mm:ss 格式
   * @param seconds 秒数
   * @returns 格式化的时间字符串
   */
  static formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = Math.floor(seconds % 60);
    return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  /**
   * 将 mm:ss 格式转换为秒数
   * @param timeString 时间字符串
   * @returns 秒数
   */
  static parseTime(timeString: string): number {
    const parts = timeString.split(':');
    if (parts.length === 2) {
      const minutes = parseInt(parts[0]) || 0;
      const seconds = parseInt(parts[1]) || 0;
      return minutes * 60 + seconds;
    }
    return 0;
  }

  /**
   * 格式化日期
   * @param date 日期对象或时间戳
   * @returns 格式化的日期字符串
   */
  static formatDate(date: Date | number): string {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}
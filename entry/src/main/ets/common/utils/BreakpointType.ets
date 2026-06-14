/**
 * 断点类型工具类
 * 用于根据当前断点返回不同的值，简化响应式布局代码
 */
export type BreakpointValueType = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

/**
 * 断点值映射接口
 */
export interface BreakpointValueOption<T> {
  xs?: T;
  sm?: T;
  md?: T;
  lg?: T;
  xl?: T;
}

/**
 * 断点值工具类
 * 根据当前断点返回对应的值
 * 
 * 使用示例：
 * // 根据断点返回不同的字体大小
 * const fontSize = new BreakpointValue<number>({
 *   xs: 14,
 *   sm: 16,
 *   md: 18,
 *   lg: 20,
 *   xl: 22
 * }).getValue(this.currentBreakpoint);
 */
export class BreakpointValue<T> {
  private options: BreakpointValueOption<T>;
  
  constructor(options: BreakpointValueOption<T>) {
    this.options = options;
  }
  
  /**
   * 根据当前断点获取对应的值
   * @param breakpoint 当前断点值
   * @returns 对应的值，如果没有配置则返回 undefined
   */
  getValue(breakpoint: BreakpointValueType): T | undefined {
    switch (breakpoint) {
      case 'xs':
        return this.options.xs;
      case 'sm':
        return this.options.sm;
      case 'md':
        return this.options.md;
      case 'lg':
        return this.options.lg;
      case 'xl':
        return this.options.xl;
      default:
        return undefined;
    }
  }
  
  /**
   * 获取值，如果未配置则返回默认值
   * @param breakpoint 当前断点值
   * @param defaultValue 默认值
   * @returns 对应的值或默认值
   */
  getValueOrDefault(breakpoint: BreakpointValueType, defaultValue: T): T {
    const value = this.getValue(breakpoint);
    return value !== undefined ? value : defaultValue;
  }
}

/**
 * 断点常量
 */
export class BreakpointConstants {
  // 断点名称
  static readonly BREAKPOINT_XS: BreakpointValueType = 'xs';
  static readonly BREAKPOINT_SM: BreakpointValueType = 'sm';
  static readonly BREAKPOINT_MD: BreakpointValueType = 'md';
  static readonly BREAKPOINT_LG: BreakpointValueType = 'lg';
  static readonly BREAKPOINT_XL: BreakpointValueType = 'xl';
  
  // 断点范围（vp）
  static readonly BREAKPOINT_XS_MAX = 320;
  static readonly BREAKPOINT_SM_MAX = 600;
  static readonly BREAKPOINT_MD_MAX = 840;
  static readonly BREAKPOINT_LG_MAX = 1440;
  
  // 栅格系统默认列数
  static readonly COLUMN_XS: number = 4;
  static readonly COLUMN_SM: number = 4;
  static readonly COLUMN_MD: number = 8;
  static readonly COLUMN_LG: number = 12;
  static readonly COLUMN_XL: number = 12;
  
  // 默认间距
  static readonly GUTTER_X: number = 12;
  static readonly GUTTER_Y: number = 12;
  
  // 默认边距
  static readonly MARGIN_SM: number = 16;
  static readonly MARGIN_MD: number = 24;
  static readonly MARGIN_LG: number = 32;
}

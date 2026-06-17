#!/usr/bin/env python3
"""
SVG to PNG converter for app icon
Requires: pip install cairosvg
"""

import os
try:
    import cairosvg
except ImportError:
    print("请先安装 cairosvg: pip install cairosvg")
    exit(1)

# 定义路径
svg_path = r"AppScope\resources\base\media\app_icon.svg"
png_path = r"AppScope\resources\base\media\app_icon.png"

# 转换SVG到PNG
try:
    cairosvg.svg2png(url=svg_path, write_to=png_path, output_width=256, output_height=256)
    print(f"✅ 图标转换成功: {png_path}")
except Exception as e:
    print(f"❌ 转换失败: {e}")

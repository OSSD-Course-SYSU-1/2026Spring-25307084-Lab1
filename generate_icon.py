#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generate app icon with clock, food, and four seasons elements
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os
except ImportError:
    print("请先安装 Pillow: pip install Pillow")
    exit(1)

# 创建256x256的图像
img = Image.new('RGB', (256, 256), 'white')
draw = ImageDraw.Draw(img)

# 定义颜色
spring_green = (76, 175, 80)    # 春绿
summer_red = (255, 87, 34)      # 夏红
autumn_yellow = (255, 193, 7)   # 秋黄
winter_blue = (33, 150, 243)    # 冬蓝
white = (255, 255, 255)
black = (51, 51, 51)
gray = (102, 102, 102)
brown = (139, 69, 19)

# 绘制渐变背景（简化版，使用纯色渐变）
for i in range(120):
    # 从春绿渐变到冬蓝
    r = int(spring_green[0] + (winter_blue[0] - spring_green[0]) * i / 120)
    g = int(spring_green[1] + (winter_blue[1] - spring_green[1]) * i / 120)
    b = int(spring_green[2] + (winter_blue[2] - spring_green[2]) * i / 120)
    draw.ellipse([8 + i, 8 + i, 248 - i, 248 - i], fill=(r, g, b))

# 绘制白色表盘
draw.ellipse([48, 48, 208, 208], fill=white)
draw.ellipse([53, 53, 203, 203], outline=black, width=2)

# 绘制时钟刻度
draw.line([(128, 58), (128, 68)], fill=black, width=2)   # 12点
draw.line([(198, 128), (188, 128)], fill=black, width=2) # 3点
draw.line([(128, 198), (128, 188)], fill=black, width=2) # 6点
draw.line([(58, 128), (68, 128)], fill=black, width=2)   # 9点

# 绘制时针
draw.line([(128, 128), (128, 85)], fill=black, width=4)

# 绘制分针
draw.line([(128, 128), (165, 95)], fill=gray, width=3)

# 绘制中心点
draw.ellipse([122, 122, 140, 140], fill=summer_red)

# 绘制食物元素 - 饭碗
draw.ellipse([60, 65, 100, 81], fill=white, outline=black, width=2)

# 绘制筷子
draw.rectangle([170, 70, 174, 100], fill=brown)
draw.rectangle([178, 70, 182, 100], fill=brown)

# 尝试加载中文字体
try:
    # Windows系统字体路径
    font_paths = [
        r"C:\Windows\Fonts\msyh.ttc",  # 微软雅黑
        r"C:\Windows\Fonts\simhei.ttf",  # 黑体
        r"C:\Windows\Fonts\simsun.ttc",  # 宋体
    ]
    
    font = None
    for font_path in font_paths:
        if os.path.exists(font_path):
            font = ImageFont.truetype(font_path, 12)
            break
    
    if font is None:
        # 如果找不到中文字体，使用默认字体
        font = ImageFont.load_default()
except Exception as e:
    print(f"字体加载失败: {e}")
    font = ImageFont.load_default()

# 绘制四季标识
# 春
draw.ellipse([55, 175, 75, 195], fill=spring_green)
draw.text((60, 180), "春", fill=white, font=font)

# 夏
draw.ellipse([80, 185, 100, 205], fill=summer_red)
draw.text((85, 190), "夏", fill=white, font=font)

# 秋
draw.ellipse([105, 175, 125, 195], fill=autumn_yellow)
draw.text((110, 180), "秋", fill=white, font=font)

# 冬
draw.ellipse([130, 185, 150, 205], fill=winter_blue)
draw.text((135, 190), "冬", fill=white, font=font)

# 保存图像
output_path = r"AppScope\resources\base\media\app_icon.png"
img.save(output_path, 'PNG', quality=95)

print(f"✅ 应用图标生成成功: {output_path}")
print("图标包含以下元素:")
print("  - 时钟指针 (时间管理)")
print("  - 食物元素 (饭碗、筷子)")
print("  - 四季标识 (春夏秋冬)")
print("\n应用名称已修改为: 一日三餐")
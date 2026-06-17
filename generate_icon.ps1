# PowerShell script to generate app icon
# UTF-8 BOM encoding
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Drawing

# 创建256x256的位图
$bmp = New-Object System.Drawing.Bitmap(256, 256)
$graphics = [System.Drawing.Graphics]::FromImage($bmp)

# 设置高质量渲染
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# 定义颜色
$springGreen = [System.Drawing.Color]::FromArgb(255, 76, 175, 80)
$summerRed = [System.Drawing.Color]::FromArgb(255, 255, 87, 34)
$autumnYellow = [System.Drawing.Color]::FromArgb(255, 255, 193, 7)
$winterBlue = [System.Drawing.Color]::FromArgb(255, 33, 150, 243)
$white = [System.Drawing.Color]::White
$black = [System.Drawing.Color]::FromArgb(255, 51, 51, 51)

# 创建渐变背景
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point(256, 256)),
    $springGreen,
    $winterBlue
)

# 绘制背景圆
$graphics.FillEllipse($brush, 8, 8, 240, 240)

# 绘制白色表盘
$whiteBrush = New-Object System.Drawing.SolidBrush($white)
$graphics.FillEllipse($whiteBrush, 48, 48, 160, 160)

# 绘制表盘边框
$blackPen = New-Object System.Drawing.Pen($black, 2)
$graphics.DrawEllipse($blackPen, 53, 53, 150, 150)

# 绘制时钟刻度
$graphics.DrawLine($blackPen, 128, 58, 128, 68)
$graphics.DrawLine($blackPen, 198, 128, 188, 128)
$graphics.DrawLine($blackPen, 128, 198, 128, 188)
$graphics.DrawLine($blackPen, 58, 128, 68, 128)

# 绘制时针
$hourPen = New-Object System.Drawing.Pen($black, 4)
$hourPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$hourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawLine($hourPen, 128, 128, 128, 85)

# 绘制分针
$minutePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 102, 102, 102), 3)
$minutePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$minutePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawLine($minutePen, 128, 128, 165, 95)

# 绘制中心点
$centerBrush = New-Object System.Drawing.SolidBrush($summerRed)
$graphics.FillEllipse($centerBrush, 122, 122, 12, 12)

# 绘制食物元素 - 饭碗
$bowlBrush = New-Object System.Drawing.SolidBrush($white)
$graphics.FillEllipse($bowlBrush, 60, 65, 40, 16)
$graphics.DrawEllipse($blackPen, 60, 65, 40, 16)

# 绘制筷子
$chopstickBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 139, 69, 19))
$graphics.FillRectangle($chopstickBrush, 170, 70, 4, 30)
$graphics.FillRectangle($chopstickBrush, 178, 70, 4, 30)

# 绘制四季标识
$font = New-Object System.Drawing.Font("Microsoft YaHei", 10, [System.Drawing.FontStyle]::Bold)
$stringFormat = New-Object System.Drawing.StringFormat
$stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
$stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

# 春
$springBrush = New-Object System.Drawing.SolidBrush($springGreen)
$graphics.FillEllipse($springBrush, 55, 175, 20, 20)
$textRect = New-Object System.Drawing.RectangleF(55, 175, 20, 20)
$graphics.DrawString("春", $font, $white, $textRect, $stringFormat)

# 夏
$summerBrush = New-Object System.Drawing.SolidBrush($summerRed)
$graphics.FillEllipse($summerBrush, 80, 185, 20, 20)
$textRect = New-Object System.Drawing.RectangleF(80, 185, 20, 20)
$graphics.DrawString("夏", $font, $white, $textRect, $stringFormat)

# 秋
$autumnBrush = New-Object System.Drawing.SolidBrush($autumnYellow)
$graphics.FillEllipse($autumnBrush, 105, 175, 20, 20)
$textRect = New-Object System.Drawing.RectangleF(105, 175, 20, 20)
$graphics.DrawString("秋", $font, $white, $textRect, $stringFormat)

# 冬
$winterBrush = New-Object System.Drawing.SolidBrush($winterBlue)
$graphics.FillEllipse($winterBrush, 130, 185, 20, 20)
$textRect = New-Object System.Drawing.RectangleF(130, 185, 20, 20)
$graphics.DrawString("冬", $font, $white, $textRect, $stringFormat)

# 保存PNG文件
$outputPath = "AppScope\resources\base\media\app_icon.png"
$bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

# 清理资源
$graphics.Dispose()
$bmp.Dispose()
$brush.Dispose()
$whiteBrush.Dispose()
$blackPen.Dispose()
$hourPen.Dispose()
$minutePen.Dispose()
$centerBrush.Dispose()
$bowlBrush.Dispose()
$chopstickBrush.Dispose()
$springBrush.Dispose()
$summerBrush.Dispose()
$autumnBrush.Dispose()
$winterBrush.Dispose()
$font.Dispose()
$stringFormat.Dispose()

Write-Host "应用图标生成成功: $outputPath"
Write-Host "图标包含以下元素:"
Write-Host "  - 时钟指针 (时间管理)"
Write-Host "  - 食物元素 (饭碗、筷子)"
Write-Host "  - 四季标识 (春夏秋冬)"
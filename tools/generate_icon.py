"""
يولّد أيقونة مبدئية بسيطة لتطبيق Alive:
- خلفية سوداء نقية + شكل يوجا هندسي بسيط باللون البرتقالي
- يُنتج:
  1) assets/icon/icon.png        -> الأيقونة الكاملة (خلفية سوداء + الشكل) لأيقونة عادية
  2) assets/icon/icon_foreground.png -> الشكل فقط بخلفية شفافة (لأيقونة أندرويد التكيفية)
لاحقاً يمكن استبدال هذين الملفين بتصميم احترافي دون تغيير أي كود آخر.
"""
from PIL import Image, ImageDraw
import math

SIZE = 1024
ORANGE = (255, 107, 0, 255)  # #FF6B00
BLACK = (0, 0, 0, 255)

def draw_yoga_figure(draw, cx, cy, scale, color):
    # رأس
    head_r = 60 * scale
    draw.ellipse([cx - head_r, cy - 260*scale - head_r, cx + head_r, cy - 260*scale + head_r], fill=color)

    # جسم (مثلث ناعم يمثل الجلوس المتربع - وضعية اللوتس)
    body_top = (cx, cy - 210*scale)
    body_left = (cx - 210*scale, cy + 160*scale)
    body_right = (cx + 210*scale, cy + 160*scale)
    draw.polygon([body_top, body_left, body_right], fill=color)

    # قاعدة دائرية ناعمة أسفل الجسم (توحي بالوسادة/التمركز)
    draw.ellipse([cx - 230*scale, cy + 130*scale, cx + 230*scale, cy + 190*scale], fill=color)

    # فراغ أسود لتشكيل الذراعين (قطع دائرتين من الجسم لإظهار انحناء الذراعين على الركبتين)
    arm_r = 95 * scale
    draw.ellipse([cx - 300*scale, cy + 10*scale, cx - 300*scale + arm_r*2, cy + 10*scale + arm_r*2], fill=BLACK)
    draw.ellipse([cx + 300*scale - arm_r*2, cy + 10*scale, cx + 300*scale, cy + 10*scale + arm_r*2], fill=BLACK)


def make_icon(path, with_background: bool):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if with_background:
        draw.rectangle([0, 0, SIZE, SIZE], fill=BLACK)
        # حلقة رفيعة واحدة خلف الشكل (بدون تدرج شفافية لتفادي مشاكل الدمج)
        r = 340
        ring_w = 10
        draw.ellipse(
            [SIZE/2 - r, SIZE/2 - r, SIZE/2 + r, SIZE/2 + r],
            outline=ORANGE, width=ring_w,
        )

    draw_yoga_figure(draw, SIZE/2, SIZE/2 + 40, 1.0, ORANGE)

    img.save(path)


if __name__ == "__main__":
    make_icon("assets/icon/icon.png", with_background=True)
    make_icon("assets/icon/icon_foreground.png", with_background=False)
    print("تم إنشاء الأيقونات في assets/icon/")

"""
يعدّل ملف AndroidManifest.xml بعد إنشاء مجلد android عبر flutter create:
- يضيف صلاحية الإنترنت (لازمة للنسخ الاحتياطي عبر GitHub API)
- يضبط اسم التطبيق الظاهر إلى Alive
"""
import re
import os

manifest_path = "android/app/src/main/AndroidManifest.xml"

if not os.path.exists(manifest_path):
    print(f"لم يتم العثور على {manifest_path}، تجاوز التعديل.")
    raise SystemExit(0)

with open(manifest_path, "r", encoding="utf-8") as f:
    content = f.read()

# إضافة صلاحية الإنترنت إذا لم تكن موجودة
if "android.permission.INTERNET" not in content:
    content = content.replace(
        "<manifest",
        '<manifest',
        1,
    )
    # أدرج السطر بعد وسم <manifest ...>
    content = re.sub(
        r"(<manifest[^>]*>)",
        r'\1\n    <uses-permission android:name="android.permission.INTERNET" />',
        content,
        count=1,
    )

# ضبط اسم التطبيق
content = re.sub(r'android:label="[^"]*"', 'android:label="Alive"', content)

with open(manifest_path, "w", encoding="utf-8") as f:
    f.write(content)

print("تم تعديل AndroidManifest.xml بنجاح.")

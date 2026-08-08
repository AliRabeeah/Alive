# Alive 🧘‍♂️

تطبيق يوجا شخصي لهاتف الأندرويد، مبني بـ Flutter، يولّد جلسات يوجا ديناميكية بحسب المدة والمستوى والتركيز، مع إرشاد صوتي وسجل تقدم ونسخ احتياطي تلقائي إلى GitHub.

تصميم وتطوير: **Ali Halim**

## المميزات
- توليد جلسات عشوائية ذكية حسب المدة/المستوى/التركيز
- إرشاد صوتي (نطق عربي) لكل وضعية
- مؤقت دائري متحرك + اهتزاز عند الانتقال بين الوضعيات
- عمل كامل بدون إنترنت (offline-first)
- سجل جلسات وإحصائيات (عدد الجلسات، إجمالي الدقائق)
- نسخ احتياطي تلقائي للبيانات بعد كل جلسة إلى مستودع GitHub خاص بك
- ثيم أسود نقي + لون برتقالي قابل للتخصيص بالكامل، ووضع فاتح/داكن

## البناء عبر GitHub Actions
لا تحتاج تثبيت Flutter محلياً. فقط:

1. ادفع (push) الكود إلى فرع `main`، أو شغّل الـ workflow يدوياً من تبويب **Actions** على GitHub (`workflow_dispatch`).
2. الـ workflow (`.github/workflows/build.yml`) يقوم تلقائياً بـ:
   - تجهيز مجلد `android` (عبر `flutter create`)
   - تعديل الصلاحيات واسم التطبيق
   - توليد أيقونة التطبيق من `assets/icon/icon.png`
   - بناء وتوقيع ملف APK
   - إرفاقه كـ Artifact ونشره ضمن GitHub Release

## توقيع APK (اختياري لكن موصى به)
لتوقيع التطبيق بمفتاحك الخاص (بدلاً من التوقيع الافتراضي)، أضف الأسرار التالية في **Settings → Secrets and variables → Actions**:

| الاسم | الوصف |
|---|---|
| `ALIVE_KEYSTORE_BASE64` | ملف الـ keystore (`.jks`) مُرمّز بصيغة base64 |
| `ALIVE_KEYSTORE_PASSWORD` | كلمة سر الـ keystore |
| `ALIVE_KEY_ALIAS` | اسم الـ alias |
| `ALIVE_KEY_PASSWORD` | كلمة سر المفتاح |

لإنشاء keystore جديد محلياً (مرة واحدة فقط):
```bash
keytool -genkey -v -keystore alive_release.keystore -alias alive -keyalg RSA -keysize 2048 -validity 10000
base64 -w0 alive_release.keystore > keystore_base64.txt
```
انسخ محتوى `keystore_base64.txt` وضعه في السر `ALIVE_KEYSTORE_BASE64`.

> إذا لم تُضف هذه الأسرار، سيبني الـ workflow نسخة موقّعة تلقائياً بمفتاح Flutter الافتراضي (تعمل تماماً للاستخدام الشخصي، لكن لن تصلح لتحديثات مستقبلية إذا تغيّر مفتاح debug على راناتك).

## النسخ الاحتياطي عبر GitHub
من داخل التطبيق (الإعدادات ← النسخ الاحتياطي):
1. أنشئ [Personal Access Token](https://github.com/settings/tokens) بصلاحية `repo` فقط.
2. أدخله في حقل GitHub Token.
3. أدخل اسم المستودع بصيغة `owner/repo` (يُفضّل مستودع خاص منفصل للنسخ الاحتياطية).
4. فعّل "نسخ احتياطي تلقائي بعد كل جلسة"، أو اضغط "نسخ احتياطي الآن" يدوياً.

يتم رفع ملف `backup/alive_backup.json` يحتوي السجل والإحصائيات والمفضلة والإعدادات الأخيرة.

## هيكلة المشروع
```
lib/
  models/       # نماذج البيانات (Pose, Session)
  data/         # قراءة بيانات الوضعيات من poses.json
  services/     # التوليد، التخزين، TTS، النسخ الاحتياطي
  theme/        # الثيم ومزوّدات الحالة
  screens/      # شاشات التطبيق
assets/
  data/poses.json
  icon/         # أيقونة التطبيق (قابلة للاستبدال لاحقاً)
tools/          # سكربتات مساعدة تُستخدم أثناء البناء في GitHub Actions
.github/workflows/build.yml
```

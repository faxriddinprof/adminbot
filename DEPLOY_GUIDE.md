# Admin Bot - PythonAnywhere Deploy Guide

## Loyihani tayyorlash

Botingiz tayyor! Endi uni pythonanywhere.com ga deploy qilish uchun quyidagi qadamlarni bajaring.

## 1. Local da test qilish

```bash
# Virtual environment yarating (ixtiyoriy)
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# yoki
venv\Scripts\activate  # Windows

# Kutubxonalarni o'rnating
pip install -r requirements.txt

# Botni ishga tushiring
python manage.py runbot
```

## 2. PythonAnywhere ga Deploy qilish

### 2.1. Account yaratish
1. [pythonanywhere.com](https://www.pythonanywhere.com) ga o'ting
2. Free account yarating (Beginner hisobi yetarli)

### 2.2. Bash Console ochish
1. Dashboard > Consoles > Bash
2. Console ochilgandan keyin quyidagi buyruqlarni bajaring:

```bash
# Loyihani yuklash (Git orqali yoki file upload orqali)
# Agar Git orqali:
git clone <sizning-repo-url> adminbot
cd adminbot

# Yoki file upload orqali Files tabdan fayllarni yuklang

# Virtual environment yaratish
mkvirtualenv adminbot --python=python3.10

# Kutubxonalarni o'rnatish
pip install -r requirements.txt

# Django migrations
python manage.py migrate
```

### 2.3. Environment Variables sozlash
1. PythonAnywhere Dashboard > Files
2. `.bashrc` faylini oching (home directory da)
3. Quyidagilarni qo'shing:

```bash
export BOT_TOKEN="8007539860:AAETb1mofF-yVX4_J_2tS81Ffba4FnbXMTk"
export ADMIN_ID="272996039"
```

4. Console da yangi environment o'qish uchun:
```bash
source ~/.bashrc
```

### 2.4. Always-on Task yaratish
1. Dashboard > Tasks
2. "Create a new always-on task" tugmasini bosing
3. Command qatoriga quyidagini kiriting:

```bash
cd /home/yourusername/adminbot && source ~/.virtualenvs/adminbot/bin/activate && python manage.py runbot
```

**Eslatma:** `yourusername` o'rniga o'zingizning PythonAnywhere username ni yozing!

4. "Create" tugmasini bosing

## 3. Tekshirish

1. Telegram da botingizga `/start` yuboring
2. Istalgan xabar yuboring
3. Admin ID ga xabar kelganini tekshiring

## 4. Muammolarni hal qilish

### Bot ishlamayotgan bo'lsa:
1. Dashboard > Tasks > "Always-on task" log fayllarini tekshiring
2. Console da qo'lda ishga tushiring:
```bash
cd ~/adminbot
source ~/.virtualenvs/adminbot/bin/activate
python manage.py runbot
```
3. Error loglarini o'qing

### Environment variables ishlamasa:
Console da tekshiring:
```bash
echo $BOT_TOKEN
echo $ADMIN_ID
```

Agar bo'sh bo'lsa, `.bashrc` ni qayta tekshiring va `source ~/.bashrc` bajaring.

## 5. Bot kodlari

Bot [src/apps/bot/management/commands/runbot.py](src/apps/bot/management/commands/runbot.py) da joylashgan.

### Bot ishlash tartibi:
- `/start` - Kutish xabari
- `/ping` - Test uchun "pong" javob beradi
- Har qanday boshqa xabar - Admin ID ga yuboriladi

## 6. Important Notes

- **Free account:** 1ta always-on task bepul
- Bot to'xtatish: Dashboard > Tasks > Delete always-on task
- Bot qayta ishga tushirish: Task ni o'chirib qaytadan yarating
- Logs: Task page da log fayllar ko'rinadi

## 7. Token xavfsizligi

⚠️ **MUHIM:** Hozirgi kodda token ochiq yozilgan! Production uchun:

1. Token ni koddan olib tashlang
2. Faqat environment variable ishlatilsin
3. `.bashrc` da saqlang yoki PythonAnywhere Environment variables sectiondan sozlang

[deploy_pythonanywhere.sh](deploy_pythonanywhere.sh) faylida ham ko'rsatmalar bor.

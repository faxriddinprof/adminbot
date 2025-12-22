# 🤖 Admin Bot

Oddiy Telegram bot - foydalanuvchilardan murojaatlar qabul qilib, administratorga yuboradi.

## 📋 Tavsif

Bu bot foydalanuvchilardan xabarlar qabul qilib, ularni belgilangan admin ID ga yuboradi. Django framework asosida qurilgan va pythonanywhere.com ga deploy qilish uchun tayyor.

## ✨ Xususiyatlar

- ✅ `/start` - Kutish xabari
- ✅ `/ping` - Bot ishlayotganini tekshirish
- ✅ Har qanday xabar - Admin ga yuboriladi
- ✅ Loglar `logs/bot.log` fayliga yoziladi
- ✅ `.env` fayl orqali sozlanadi

## 🚀 O'rnatish

### 1. Repository ni clone qilish

```bash
git clone https://github.com/faxriddinprof/adminbot.git
cd adminbot
```

### 2. Virtual environment yaratish

```bash
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# yoki
venv\Scripts\activate  # Windows
```

### 3. Kutubxonalarni o'rnatish

```bash
pip install -r requirements.txt
```

### 4. Environment variables sozlash

`.env` fayl yarating va quyidagilarni kiriting:

```env
BOT_TOKEN=sizning_bot_tokeningiz
ADMIN_ID=sizning_telegram_id
```

**Bot token olish:**
1. [@BotFather](https://t.me/BotFather) ga boring
2. `/newbot` buyrug'ini yuboring
3. Bot nomini va username ni kiriting
4. Token ni nusxalang

**Telegram ID olish:**
1. [@userinfobot](https://t.me/userinfobot) ga boring
2. `/start` bosing
3. ID ni nusxalang

### 5. Django sozlamalari

```bash
python manage.py migrate
```

### 6. Botni ishga tushirish

```bash
python manage.py runbot
```

## 📁 Loyiha tuzilishi

```
adminbot/
├── config/              # Django sozlamalari
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── src/
│   └── apps/
│       └── bot/         # Bot ilovasi
│           ├── management/
│           │   └── commands/
│           │       └── runbot.py  # Bot kodi
│           └── apps.py
├── logs/                # Log fayllar
│   └── bot.log
├── .env                 # Environment variables (yaratiladi)
├── .env.example         # Environment namunasi
├── requirements.txt     # Python kutubxonalari
├── manage.py
├── DEPLOY_GUIDE.md     # PythonAnywhere deploy guide
└── README.md
```

## 🌐 PythonAnywhere ga Deploy qilish

Batafsil ko'rsatmalar: [DEPLOY_GUIDE.md](DEPLOY_GUIDE.md)

### Qisqacha:

1. [pythonanywhere.com](https://www.pythonanywhere.com) da account yarating
2. Bash console ochib, repository ni clone qiling
3. Virtual environment yaratib, kutubxonalarni o'rnating
4. `.bashrc` faylida environment variables sozlang
5. Always-on task yaratib, botni ishga tushiring

```bash
# PythonAnywhere da
cd /home/yourusername/adminbot
source ~/.virtualenvs/adminbot/bin/activate
python manage.py runbot
```

## 🔧 Sozlamalar

### Environment Variables

| Variable | Tavsif | Misol |
|----------|--------|-------|
| `BOT_TOKEN` | Telegram bot token | `123456:ABC-DEF...` |
| `ADMIN_ID` | Admin Telegram ID | `272996039` |

### Log fayllar

Bot barcha faoliyatini `logs/bot.log` fayliga yozadi:
- Bot ishga tushganda
- Xabarlar qabul qilinganda
- Xatoliklar yuz berganda

## 📝 Bot buyruqlari

- `/start` - Botni boshlash, kutish xabari
- `/ping` - Bot ishlayotganini tekshirish (javob: "pong")
- Har qanday matn - Admin ga yuboriladi

## 🛠️ Development

### Yangi xususiyat qo'shish

Bot kodi [src/apps/bot/management/commands/runbot.py](src/apps/bot/management/commands/runbot.py) da joylashgan.

```python
# Yangi handler qo'shish
async def my_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Mening javobim")

# Command qo'shish
app.add_handler(CommandHandler("mycommand", my_command))
```

### Loglarni ko'rish

```bash
tail -f logs/bot.log
```

## 🐛 Muammolarni hal qilish

### Bot ishlamayotgan bo'lsa

1. Token va Admin ID to'g'riligini tekshiring
2. Environment variables yuklangannini tekshiring
3. Log faylni ko'ring: `cat logs/bot.log`

### "Module not found" xatosi

```bash
pip install -r requirements.txt
```

### Environment variables ishlamasa

```bash
# .env fayl mavjudligini tekshiring
cat .env

# Qo'lda sozlash (test uchun)
export BOT_TOKEN="your_token"
export ADMIN_ID="your_id"
```

## 📦 Kerakli kutubxonalar

- Django 4.2+
- python-telegram-bot 20.0+
- python-dotenv 1.0+

## 📄 Litsenziya

MIT License

## 👨‍💻 Muallif

[@faxriddinprof](https://github.com/faxriddinprof)

## 🤝 Hissa qo'shish

Pull request'lar qabul qilinadi! Katta o'zgarishlar uchun avval issue oching.

## 📞 Aloqa

Savol yoki takliflar uchun issue oching yoki Pull Request yuboring.

---

⭐ Agar loyiha foydali bo'lsa, star bering!

.PHONY: help install venv setup migrate migrations superuser run server bot cleanup clean test freeze deploy-check logs

# Default target
help:
	@echo "🤖 Admin Bot - Makefile Commands"
	@echo ""
	@echo "📦 O'rnatish va sozlash:"
	@echo "  make install      - Kutubxonalarni o'rnatish"
	@echo "  make venv         - Virtual environment yaratish"
	@echo "  make setup        - To'liq o'rnatish (venv + install + migrate)"
	@echo ""
	@echo "🗄️  Database:"
	@echo "  make migrations   - Migratsiya fayllarini yaratish"
	@echo "  make migrate      - Migratsiyalarni qo'llash"
	@echo "  make superuser    - Admin foydalanuvchi yaratish"
	@echo ""
	@echo "🚀 Ishga tushirish:"
	@echo "  make run          - Telegram botni ishga tushirish"
	@echo "  make server       - Django serverni ishga tushirish"
	@echo "  make bot          - Botni background rejimda ishga tushirish"
	@echo ""
	@echo "🧹 Tozalash:"
	@echo "  make cleanup      - 7 kundan eski xabarlarni o'chirish"
	@echo "  make clean        - Cache va venv fayllarni tozalash"
	@echo ""
	@echo "📊 Monitoring:"
	@echo "  make logs         - Bot loglarini ko'rish (tail -f)"
	@echo "  make stats        - Database statistikasi"
	@echo ""
	@echo "🔧 Development:"
	@echo "  make freeze       - requirements.txt ni yangilash"
	@echo "  make test         - Testlarni ishga tushirish"
	@echo "  make shell        - Django shell ochish"
	@echo ""
	@echo "📤 Deploy:"
	@echo "  make deploy-check - Deploy uchun tekshirish"

# Virtual environment yaratish
venv:
	@echo "📦 Virtual environment yaratilmoqda..."
	python3 -m venv venv
	@echo "✅ Virtual environment yaratildi!"
	@echo "Aktivlashtirish: source venv/bin/activate"

# Kutubxonalarni o'rnatish
install:
	@echo "📚 Kutubxonalar o'rnatilmoqda..."
	pip install --upgrade pip
	pip install -r requirements.txt
	@echo "✅ Kutubxonalar o'rnatildi!"

# To'liq o'rnatish
setup: venv
	@echo "🔧 Loyiha sozlanmoqda..."
	@bash -c "source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt"
	@bash -c "source venv/bin/activate && python manage.py migrate"
	@echo "✅ Loyiha muvaffaqiyatli sozlandi!"
	@echo ""
	@echo "📝 Keyingi qadamlar:"
	@echo "1. .env faylini yarating va sozlang"
	@echo "2. make superuser - admin yaratish"
	@echo "3. make run - botni ishga tushirish"

# Migratsiya fayllarini yaratish
migrations:
	@echo "📝 Migratsiya fayllar yaratilmoqda..."
	python manage.py makemigrations
	@echo "✅ Migratsiyalar yaratildi!"

# Migratsiyalarni qo'llash
migrate:
	@echo "🗄️  Database migratsiya qilinmoqda..."
	python manage.py migrate
	@echo "✅ Migratsiya muvaffaqiyatli!"

# Superuser yaratish
superuser:
	@echo "👤 Admin foydalanuvchi yaratish..."
	python manage.py createsuperuser

# Telegram botni ishga tushirish
run:
	@echo "🤖 Telegram bot ishga tushirilmoqda..."
	@echo "⚠️  To'xtatish uchun: Ctrl+C"
	python manage.py runbot

# Django serverni ishga tushirish
server:
	@echo "🌐 Django server ishga tushirilmoqda..."
	@echo "Admin panel: http://127.0.0.1:8000/admin"
	@echo "⚠️  To'xtatish uchun: Ctrl+C"
	python manage.py runserver

# Botni background rejimda ishga tushirish
bot:
	@echo "🤖 Bot background rejimda ishga tushirilmoqda..."
	nohup python manage.py runbot > logs/bot_output.log 2>&1 &
	@echo "✅ Bot ishga tushdi!"
	@echo "📊 Loglarni ko'rish: make logs"
	@echo "⚠️  To'xtatish: pkill -f 'python manage.py runbot'"

# 7 kundan eski xabarlarni o'chirish
cleanup:
	@echo "🗑️  Eski xabarlar tozalanmoqda..."
	python manage.py cleanup_messages
	@echo "✅ Tozalash tugadi!"

# Cache va venv fayllarni tozalash
clean:
	@echo "🧹 Tozalanmoqda..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache 2>/dev/null || true
	rm -rf htmlcov 2>/dev/null || true
	rm -rf .coverage 2>/dev/null || true
	@echo "✅ Tozalandi!"

# Bot loglarini ko'rish
logs:
	@echo "📊 Bot loglari (Ctrl+C - to'xtatish)..."
	@echo ""
	tail -f logs/bot.log

# Database statistikasi
stats:
	@echo "📊 Database statistikasi..."
	@python -c "import django; import os; os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings'); django.setup(); from src.apps.bot.models import Message, BotStatistics; print(f'\n📨 Jami xabarlar: {Message.objects.count()}'); print(f'👥 Jami foydalanuvchilar: {Message.objects.values(\"telegram_user_id\").distinct().count()}'); from django.utils import timezone; from datetime import timedelta; print(f'📅 Bugungi xabarlar: {Message.objects.filter(created_at__date=timezone.now().date()).count()}'); week_ago = timezone.now() - timedelta(days=7); print(f'📆 Bu haftalik: {Message.objects.filter(created_at__gte=week_ago).count()}\n')"

# requirements.txt ni yangilash
freeze:
	@echo "📝 requirements.txt yangilanmoqda..."
	pip freeze > requirements.txt
	@echo "✅ requirements.txt yangilandi!"

# Testlarni ishga tushirish
test:
	@echo "🧪 Testlar ishga tushirilmoqda..."
	python manage.py test

# Django shell
shell:
	@echo "🐚 Django shell ochilmoqda..."
	python manage.py shell

# Deploy uchun tekshirish
deploy-check:
	@echo "🔍 Deploy uchun tekshirish..."
	@echo ""
	@echo "1️⃣  .env fayli:"
	@if [ -f .env ]; then echo "  ✅ .env mavjud"; else echo "  ❌ .env topilmadi!"; fi
	@echo ""
	@echo "2️⃣  requirements.txt:"
	@if [ -f requirements.txt ]; then echo "  ✅ requirements.txt mavjud"; else echo "  ❌ requirements.txt topilmadi!"; fi
	@echo ""
	@echo "3️⃣  Database migratison:"
	@python manage.py showmigrations --list | grep -q "\[ \]" && echo "  ⚠️  Qo'llanmagan migratsiyalar bor!" || echo "  ✅ Barcha migratsiyalar qo'llangan"
	@echo ""
	@echo "4️⃣  Environment variables:"
	@if [ ! -z "$$BOT_TOKEN" ]; then echo "  ✅ BOT_TOKEN sozlangan"; else echo "  ⚠️  BOT_TOKEN sozlanmagan"; fi
	@if [ ! -z "$$ADMIN_ID" ]; then echo "  ✅ ADMIN_ID sozlangan"; else echo "  ⚠️  ADMIN_ID sozlanmagan"; fi
	@echo ""
	@echo "📋 To'liq deploy guide: DEPLOY_GUIDE.md"

# Database backup
backup:
	@echo "💾 Database backup yaratilmoqda..."
	@mkdir -p backups
	@python manage.py dumpdata --indent 2 > backups/backup_$$(date +%Y%m%d_%H%M%S).json
	@echo "✅ Backup yaratildi: backups/"

# Database restore
restore:
	@echo "♻️  Database restore qilinmoqda..."
	@if [ -z "$(FILE)" ]; then echo "❌ FILE parametri kerak: make restore FILE=backup.json"; exit 1; fi
	python manage.py loaddata $(FILE)
	@echo "✅ Database restore qilindi!"

# Yangi app yaratish
app:
	@if [ -z "$(NAME)" ]; then echo "❌ NAME parametri kerak: make app NAME=myapp"; exit 1; fi
	@echo "📦 Yangi app yaratilmoqda: $(NAME)"
	python manage.py startapp $(NAME) src/apps/$(NAME)
	@echo "✅ App yaratildi: src/apps/$(NAME)"
	@echo "⚠️  settings.py ga qo'shishni unutmang: 'src.apps.$(NAME)'"

.PHONY: help install venv setup migrate migrations superuser run server bot cleanup clean test freeze deploy-check logs start-all stop-all status git-commit git-push git-pull git-status git-clean

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
	@echo "  make start-all    - Bot + Django serverni birga ishga tushirish ⭐"
	@echo "  make stop-all     - Barcha processlarni to'xtatish"
	@echo "  make run          - Telegram botni ishga tushirish"
	@echo "  make server       - Django serverni ishga tushirish"
	@echo "  make bot          - Botni background rejimda ishga tushirish"
	@echo ""
	@echo "🧹 Tozalash:"
	@echo "  make cleanup      - 7 kundan eski xabarlarni o'chirish"
	@echo "  make clean        - Cache va venv fayllarni tozalash"
	@echo "  make git-clean    - Git cache tozalash va .gitignore qo'llash"
	@echo ""
	@echo "📊 Monitoring:"
	@echo "  make logs         - Bot loglarini ko'rish (tail -f)"
	@echo "  make stats        - Database statistikasi"
	@echo "  make status       - Servislar holati"
	@echo ""
	@echo "🔧 Development:"
	@echo "  make freeze       - requirements.txt ni yangilash"
	@echo "  make test         - Testlarni ishga tushirish"
	@echo "  make shell        - Django shell ochish"
	@echo ""
	@echo "📤 Deploy:"
	@echo "  make deploy-check - Deploy uchun tekshirish"
	@echo ""
	@echo "🔀 Git:"
	@echo "  make git-status   - Git status ko'rsatish"
	@echo "  make git-commit   - O'zgarishlarni commit qilish (MSG='message')"
	@echo "  make git-push     - O'zgarishlarni GitHub'ga push qilish"
	@echo "  make git-pull     - GitHub'dan o'zgarishlarni olish"
	@echo "  make git-clean    - Git cache tozalash va ignored fayllarni o'chirish"

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
	@bash -c "source venv/bin/activate && python manage.py makemigrations"
	@echo "✅ Migratsiyalar yaratildi!"

# Migratsiyalarni qo'llash
migrate:
	@echo "🗄️  Database migratsiya qilinmoqda..."
	@bash -c "source venv/bin/activate && python manage.py migrate"
	@echo "✅ Migratsiya muvaffaqiyatli!"

# Superuser yaratish
superuser:
	@echo "👤 Admin foydalanuvchi yaratish..."
	@bash -c "source venv/bin/activate && python manage.py createsuperuser"

# Telegram botni ishga tushirish
run:
	@echo "🤖 Telegram bot ishga tushirilmoqda..."
	@echo "⚠️  To'xtatish uchun: Ctrl+C"
	@bash -c "source venv/bin/activate && python manage.py runbot"

# Django serverni ishga tushirish
server:
	@echo "🌐 Django server ishga tushirilmoqda..."
	@echo "Admin panel: http://127.0.0.1:8000/admin"
	@echo "⚠️  To'xtatish uchun: Ctrl+C"
	@bash -c "source venv/bin/activate && python manage.py runserver"

# Bot va serverni birga ishga tushirish
start-all:
	@echo "🚀 Bot va Django server birga ishga tushirilmoqda..."
	@echo ""
	@mkdir -p logs
	@bash -c "source venv/bin/activate && nohup python manage.py runbot > logs/bot_output.log 2>&1 & echo \$$! > logs/bot.pid"
	@sleep 2
	@bash -c "source venv/bin/activate && nohup python manage.py runserver > logs/server_output.log 2>&1 & echo \$$! > logs/server.pid"
	@sleep 2
	@echo "✅ Barcha servislar ishga tushdi!"
	@echo ""
	@echo "📊 Status:"
	@if [ -f logs/bot.pid ]; then echo "  🤖 Telegram Bot: Ishlamoqda (PID: $$(cat logs/bot.pid))"; fi
	@if [ -f logs/server.pid ]; then echo "  🌐 Django Server: http://127.0.0.1:8000/admin (PID: $$(cat logs/server.pid))"; fi
	@echo ""
	@echo "📝 Loglar:"
	@echo "  Bot: tail -f logs/bot_output.log"
	@echo "  Server: tail -f logs/server_output.log"
	@echo ""
	@echo "⚠️  To'xtatish: make stop-all"

# Barcha servislarni to'xtatish
stop-all:
	@echo "🛑 Barcha servislar to'xtatilmoqda..."
	@if [ -f logs/bot.pid ]; then \
		kill $$(cat logs/bot.pid) 2>/dev/null || true; \
		rm -f logs/bot.pid; \
		echo "  ✅ Telegram bot to'xtatildi (PID file)"; \
	fi
	@if [ -f logs/server.pid ]; then \
		kill $$(cat logs/server.pid) 2>/dev/null || true; \
		rm -f logs/server.pid; \
		echo "  ✅ Django server to'xtatildi (PID file)"; \
	fi
	@pkill -f "python.*manage.py runbot" 2>/dev/null && echo "  ✅ Bot processlar to'xtatildi" || true
	@pkill -f "python.*manage.py runserver" 2>/dev/null && echo "  ✅ Server processlar to'xtatildi" || true
	@sleep 1
	@if pgrep -f "manage.py" > /dev/null; then \
		echo "  ⚠️  Ba'zi processlar hali ishlayabdi, majburlab to'xtatilmoqda..."; \
		pkill -9 -f "manage.py" 2>/dev/null || true; \
	fi
	@echo "✅ Barcha servislar to'xtatildi!"

# Botni background rejimda ishga tushirish
bot:
	@echo "🤖 Bot background rejimda ishga tushirilmoqda..."
	@bash -c "source venv/bin/activate && nohup python manage.py runbot > logs/bot_output.log 2>&1 &"
	@echo "✅ Bot ishga tushdi!"
	@echo "📊 Loglarni ko'rish: make logs"
	@echo "⚠️  To'xtatish: pkill -f 'python manage.py runbot'"

# 7 kundan eski xabarlarni o'chirish
cleanup:
	@echo "🗑️  Eski xabarlar tozalanmoqda..."
	@bash -c "source venv/bin/activate && python manage.py cleanup_messages"
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

# Servislar statusini tekshirish
status:
	@bash check_status.sh

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
	@bash -c "source venv/bin/activate && python manage.py test"

# Django shell
shell:
	@echo "🐚 Django shell ochilmoqda..."
	@bash -c "source venv/bin/activate && python manage.py shell"

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
	@bash -c "source venv/bin/activate && python manage.py showmigrations --list | grep -q '\[ \]' && echo '  ⚠️  Qo'llanmagan migratsiyalar bor!' || echo '  ✅ Barcha migratsiyalar qo'llangan'"
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
	@bash -c "source venv/bin/activate && python manage.py dumpdata --indent 2 > backups/backup_$$(date +%Y%m%d_%H%M%S).json"
	@echo "✅ Backup yaratildi: backups/"

# Database restore
restore:
	@echo "♻️  Database restore qilinmoqda..."
	@if [ -z "$(FILE)" ]; then echo "❌ FILE parametri kerak: make restore FILE=backup.json"; exit 1; fi
	@bash -c "source venv/bin/activate && python manage.py loaddata $(FILE)"
	@echo "✅ Database restore qilindi!"

# ==================== GIT OPERATIONS ====================

# Git status
git-status:
	@echo "📊 Git status:"
	@echo ""
	@git status

# Git commit
git-commit:
	@if [ -z "$(MSG)" ]; then \
		echo "❌ Commit message kerak!"; \
		echo "Misol: make git-commit MSG='Yangi funksiya qo'shildi'"; \
		exit 1; \
	fi
	@echo "💾 O'zgarishlar commit qilinmoqda..."
	@git add .
	@git commit -m "$(MSG)"
	@echo "✅ Commit qilindi!"
	@echo ""
	@echo "📤 GitHub'ga yuborish uchun: make git-push"

# Git push
git-push:
	@echo "📤 O'zgarishlar GitHub'ga yuborilmoqda..."
	@git push origin $$(git branch --show-current)
	@echo "✅ GitHub'ga yuborildi!"
	@echo ""
	@echo "🔗 Repository: https://github.com/faxriddinprof/adminbot"

# Git pull
git-pull:
	@echo "📥 GitHub'dan o'zgarishlar olinmoqda..."
	@git pull origin $$(git branch --show-current)
	@echo "✅ O'zgarishlar olindi!"

# Git cache tozalash va .gitignore qo'llash
git-clean:
	@echo "🧹 Git cache tozalanmoqda..."
	@echo ""
	@echo "⚠️  Bu buyruq barcha .gitignore dagi fayllarni git trackingdan olib tashlaydi"
	@echo "⚠️  Lokal fayllar o'chirilmaydi, faqat git tracking to'xtatiladi"
	@echo ""
	@read -p "Davom etishni xohlaysizmi? (y/n): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "🗑️  Git cache tozalanmoqda..."; \
		git rm -r --cached . 2>/dev/null || true; \
		echo "📋 Barcha fayllar qayta qo'shilmoqda..."; \
		git add .; \
		echo "✅ Git cache tozalandi!"; \
		echo ""; \
		echo "📊 O'zgarishlar:"; \
		git status --short; \
		echo ""; \
		echo "💾 Commit qilish: make git-commit MSG='Git cache tozalandi'"; \
	else \
		echo "❌ Bekor qilindi"; \
	fi

# Tez commit + push (dev uchun)
git-save:
	@if [ -z "$(MSG)" ]; then \
		echo "❌ Commit message kerak!"; \
		echo "Misol: make git-save MSG='Tez saqlash'"; \
		exit 1; \
	fi
	@echo "💾 Saqlash va yuborish..."
	@git add .
	@git commit -m "$(MSG)"
	@git push origin $$(git branch --show-current)
	@echo "✅ Saqlandi va GitHub'ga yuborildi!"

# .gitignore dan ignored fayllarni ko'rsatish
git-ignored:
	@echo "📋 .gitignore'da ko'rsatilgan fayllar:"
	@echo ""
	@git status --ignored --short | grep '^!!'

# Yangi app yaratish
app:
	@if [ -z "$(NAME)" ]; then echo "❌ NAME parametri kerak: make app NAME=myapp"; exit 1; fi
	@echo "📦 Yangi app yaratilmoqda: $(NAME)"
	@bash -c "source venv/bin/activate && python manage.py startapp $(NAME) src/apps/$(NAME)"
	@echo "✅ App yaratildi: src/apps/$(NAME)"
	@echo "⚠️  settings.py ga qo'shishni unutmang: 'src.apps.$(NAME)'"

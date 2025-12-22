#!/bin/bash

# Servislar statusini tekshirish

echo "🔍 Servislar holati:"
echo ""

# Bot process
if pgrep -f "manage.py runbot" > /dev/null; then
    echo "✅ Telegram Bot: ISHLAMOQDA"
    echo "   PID: $(pgrep -f 'manage.py runbot')"
else
    echo "❌ Telegram Bot: TO'XTAGAN"
fi

# Server process
if pgrep -f "manage.py runserver" > /dev/null; then
    echo "✅ Django Server: ISHLAMOQDA"
    echo "   PID: $(pgrep -f 'manage.py runserver')"
    echo "   URL: http://127.0.0.1:8000/admin"
else
    echo "❌ Django Server: TO'XTAGAN"
fi

echo ""
echo "📊 Log fayllar:"
if [ -f logs/bot_output.log ]; then
    echo "   Bot: $(wc -l < logs/bot_output.log) qator"
fi
if [ -f logs/server_output.log ]; then
    echo "   Server: $(wc -l < logs/server_output.log) qator"
fi

echo ""
echo "💾 Database:"
python -c "import django; import os; os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings'); django.setup(); from src.apps.bot.models import Message; print(f'   Xabarlar: {Message.objects.count()} ta')" 2>/dev/null || echo "   Database ulanmadi"

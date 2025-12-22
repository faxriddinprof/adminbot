#!/bin/bash

# PythonAnywhere setup script
# Bu scriptni pythonanywhere.com da bash console orqali ishga tushiring

# 1. Repository clone qilish (agar kerak bo'lsa)
# git clone <your-repo-url> adminbot
# cd adminbot

# 2. Virtual environment yaratish
mkvirtualenv adminbot --python=python3.10

# 3. Kerakli kutubxonalarni o'rnatish
pip install -r requirements.txt

# 4. Environment variables sozlash
# PythonAnywhere web app settings da qo'shing:
# BOT_TOKEN=sizning_bot_tokeningiz
# ADMIN_ID=sizning_telegram_id

# 5. Django migratsiyalarini bajarish
python manage.py migrate

# 6. Bot ishga tushirish
# PythonAnywhere da "Always-on task" yarating va quyidagi buyruqni kiriting:
# cd /home/yourusername/adminbot && source ~/.virtualenvs/adminbot/bin/activate && python manage.py runbot

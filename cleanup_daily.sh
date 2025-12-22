#!/bin/bash

# Har kuni soat 03:00 da eski xabarlarni tozalash
# Crontab ga qo'shish: crontab -e
# 0 3 * * * /home/yourusername/adminbot/cleanup_daily.sh

cd /home/yourusername/adminbot
source ~/.virtualenvs/adminbot/bin/activate
python manage.py cleanup_messages

# Log faylga yozish
echo "$(date): Cleanup completed" >> logs/cleanup.log

import os
import logging
from pathlib import Path
from django.core.management.base import BaseCommand
from telegram import Update
from telegram.ext import (
    ApplicationBuilder,
    MessageHandler,
    CommandHandler,
    ContextTypes,
    filters,
)
from dotenv import load_dotenv
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from src.apps.bot.models import Message, BotStatistics

# .env faylini yuklash
load_dotenv()

# ЛОГИ
# Logs papkasini yaratish
BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent.parent.parent
LOG_DIR = BASE_DIR / "logs"
LOG_DIR.mkdir(exist_ok=True)
LOG_FILE = LOG_DIR / "bot.log"

# Logger sozlash - ham fayl ga, ham console ga
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Format
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

# File handler - fayl ga yozish
file_handler = logging.FileHandler(LOG_FILE, encoding='utf-8')
file_handler.setLevel(logging.INFO)
file_handler.setFormatter(formatter)

# Console handler - console ga chiqarish
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_handler.setFormatter(formatter)

# Handlerlarni qo'shish
logger.addHandler(file_handler)
logger.addHandler(console_handler)

# Токен и ADMIN_ID
TOKEN = os.environ.get("BOT_TOKEN", "8594034343:AAFUoNY6WrN4zIhEmJlc4rrsCCeyYuZ9IvA")
ADMIN_ID = int(os.environ.get("ADMIN_ID", "272996039"))

WELCOME_TEXT = "Salom, men - adminbot! Murojaatingizni qoldiring, administratorga yetkazaman."


# /start — только текст, НИКАКИХ КНОПОК
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(WELCOME_TEXT)


# Тест-пинг
async def ping(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("pong")


# Любое текстовое сообщение — пересылаем админу
async def forward_to_admin(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message or not update.message.text:
        return

    user = update.effective_user
    chat_id = update.effective_chat.id
    text = update.message.text

    # Xabarni databasega saqlash
    try:
        Message.objects.create(
            telegram_user_id=chat_id,
            username=user.username,
            first_name=user.first_name,
            last_name=user.last_name,
            message_text=text,
            is_sent_to_admin=True
        )
        logger.info(f"Xabar saqlandi: {user.username or user.first_name}")
    except Exception as e:
        logger.error(f"Xabarni saqlashda xato: {e}")

    admin_text = (
        f"Новое сообщение от @{user.username or user.first_name} "
        f"(id={chat_id}):\n\n{text}"
    )

    await context.bot.send_message(chat_id=ADMIN_ID, text=admin_text)
    await update.message.reply_text("Rahmat, murojaatingiz administratorga jo'natildi.")


class Command(BaseCommand):
    help = "Telegram bot ishga tushirish"

    def handle(self, *args, **options):
        app = ApplicationBuilder().token(TOKEN).build()

        app.add_handler(CommandHandler("start", start))
        app.add_handler(CommandHandler("ping", ping))

        # ВСЕ ТЕКСТОВЫЕ СООБЩЕНИЯ (кроме команд) → админу
        app.add_handler(
            MessageHandler(filters.TEXT & ~filters.COMMAND, forward_to_admin)
        )

        logger.info("Бот запущен...")
        self.stdout.write(self.style.SUCCESS("Bot muvaffaqiyatli ishga tushdi!"))
        
        app.run_polling()

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
from telegram.request import HTTPXRequest
from dotenv import load_dotenv
from asgiref.sync import sync_to_async

# .env faylini yuklash
load_dotenv()

# Django modellarini import qilish
from src.apps.bot.models import Message, BotStatistics
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
TOKEN = os.environ.get("BOT_TOKEN",)
ADMIN_ID = int(os.environ.get("ADMIN_ID",))

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

    # Xabarni databasega saqlash (async da)
    try:
        await sync_to_async(Message.objects.create)(
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

    async def post_init(self, application):
        """Bot ishga tushgandan keyin description sozlash"""
        description = """Kanaldan mamnunmisiz ? 
Sizga ko'proq qaysi mavzular qiziq ? 
yoki Savollaringiz bormi ?"""
        
        try:
            await application.bot.set_my_description(description=description)
            await application.bot.set_my_short_description(short_description="Fikr-mulohazalaringizni yuboring")
            logger.info("Bot description sozlandi")
        except Exception as e:
            logger.error(f"Description sozlashda xato: {e}")

    def handle(self, *args, **options):
        # Network sozlamalari - timeout oshirildi
        request = HTTPXRequest(
            connection_pool_size=8,
            connect_timeout=30.0,
            read_timeout=30.0,
            write_timeout=30.0,
            pool_timeout=30.0,
        )
        
        app = ApplicationBuilder().token(TOKEN).request(request).post_init(self.post_init).build()

        app.add_handler(CommandHandler("start", start))
        app.add_handler(CommandHandler("ping", ping))

        # ВСЕ ТЕКСТОВЫЕ СООБЩЕНИЯ (кроме команд) → админу
        app.add_handler(
            MessageHandler(filters.TEXT & ~filters.COMMAND, forward_to_admin)
        )

        logger.info("Бот запущен...")
        self.stdout.write(self.style.SUCCESS("Bot muvaffaqiyatli ishga tushdi!"))
        
        # Polling sozlamalari
        app.run_polling(
            allowed_updates=Update.ALL_TYPES,
            drop_pending_updates=True,
        )

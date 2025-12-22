import os
import logging
from django.core.management.base import BaseCommand
from telegram import Update
from telegram.ext import (
    ApplicationBuilder,
    MessageHandler,
    CommandHandler,
    ContextTypes,
    filters,
)

# ЛОГИ
logging.basicConfig(
    format="%(asctime)s - %(levelname)s - %(message)s", 
    level=logging.INFO
)
logger = logging.getLogger(__name__)

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

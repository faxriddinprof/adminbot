import os
import asyncio
from dotenv import load_dotenv
from telegram import Bot

# .env faylini yuklash
load_dotenv()

TOKEN = os.environ.get("BOT_TOKEN", "8594034343:AAFUoNY6WrN4zIhEmJlc4rrsCCeyYuZ9IvA")

async def clear_webhook():
    bot = Bot(token=TOKEN)
    
    # Webhook ni o'chirish
    await bot.delete_webhook(drop_pending_updates=True)
    print("✅ Webhook o'chirildi va pending updates tozalandi!")
    
    # Bot ma'lumotlarini olish
    me = await bot.get_me()
    print(f"🤖 Bot: @{me.username}")
    print(f"📝 Bot ID: {me.id}")
    print(f"✅ Bot tayyor!")

if __name__ == "__main__":
    asyncio.run(clear_webhook())

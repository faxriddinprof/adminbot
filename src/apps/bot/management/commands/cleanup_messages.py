from django.core.management.base import BaseCommand
from django.utils import timezone
from src.apps.bot.models import Message


class Command(BaseCommand):
    help = "7 kundan eski xabarlarni o'chirish (database cleanup)"

    def handle(self, *args, **options):
        self.stdout.write("🗑️  Eski xabarlarni tozalash boshlandi...")
        
        deleted_count = Message.cleanup_old_messages()
        
        if deleted_count > 0:
            self.stdout.write(
                self.style.SUCCESS(
                    f"✅ {deleted_count} ta eski xabar o'chirildi"
                )
            )
        else:
            self.stdout.write(
                self.style.WARNING("⚠️  O'chiriladigan eski xabar topilmadi")
            )
        
        # Qolgan xabarlar soni
        remaining = Message.objects.count()
        self.stdout.write(
            self.style.SUCCESS(
                f"📊 Databaseda {remaining} ta xabar qoldi"
            )
        )

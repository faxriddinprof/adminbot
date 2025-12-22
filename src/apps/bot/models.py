from django.db import models
from django.utils import timezone
from datetime import timedelta


class Message(models.Model):
    """Foydalanuvchilardan kelgan xabarlar"""
    
    telegram_user_id = models.BigIntegerField(verbose_name="Telegram User ID")
    username = models.CharField(max_length=255, blank=True, null=True, verbose_name="Username")
    first_name = models.CharField(max_length=255, blank=True, null=True, verbose_name="Ism")
    last_name = models.CharField(max_length=255, blank=True, null=True, verbose_name="Familiya")
    message_text = models.TextField(verbose_name="Xabar matni")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Yaratilgan vaqt")
    is_sent_to_admin = models.BooleanField(default=True, verbose_name="Adminga yuborildi")
    
    class Meta:
        verbose_name = "Xabar"
        verbose_name_plural = "Xabarlar"
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['-created_at']),
            models.Index(fields=['telegram_user_id']),
        ]
    
    def __str__(self):
        username = self.username or self.first_name or f"ID:{self.telegram_user_id}"
        return f"{username} - {self.created_at.strftime('%Y-%m-%d %H:%M')}"
    
    @classmethod
    def cleanup_old_messages(cls):
        """7 kundan eski xabarlarni o'chirish"""
        week_ago = timezone.now() - timedelta(days=7)
        deleted_count, _ = cls.objects.filter(created_at__lt=week_ago).delete()
        return deleted_count
    
    def get_age_days(self):
        """Xabar necha kun oldin yuborilganligi"""
        return (timezone.now() - self.created_at).days


class BotStatistics(models.Model):
    """Bot statistikasi - faqat 1 ta yozuv bo'ladi"""
    
    total_messages = models.IntegerField(default=0, verbose_name="Jami xabarlar")
    total_users = models.IntegerField(default=0, verbose_name="Jami foydalanuvchilar")
    last_message_date = models.DateTimeField(null=True, blank=True, verbose_name="Oxirgi xabar")
    bot_started_at = models.DateTimeField(auto_now_add=True, verbose_name="Bot ishga tushgan vaqt")
    updated_at = models.DateTimeField(auto_now=True, verbose_name="Yangilangan vaqt")
    
    class Meta:
        verbose_name = "Bot statistika"
        verbose_name_plural = "Bot statistika"
    
    def __str__(self):
        return f"Statistika - {self.total_messages} xabar, {self.total_users} foydalanuvchi"
    
    @classmethod
    def get_stats(cls):
        """Statistikani olish yoki yaratish"""
        stats, created = cls.objects.get_or_create(pk=1)
        return stats
    
    def update_stats(self):
        """Statistikani yangilash"""
        from django.db.models import Count
        self.total_messages = Message.objects.count()
        self.total_users = Message.objects.values('telegram_user_id').distinct().count()
        last_msg = Message.objects.first()
        if last_msg:
            self.last_message_date = last_msg.created_at
        self.save()


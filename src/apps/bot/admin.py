from django.contrib import admin
from django.utils.html import format_html
from django.db.models import Count
from .models import Message, BotStatistics


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['user_info', 'short_message', 'created_at', 'age_badge', 'is_sent_to_admin']
    list_filter = ['created_at', 'is_sent_to_admin']
    search_fields = ['telegram_user_id', 'username', 'first_name', 'message_text']
    readonly_fields = ['telegram_user_id', 'username', 'first_name', 'last_name', 
                      'message_text', 'created_at', 'is_sent_to_admin', 'age_display']
    date_hierarchy = 'created_at'
    
    def user_info(self, obj):
        """Foydalanuvchi ma'lumotlari"""
        name = obj.username or obj.first_name or f"ID: {obj.telegram_user_id}"
        return format_html(
            '<strong>{}</strong><br><small>ID: {}</small>',
            name, obj.telegram_user_id
        )
    user_info.short_description = "Foydalanuvchi"
    
    def short_message(self, obj):
        """Qisqa xabar matni"""
        if len(obj.message_text) > 50:
            return obj.message_text[:50] + "..."
        return obj.message_text
    short_message.short_description = "Xabar"
    
    def age_badge(self, obj):
        """Xabar yoshi rangli badge"""
        days = obj.get_age_days()
        if days == 0:
            color = '#28a745'  # green
            text = 'Bugun'
        elif days <= 3:
            color = '#ffc107'  # yellow
            text = f'{days} kun oldin'
        else:
            color = '#dc3545'  # red
            text = f'{days} kun oldin'
        return format_html(
            '<span style="background-color: {}; color: white; '
            'padding: 3px 10px; border-radius: 3px;">{}</span>',
            color, text
        )
    age_badge.short_description = "Yoshi"
    
    def age_display(self, obj):
        """Admin detail view uchun yosh"""
        return f"{obj.get_age_days()} kun oldin"
    age_display.short_description = "Xabar yoshi"
    
    def has_add_permission(self, request):
        """Yangi xabar qo'shish mumkin emas"""
        return False
    
    def has_change_permission(self, request, obj=None):
        """Xabarni o'zgartirish mumkin emas"""
        return False


@admin.register(BotStatistics)
class BotStatisticsAdmin(admin.ModelAdmin):
    list_display = ['total_messages', 'total_users', 'last_message_date', 'updated_at']
    readonly_fields = ['total_messages', 'total_users', 'last_message_date', 
                      'bot_started_at', 'updated_at', 'detailed_stats']
    
    def detailed_stats(self, obj):
        """Batafsil statistika"""
        from django.utils import timezone
        from datetime import timedelta
        
        # Bugungi xabarlar
        today = timezone.now().date()
        today_messages = Message.objects.filter(created_at__date=today).count()
        
        # Bu haftalik xabarlar
        week_ago = timezone.now() - timedelta(days=7)
        week_messages = Message.objects.filter(created_at__gte=week_ago).count()
        
        # Top foydalanuvchilar
        top_users = Message.objects.values('username', 'first_name', 'telegram_user_id') \
            .annotate(msg_count=Count('id')) \
            .order_by('-msg_count')[:5]
        
        html = f"""
        <div style="background: #f8f9fa; padding: 15px; border-radius: 5px;">
            <h3>📊 Statistika</h3>
            <p><strong>Bugungi xabarlar:</strong> {today_messages}</p>
            <p><strong>Bu haftalik xabarlar:</strong> {week_messages}</p>
            <hr>
            <h4>👥 Eng faol foydalanuvchilar:</h4>
            <ul>
        """
        
        for user in top_users:
            name = user['username'] or user['first_name'] or f"ID: {user['telegram_user_id']}"
            html += f"<li><strong>{name}</strong> - {user['msg_count']} xabar</li>"
        
        html += """
            </ul>
        </div>
        """
        
        return format_html(html)
    detailed_stats.short_description = "Batafsil statistika"
    
    def has_add_permission(self, request):
        """Yangi statistika qo'shish mumkin emas"""
        return False
    
    def has_delete_permission(self, request, obj=None):
        """Statistikani o'chirish mumkin emas"""
        return False
    
    def changelist_view(self, request, extra_context=None):
        """Statistikani avtomatik yangilash"""
        stats = BotStatistics.get_stats()
        stats.update_stats()
        return super().changelist_view(request, extra_context)


# Admin panel sarlavhasini o'zgartirish
admin.site.site_header = "Admin Bot Boshqaruv Paneli"
admin.site.site_title = "Admin Bot"
admin.site.index_title = "Boshqaruv paneli"


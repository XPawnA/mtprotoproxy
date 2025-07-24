# -----------------------------
# تنظیمات اصلی پروکسی MTProto
# هر گزینه با توضیح فارسی و مقدار پیش‌فرض آمده است
# برای فعال‌سازی هر گزینه، مقدار آن را تغییر دهید
# -----------------------------

PORT = 443  # پورت سرور پروکسی

# نام کاربر -> سکرت (۳۲ کاراکتر هگزادسیمال)
USERS = {
    "tg": "e4b7c2a1f9d8e6b5c3a2f1e0d9c8b7a6"
}

# حالت‌های مختلف پروکسی
MODES = {
    "classic": False,  # حالت کلاسیک (قابل شناسایی)
    "secure": False,   # حالت امن (سخت‌تر برای شناسایی)
    "tls": True        # حالت TLS (سخت‌ترین برای شناسایی)
}

# دامنه برای حالت TLS (کلاینت‌های بد به این دامنه هدایت می‌شوند)
TLS_DOMAIN = "www.google.com"

# تگ تبلیغاتی (از @MTProxybot دریافت کنید)
AD_TAG = "f80245e25d5d89fb6458bf1bfc697572"  # مقدار را با تگ دریافتی جایگزین کنید

# استفاده از پروکسی میانی (برای تبلیغات)
USE_MIDDLE_PROXY = False  # اگر AD_TAG ست شده باشد، True شود

# ترجیح استفاده از IPv6
PREFER_IPV6 = False

# فعال‌سازی حالت سریع (امنیت کمتر، سرعت بیشتر)
FAST_MODE = True

# فعال‌سازی پذیرش فقط با پروتکل پراکسی (برای nginx/haproxy)
PROXY_PROTOCOL = False

# فعال‌سازی ماسک کردن کلاینت‌های بد
MASK = True

# دامنه مقصد برای کلاینت‌های بد
MASK_HOST = TLS_DOMAIN

# پورت مقصد برای کلاینت‌های بد
MASK_PORT = 443

# دامنه خانگی (برای نمایش در لاگ)
MY_DOMAIN = False

# پراکسی بالادستی SOCKS5
SOCKS5_HOST = None
SOCKS5_PORT = None
SOCKS5_USER = None
SOCKS5_PASS = None

# محدودیت تعداد اتصال همزمان هر کاربر (نام کاربر -> تعداد)
USER_MAX_TCP_CONNS = {}

# تاریخ انقضای هر کاربر (نام کاربر -> رشته به فرمت روز/ماه/سال)
USER_EXPIRATIONS = {}

# سهمیه حجم داده هر کاربر (نام کاربر -> بایت)
USER_DATA_QUOTA = {}

# طول لیست بررسی تکرار handshake (برای جلوگیری از حمله)
REPLAY_CHECK_LEN = 65536

# نادیده گرفتن اختلاف ساعت کلاینت (کاهش امنیت)
IGNORE_TIME_SKEW = False

# تعداد آی‌پی‌های ذخیره شده کلاینت‌ها
CLIENT_IPS_LEN = 131072

# فاصله زمانی چاپ آمار (ثانیه)
STATS_PRINT_PERIOD = 600

# فاصله زمانی بروزرسانی اطلاعات پروکسی میانی (ثانیه)
PROXY_INFO_UPDATE_PERIOD = 24*60*60

# فاصله زمانی دریافت ساعت سرور تلگرام (ثانیه)
GET_TIME_PERIOD = 10*60

# فاصله زمانی دریافت طول گواهی ماسک‌هاست (ثانیه)
import random
GET_CERT_LEN_PERIOD = random.randrange(4*60*60, 6*60*60)

# سایز بافر سوکت به سمت کلاینت (عدد یا تاپل)
TO_CLT_BUFSIZE = (16384, 100, 131072)

# سایز بافر سوکت به سمت تلگرام
TO_TG_BUFSIZE = 65536

# مدت keepalive کلاینت (ثانیه)
CLIENT_KEEPALIVE = 10*60

# تایم‌اوت handshake کلاینت (ثانیه)
CLIENT_HANDSHAKE_TIMEOUT = random.randrange(5, 15)

# تایم‌اوت تایید کلاینت (ثانیه)
CLIENT_ACK_TIMEOUT = 5*60

# تایم‌اوت اتصال به تلگرام (ثانیه)
TG_CONNECT_TIMEOUT = 10

# آدرس گوش دادن سرور (IPv4)
LISTEN_ADDR_IPV4 = "0.0.0.0"

# آدرس گوش دادن سرور (IPv6)
LISTEN_ADDR_IPV6 = "::"

# آدرس یونیکس برای گوش دادن (در صورت نیاز)
LISTEN_UNIX_SOCK = ""

# پورت Prometheus برای مانیتورینگ
METRICS_PORT = None

# آدرس گوش دادن Prometheus (IPv4)
METRICS_LISTEN_ADDR_IPV4 = "0.0.0.0"

# آدرس گوش دادن Prometheus (IPv6)
METRICS_LISTEN_ADDR_IPV6 = None

# لیست آی‌پی‌های مجاز برای Prometheus
METRICS_WHITELIST = ["127.0.0.1", "::1"]

# فعال‌سازی خروجی لینک پروکسی در Prometheus
METRICS_EXPORT_LINKS = False

# پیشوند پیش‌فرض برای متریک‌ها
METRICS_PREFIX = "mtprotoproxy_"

# -----------------------------
# پایان تنظیمات
# -----------------------------

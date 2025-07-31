# پروکسی MTProto بهینه شده

پروکسی MTProto پرسرعت و بهینه شده با قابلیت‌های پیشرفته برای دسترسی آسان به تلگرام.

## ویژگی‌های کلیدی

✅ **پرسرعت**: بهینه‌سازی شده برای حداکثر سرعت و throughput  
✅ **امن**: استفاده از TLS و تکنیک‌های مخفی‌سازی پیشرفته  
✅ **قابل اعتماد**: مانیتورینگ و health check های خودکار  
✅ **آسان**: نصب و راه‌اندازی با یک کلیک  
✅ **مقیاس‌پذیر**: پشتیبانی از load balancing و چندین instance  
✅ **درآمدزا**: پشتیبانی کامل از AD_TAG برای کسب درآمد  

## نصب سریع

### پیش‌نیازها
```bash
# نصب Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# نصب Docker Compose
sudo apt install docker-compose-plugin
```

### راه‌اندازی
```bash
# کلون کردن پروژه
git clone <repository-url>
cd mtprotoproxy

# اجرای اسکریپت راه‌اندازی
chmod +x scripts/start.sh
./scripts/start.sh
```

## تنظیم AD_TAG برای درآمدزایی

### مرحله 1: دریافت AD_TAG
1. به بات [@MTProxybot](https://t.me/MTProxybot) در تلگرام مراجعه کنید
2. دستور `/newproxy` را ارسال کنید
3. AD_TAG دریافتی را کپی کنید

### مرحله 2: تنظیم در config.py
```python
# فایل config.py را ویرایش کنید
AD_TAG = "your-ad-tag-here"  # AD_TAG دریافتی را جایگزین کنید
USE_MIDDLE_PROXY = True      # حتماً True باشد
```

### مرحله 3: راه‌اندازی مجدد
```bash
docker-compose restart mtprotoproxy
```

## تنظیمات بهینه‌سازی

### تنظیمات سرعت
- `FAST_MODE = True`: حالت پرسرعت فعال
- `TO_CLT_BUFSIZE = (32768, 200, 262144)`: بافر بزرگ‌تر برای throughput بهتر
- `TO_TG_BUFSIZE = 131072`: بافر دو برابر شده
- `TCP_NODELAY = True`: کاهش latency

### تنظیمات امنیت
- `MODES["tls"] = True`: حالت TLS فعال
- `MASK = True`: مخفی‌سازی ترافیک
- `TLS_DOMAIN = "www.microsoft.com"`: دامنه مطمئن برای masking

### تنظیمات کاربران
- چندین کاربر برای توزیع بار
- محدودیت اتصال برای هر کاربر
- سهمیه حجم داده قابل تنظیم

## مدیریت پروکسی

### اسکریپت مدیریت
```bash
chmod +x scripts/manage.sh
./scripts/manage.sh
```

منوی مدیریت شامل:
- نمایش وضعیت سرویس‌ها
- مشاهده لاگ‌ها و آمار
- نمایش لینک‌های اتصال
- راه‌اندازی مجدد و توقف
- پشتیبان‌گیری و بازیابی
- تولید کاربر جدید
- مانیتورینگ لحظه‌ای

### دستورات مفید
```bash
# مشاهده وضعیت
docker-compose ps

# مشاهده لاگ‌ها
docker-compose logs -f mtprotoproxy

# نمایش لینک‌های اتصال
docker-compose logs mtprotoproxy | grep tg://proxy

# راه‌اندازی مجدد
docker-compose restart

# توقف کامل
docker-compose down
```

## مانیتورینگ و آمارگیری

### Prometheus + Grafana
```bash
# فعال‌سازی مانیتورینگ
docker-compose --profile monitoring up -d

# دسترسی
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin123)
```

### Load Balancer
```bash
# فعال‌سازی Nginx Load Balancer
docker-compose --profile loadbalancer up -d

# دسترسی به پنل مدیریت
# https://localhost:8443
```

## بهینه‌سازی سیستم

### تنظیمات شبکه
```bash
# بهینه‌سازی TCP
echo 'net.core.rmem_max = 134217728' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 134217728' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf
sysctl -p

# افزایش file descriptor limit
echo '* soft nofile 65536' >> /etc/security/limits.conf
echo '* hard nofile 65536' >> /etc/security/limits.conf
```

### فایروال
```bash
# باز کردن پورت‌های مورد نیاز
ufw allow 443/tcp
ufw allow 22/tcp
ufw enable
```

## عیب‌یابی

### مشکلات رایج

#### پروکسی وصل نمی‌شود
1. بررسی وضعیت سرویس: `docker-compose ps`
2. بررسی لاگ‌ها: `docker-compose logs mtprotoproxy`
3. بررسی فایروال: `ufw status`
4. بررسی پورت: `netstat -tuln | grep 443`

#### سرعت کم
1. بررسی CPU و RAM: `htop`
2. بررسی شبکه: `iftop`
3. بررسی تنظیمات بافر در config.py
4. فعال‌سازی `FAST_MODE = True`

#### AD_TAG کار نمی‌کند
1. بررسی `USE_MIDDLE_PROXY = True`
2. بررسی صحت AD_TAG از @MTProxybot
3. راه‌اندازی مجدد سرویس
4. بررسی لاگ‌ها برای خطا

### لاگ‌های مفید
```bash
# لاگ کامل
docker-compose logs -f

# لاگ خطاها
docker-compose logs mtprotoproxy | grep -i error

# آمار اتصالات
curl -s http://localhost:8080/metrics | grep connections
```

## امنیت

### توصیه‌های امنیتی
- استفاده از TLS mode
- تغییر پورت پیش‌فرض در صورت نیاز
- محدود کردن دسترسی به metrics endpoint
- استفاده از گواهی SSL معتبر برای nginx
- بروزرسانی منظم سیستم و Docker images

### پشتیبان‌گیری
```bash
# پشتیبان‌گیری خودکار
./scripts/manage.sh
# انتخاب گزینه 10
```

## پشتیبانی

برای دریافت پشتیبانی:
1. ابتدا بخش عیب‌یابی را مطالعه کنید
2. لاگ‌های مربوطه را جمع‌آوری کنید
3. اطلاعات سیستم و تنظیمات را آماده کنید

## لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.

---

**نکته مهم**: برای کسب درآمد بیشتر، حتماً AD_TAG معتبر از @MTProxybot دریافت کنید و USE_MIDDLE_PROXY را True قرار دهید.
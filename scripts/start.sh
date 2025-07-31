#!/bin/bash

# اسکریپت راه‌اندازی پروکسی MTProto
# Start script for MTProto Proxy

set -e

# رنگ‌ها برای خروجی بهتر
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# تابع چاپ پیام‌های رنگی
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}    MTProto Proxy Management${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo
}

# بررسی وجود Docker و Docker Compose
check_requirements() {
    print_message "بررسی پیش‌نیازها..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker نصب نیست. لطفاً ابتدا Docker را نصب کنید."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose نصب نیست. لطفاً ابتدا Docker Compose را نصب کنید."
        exit 1
    fi
    
    print_message "تمام پیش‌نیازها موجود است ✓"
}

# بررسی و ایجاد دایرکتوری‌های مورد نیاز
create_directories() {
    print_message "ایجاد دایرکتوری‌های مورد نیاز..."
    
    mkdir -p logs
    mkdir -p data
    mkdir -p nginx/ssl
    
    print_message "دایرکتوری‌ها ایجاد شد ✓"
}

# تولید گواهی SSL خودامضا
generate_ssl_cert() {
    if [ ! -f "nginx/ssl/cert.pem" ] || [ ! -f "nginx/ssl/key.pem" ]; then
        print_message "تولید گواهی SSL..."
        
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout nginx/ssl/key.pem \
            -out nginx/ssl/cert.pem \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" 2>/dev/null
        
        print_message "گواهی SSL تولید شد ✓"
    else
        print_message "گواهی SSL از قبل موجود است ✓"
    fi
}

# بررسی تنظیمات config.py
check_config() {
    print_message "بررسی تنظیمات..."
    
    if [ ! -f "config.py" ]; then
        print_error "فایل config.py یافت نشد!"
        exit 1
    fi
    
    # بررسی AD_TAG
    if grep -q "f80245e25d5d89fb6458bf1bfc697572" config.py; then
        print_warning "AD_TAG پیش‌فرض است. برای درآمدزایی، AD_TAG جدید از @MTProxybot دریافت کنید."
    fi
    
    # بررسی دامنه
    if grep -q "your-domain.com" config.py; then
        print_warning "لطفاً MY_DOMAIN را در config.py تنظیم کنید."
    fi
    
    print_message "تنظیمات بررسی شد ✓"
}

# راه‌اندازی سرویس‌ها
start_services() {
    print_message "راه‌اندازی سرویس‌ها..."
    
    # Build و start کردن سرویس اصلی
    docker-compose up -d mtprotoproxy
    
    print_message "سرویس اصلی راه‌اندازی شد ✓"
    
    # پرسش برای راه‌اندازی مانیتورینگ
    read -p "آیا می‌خواهید مانیتورینگ (Prometheus & Grafana) را فعال کنید؟ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose --profile monitoring up -d
        print_message "مانیتورینگ فعال شد:"
        print_message "  - Prometheus: http://localhost:9090"
        print_message "  - Grafana: http://localhost:3000 (admin/admin123)"
    fi
    
    # پرسش برای راه‌اندازی Load Balancer
    read -p "آیا می‌خواهید Load Balancer (Nginx) را فعال کنید؟ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose --profile loadbalancer up -d
        print_message "Load Balancer فعال شد:"
        print_message "  - Management: https://localhost:8443"
    fi
}

# نمایش اطلاعات اتصال
show_connection_info() {
    print_message "استخراج اطلاعات اتصال..."
    
    sleep 5  # انتظار برای راه‌اندازی کامل
    
    echo
    echo -e "${BLUE}=== اطلاعات اتصال ===${NC}"
    
    # استخراج لینک‌های اتصال از لاگ
    if docker-compose logs mtprotoproxy 2>/dev/null | grep -o "tg://proxy?[^[:space:]]*" | head -5; then
        echo
    else
        print_warning "لینک‌های اتصال هنوز آماده نیستند. چند دقیقه صبر کنید و دستور زیر را اجرا کنید:"
        echo "docker-compose logs mtprotoproxy | grep tg://proxy"
    fi
    
    echo -e "${BLUE}=== وضعیت سرویس‌ها ===${NC}"
    docker-compose ps
}

# تابع اصلی
main() {
    print_header
    
    check_requirements
    create_directories
    generate_ssl_cert
    check_config
    start_services
    show_connection_info
    
    echo
    print_message "پروکسی با موفقیت راه‌اندازی شد! 🎉"
    print_message "برای مدیریت بیشتر از اسکریپت manage.sh استفاده کنید."
}

# اجرای تابع اصلی
main "$@"
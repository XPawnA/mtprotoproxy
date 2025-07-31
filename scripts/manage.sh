#!/bin/bash

# اسکریپت مدیریت پروکسی MTProto
# Management script for MTProto Proxy

set -e

# رنگ‌ها برای خروجی بهتر
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

# نمایش منوی اصلی
show_menu() {
    echo -e "${CYAN}انتخاب کنید:${NC}"
    echo "1) نمایش وضعیت سرویس‌ها"
    echo "2) مشاهده لاگ‌ها"
    echo "3) نمایش لینک‌های اتصال"
    echo "4) مشاهده آمار و متریک‌ها"
    echo "5) راه‌اندازی مجدد سرویس‌ها"
    echo "6) توقف سرویس‌ها"
    echo "7) پاکسازی و حذف همه چیز"
    echo "8) بروزرسانی کانتینرها"
    echo "9) تنظیمات شبکه و فایروال"
    echo "10) پشتیبان‌گیری از تنظیمات"
    echo "11) بازیابی تنظیمات"
    echo "12) تولید کاربر جدید"
    echo "13) مانیتورینگ سیستم"
    echo "0) خروج"
    echo
}

# نمایش وضعیت سرویس‌ها
show_status() {
    print_message "وضعیت سرویس‌ها:"
    echo
    docker-compose ps
    echo
    
    print_message "استفاده از منابع:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    echo
}

# مشاهده لاگ‌ها
show_logs() {
    echo -e "${CYAN}کدام لاگ را می‌خواهید ببینید؟${NC}"
    echo "1) پروکسی اصلی"
    echo "2) Prometheus"
    echo "3) Grafana"
    echo "4) Nginx"
    echo "5) همه سرویس‌ها"
    echo
    
    read -p "انتخاب کنید (1-5): " choice
    
    case $choice in
        1) docker-compose logs -f --tail=100 mtprotoproxy ;;
        2) docker-compose logs -f --tail=100 prometheus ;;
        3) docker-compose logs -f --tail=100 grafana ;;
        4) docker-compose logs -f --tail=100 nginx ;;
        5) docker-compose logs -f --tail=50 ;;
        *) print_error "انتخاب نامعتبر!" ;;
    esac
}

# نمایش لینک‌های اتصال
show_connections() {
    print_message "استخراج لینک‌های اتصال..."
    echo
    
    # لینک‌های TLS
    echo -e "${GREEN}=== لینک‌های TLS (توصیه شده) ===${NC}"
    docker-compose logs mtprotoproxy 2>/dev/null | grep -o "tg://proxy?[^[:space:]]*" | head -10
    
    echo
    echo -e "${BLUE}=== QR Code برای اتصال سریع ===${NC}"
    # تولید QR code اگر qrencode نصب باشد
    if command -v qrencode &> /dev/null; then
        FIRST_LINK=$(docker-compose logs mtprotoproxy 2>/dev/null | grep -o "tg://proxy?[^[:space:]]*" | head -1)
        if [ ! -z "$FIRST_LINK" ]; then
            echo "$FIRST_LINK" | qrencode -t ANSIUTF8
        fi
    else
        print_warning "برای نمایش QR Code، qrencode را نصب کنید: apt install qrencode"
    fi
    
    echo
    print_message "این لینک‌ها را در تلگرام خود اضافه کنید."
}

# مشاهده آمار و متریک‌ها
show_metrics() {
    print_message "آمار و متریک‌ها:"
    echo
    
    # بررسی در دسترس بودن metrics endpoint
    if curl -s http://localhost:8080/metrics > /dev/null 2>&1; then
        echo -e "${GREEN}=== آمار اتصالات ===${NC}"
        curl -s http://localhost:8080/metrics | grep -E "(connections|users|traffic)" | head -10
        echo
        
        echo -e "${GREEN}=== لینک‌های مفید ===${NC}"
        echo "Prometheus: http://localhost:9090"
        echo "Grafana: http://localhost:3000"
        echo "Metrics API: http://localhost:8080/metrics"
    else
        print_warning "Metrics endpoint در دسترس نیست. مانیتورینگ فعال نیست یا سرویس در حال راه‌اندازی است."
    fi
    
    echo
    echo -e "${GREEN}=== آمار سیستم ===${NC}"
    echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')"
    echo "Memory Usage: $(free | grep Mem | awk '{printf("%.2f%%", $3/$2 * 100.0)}')"
    echo "Disk Usage: $(df -h / | awk 'NR==2{printf "%s", $5}')"
    echo "Network Connections: $(netstat -an | grep :443 | wc -l)"
}

# راه‌اندازی مجدد سرویس‌ها
restart_services() {
    print_message "راه‌اندازی مجدد سرویس‌ها..."
    
    docker-compose restart
    
    print_message "سرویس‌ها راه‌اندازی مجدد شدند ✓"
}

# توقف سرویس‌ها
stop_services() {
    print_warning "آیا مطمئن هستید که می‌خواهید همه سرویس‌ها را متوقف کنید؟ (y/N)"
    read -r response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_message "توقف سرویس‌ها..."
        docker-compose down
        print_message "همه سرویس‌ها متوقف شدند ✓"
    else
        print_message "عملیات لغو شد."
    fi
}

# پاکسازی کامل
cleanup_all() {
    print_error "هشدار: این عملیات همه کانتینرها، volumes و تصاویر را حذف می‌کند!"
    print_warning "آیا مطمئن هستید؟ (yes/NO)"
    read -r response
    
    if [[ "$response" == "yes" ]]; then
        print_message "پاکسازی در حال انجام..."
        docker-compose down -v --rmi all --remove-orphans
        docker system prune -af
        print_message "پاکسازی کامل انجام شد ✓"
    else
        print_message "عملیات لغو شد."
    fi
}

# بروزرسانی کانتینرها
update_containers() {
    print_message "بروزرسانی کانتینرها..."
    
    docker-compose pull
    docker-compose up -d --build
    
    print_message "کانتینرها بروزرسانی شدند ✓"
}

# تنظیمات شبکه و فایروال
network_settings() {
    print_message "تنظیمات شبکه و فایروال:"
    echo
    
    echo -e "${CYAN}انتخاب کنید:${NC}"
    echo "1) نمایش تنظیمات فعلی"
    echo "2) باز کردن پورت 443 در فایروال"
    echo "3) بهینه‌سازی تنظیمات شبکه"
    echo "4) بررسی اتصالات فعال"
    
    read -p "انتخاب کنید (1-4): " choice
    
    case $choice in
        1)
            echo "پورت‌های باز:"
            netstat -tuln | grep LISTEN
            echo
            echo "قوانین فایروال:"
            if command -v ufw &> /dev/null; then
                ufw status
            elif command -v iptables &> /dev/null; then
                iptables -L -n | head -20
            fi
            ;;
        2)
            if command -v ufw &> /dev/null; then
                sudo ufw allow 443/tcp
                print_message "پورت 443 در فایروال باز شد ✓"
            else
                print_warning "UFW نصب نیست. دستی پورت 443 را باز کنید."
            fi
            ;;
        3)
            print_message "بهینه‌سازی تنظیمات شبکه..."
            # تنظیمات TCP optimization
            echo 'net.core.rmem_max = 134217728' | sudo tee -a /etc/sysctl.conf
            echo 'net.core.wmem_max = 134217728' | sudo tee -a /etc/sysctl.conf
            echo 'net.ipv4.tcp_congestion_control = bbr' | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
            print_message "تنظیمات شبکه بهینه شد ✓"
            ;;
        4)
            echo "اتصالات فعال به پورت 443:"
            netstat -an | grep :443 | head -20
            ;;
    esac
}

# پشتیبان‌گیری از تنظیمات
backup_config() {
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    print_message "پشتیبان‌گیری در $BACKUP_DIR..."
    
    cp config.py "$BACKUP_DIR/"
    cp docker-compose.yml "$BACKUP_DIR/"
    cp -r monitoring "$BACKUP_DIR/" 2>/dev/null || true
    cp -r nginx "$BACKUP_DIR/" 2>/dev/null || true
    
    # Export کردن volumes
    docker run --rm -v proxy_data:/data -v "$PWD/$BACKUP_DIR":/backup alpine tar czf /backup/proxy_data.tar.gz -C /data .
    
    print_message "پشتیبان‌گیری کامل شد ✓"
    echo "مسیر: $BACKUP_DIR"
}

# بازیابی تنظیمات
restore_config() {
    echo -e "${CYAN}فایل‌های پشتیبان موجود:${NC}"
    ls -la backups/ 2>/dev/null || print_error "هیچ پشتیبانی یافت نشد!"
    
    read -p "نام پوشه پشتیبان را وارد کنید: " backup_name
    
    if [ -d "backups/$backup_name" ]; then
        print_warning "آیا مطمئن هستید؟ تنظیمات فعلی جایگزین خواهد شد! (y/N)"
        read -r response
        
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            cp "backups/$backup_name/config.py" .
            cp "backups/$backup_name/docker-compose.yml" .
            cp -r "backups/$backup_name/monitoring" . 2>/dev/null || true
            cp -r "backups/$backup_name/nginx" . 2>/dev/null || true
            
            print_message "تنظیمات بازیابی شد ✓"
        fi
    else
        print_error "پشتیبان یافت نشد!"
    fi
}

# تولید کاربر جدید
generate_user() {
    read -p "نام کاربر جدید را وارد کنید: " username
    
    if [ -z "$username" ]; then
        print_error "نام کاربر نمی‌تواند خالی باشد!"
        return
    fi
    
    # تولید secret تصادفی
    secret=$(openssl rand -hex 16)
    
    print_message "کاربر جدید تولید شد:"
    echo "نام کاربر: $username"
    echo "Secret: $secret"
    echo
    print_message "این خط را به بخش USERS در config.py اضافه کنید:"
    echo "    \"$username\": \"$secret\","
    echo
    print_warning "پس از اضافه کردن، سرویس را راه‌اندازی مجدد کنید."
}

# مانیتورینگ سیستم
system_monitoring() {
    print_message "مانیتورینگ سیستم در حال اجرا... (Ctrl+C برای خروج)"
    echo
    
    while true; do
        clear
        echo -e "${BLUE}=== مانیتورینگ لحظه‌ای سیستم ===${NC}"
        echo "زمان: $(date)"
        echo
        
        echo -e "${GREEN}CPU & Memory:${NC}"
        top -bn1 | head -5
        echo
        
        echo -e "${GREEN}اتصالات شبکه:${NC}"
        echo "کل اتصالات به پورت 443: $(netstat -an | grep :443 | wc -l)"
        echo "اتصالات ESTABLISHED: $(netstat -an | grep :443 | grep ESTABLISHED | wc -l)"
        echo
        
        echo -e "${GREEN}وضعیت کانتینرها:${NC}"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | head -5
        
        sleep 5
    done
}

# تابع اصلی
main() {
    while true; do
        print_header
        show_menu
        
        read -p "انتخاب شما: " choice
        echo
        
        case $choice in
            1) show_status ;;
            2) show_logs ;;
            3) show_connections ;;
            4) show_metrics ;;
            5) restart_services ;;
            6) stop_services ;;
            7) cleanup_all ;;
            8) update_containers ;;
            9) network_settings ;;
            10) backup_config ;;
            11) restore_config ;;
            12) generate_user ;;
            13) system_monitoring ;;
            0) 
                print_message "خروج از برنامه."
                exit 0
                ;;
            *) print_error "انتخاب نامعتبر!" ;;
        esac
        
        echo
        read -p "برای ادامه Enter بزنید..."
        clear
    done
}

# اجرای تابع اصلی
main "$@"
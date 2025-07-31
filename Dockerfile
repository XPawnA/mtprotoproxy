# Multi-stage build برای کاهش سایز نهایی image
FROM ubuntu:22.04 as builder

# نصب dependencies مورد نیاز برای build
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-pip \
    python3-dev \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# نصب Python packages بهینه شده
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir uvloop cryptography pysocks

# مرحله اصلی - runtime image
FROM ubuntu:22.04

# تنظیم متغیرهای محیطی برای بهینه‌سازی
ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# نصب runtime dependencies فقط
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-uvloop \
    python3-cryptography \
    python3-socks \
    libcap2-bin \
    ca-certificates \
    curl \
    htop \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# کپی کردن Python packages از builder stage
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages

# تنظیم capabilities برای bind کردن به پورت‌های privileged
RUN setcap cap_net_bind_service=+ep /usr/bin/python3.10

# ایجاد کاربر غیر root برای امنیت
RUN useradd --create-home --shell /bin/bash --uid 10000 tgproxy

# تنظیم کاربر و دایرکتوری کاری
USER tgproxy
WORKDIR /home/tgproxy/

# کپی کردن فایل‌های پروژه با ownership صحیح
COPY --chown=tgproxy:tgproxy mtprotoproxy.py config.py ./
COPY --chown=tgproxy:tgproxy pyaes/ ./pyaes/

# ایجاد دایرکتوری برای logs
RUN mkdir -p /home/tgproxy/logs

# تنظیم file descriptor limits برای performance بهتر
RUN echo "tgproxy soft nofile 65536" >> /etc/security/limits.conf && \
    echo "tgproxy hard nofile 65536" >> /etc/security/limits.conf

# Health check برای monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 -c "import socket; s=socket.socket(); s.settimeout(5); s.connect(('127.0.0.1', 443)); s.close()" || exit 1

# Expose کردن پورت‌ها
EXPOSE 443 8080

# تنظیم signal handling برای graceful shutdown
STOPSIGNAL SIGTERM

# اجرای پروکسی با uvloop برای performance بهتر
CMD ["python3", "-u", "mtprotoproxy.py"]

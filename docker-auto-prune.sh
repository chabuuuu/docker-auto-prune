#!/bin/bash

# Load biến môi trường từ file .env
source .env

# Lấy phần trăm dung lượng của ổ đĩa gốc (/) 
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

# Ngưỡng dung lượng tối thiểu (85%)
THRESHOLD=85

# Hàm gửi thông báo đến Telegram
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_CHAT_ID" \
        -d "text=$message"
}

# Kiểm tra nếu dung lượng sử dụng lớn hơn ngưỡng
if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    send_telegram_message "❌ Dung lượng ổ đĩa đã vượt quá $THRESHOLD% ($DISK_USAGE%), tiến hành dọn dẹp Docker..."
    echo "Dung lượng ổ đĩa đã vượt quá $THRESHOLD% ($DISK_USAGE%), tiến hành dọn dẹp Docker..."
    sudo docker system prune -af
    echo "Dọn dẹp Docker hoàn tất."
    AFTER_CLEAN_DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    send_telegram_message "✅ Dọn dẹp Docker hoàn tất. Dung lượng hiện tại là $AFTER_CLEAN_DISK_USAGE%."

else
    echo "Dung lượng ổ đĩa vẫn trong mức an toàn ($DISK_USAGE%) (THRESHOLD: $THRESHOLD%), không cần dọn dẹp."
fi

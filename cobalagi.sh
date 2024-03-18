#!/bin/bash

TELEGRAM_BOT_TOKEN="6346958013:AAG5Gwoz_6kzZwol6IXO7eDdkm_Ye0bKZxg"
TELEGRAM_CHAT_ID="-1002052177540"
DOMAIN_FILE="/home/eric/myproject/data.py"

# Fungsi untuk mengirim pesan ke Telegram
function kirim_pesan_ke_telegram() {
    pesan="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID&text=$pesan"
}

# Fungsi untuk memeriksa sertifikat SSL dan mengirimkan reminder jika mendekati kedaluwarsa
function cek_ssl_domain() {
    domain="$1"
    expiration_date=$(openssl s_client -connect "$domain":443 -servername "$domain" -showcerts 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
    expiration_timestamp=$(date -d "$expiration_date" +%s)
    current_timestamp=$(date +%s)
    days_remaining=$(( (expiration_timestamp - current_timestamp) / 86400 ))

    if [ "$days_remaining" -lt 5 ]; then
        pesan="Peringatan: Sertifikat SSL untuk domain $domain akan kedaluwarsa dalam $days_remaining hari!"
        kirim_pesan_ke_telegram "$pesan"
    fi
}

# Membaca daftar domain dari file
while IFS= read -r domain; do
    cek_ssl_domain "$domain"
done < "$DOMAIN_FILE"

#!/bin/bash

# Ganti 'YOUR_BOT_TOKEN' dengan token bot Telegram Anda
TELEGRAM_BOT_TOKEN="6346958013:AAG5Gwoz_6kzZwol6IXO7eDdkm_Ye0bKZxg"
TELEGRAM_CHAT_ID="-2052177540" # Ganti dengan ID chat dari pengguna/grup/channel yang ingin Anda kirim pesan ke sana

# Fungsi untuk mengirim pesan ke Telegram
function kirim_pesan_ke_telegram() {
    pesan="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID&text=$pesan"
}

# Fungsi untuk memeriksa status SSL suatu domain
function cek_ssl_domain() {
    domain="$1"
    cek_ssl=$(checkssl --status $domain)
    kirim_pesan_ke_telegram "$cek_ssl"
}

# Membaca file yang berisi daftar domain
while IFS= read -r domain; do
    # Memeriksa status SSL dan mengirim hasilnya ke Telegram
    cek_ssl_domain "$domain"
done < /home/eric/myproject/data.py  # Ganti 'list_domain.txt' dengan nama file yang berisi daftar domain

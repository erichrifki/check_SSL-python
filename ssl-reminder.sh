#!/bin/bash

# Fungsi untuk memeriksa SSL sertifikat
cek_ssl() {
    domain=$1
    expiration_date=$(openssl s_client -connect "$domain":443 -servername "$domain" -showcerts 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
    expiration_timestamp=$(date -d "$expiration_date" +%s)
    current_timestamp=$(date +%s)
    days_remaining=$(( (expiration_timestamp - current_timestamp) / 86400 ))

    echo "Sertifikat untuk domain $domain akan kedaluwarsa dalam $days_remaining hari."
}

# Fungsi untuk mengirim pesan ke bot Telegram
kirim_pesan_telegram() {
    bot_token="1678564025:AAGkmKn1CHEzvNqh3ERyUfxtnFwzLpjz82Q"
    chat_id=" -1001983689381"
    message="$1"

    curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" -d "chat_id=$chat_id" -d "text=$message"
}

# Path file yang berisi daftar domain
file_path="/home/eric/myproject/data.py"

# Membaca daftar domain dari file
readarray -t domains < "$file_path"

# Loop melalui daftar domain
for domain in "${domains[@]}"; do
    domain=$(echo "$domain" | tr -d '\n\r') # Hapus karakter newline atau carriage return
    cek_ssl "$domain"
    # Ganti 3 hari dengan jumlah hari yang diinginkan sebelum sertifikat kedaluwarsa
    if [ $days_remaining -lt 3 ]; then
        pesan="Warning: certificate for the domain $domain will expire in $days_remaining day!"
        kirim_pesan_telegram "$pesan"
    fi
done

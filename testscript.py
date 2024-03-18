import ssl
import socket
from datetime import datetime

def check_ssl_expiry(domain, port=443):
    try:
        # Membuka koneksi SSL ke domain pada port yang diberikan
        context = ssl.create_default_context()
        with socket.create_connection((domain, port)) as sock:
            with context.wrap_socket(sock, server_hostname=domain) as ssock:
                cert_info = ssock.getpeercert()

        # Mendapatkan tanggal kedaluwarsa dari sertifikat
        expiry_date = datetime.strptime(cert_info['notAfter'], "%b %d %H:%M:%S %Y %Z")

        # Menghitung sisa hari sebelum kedaluwarsa
        days_left = (expiry_date - datetime.now()).days

        return expiry_date, days_left

    except ssl.CertificateError as e:
        return None, str(e)

if __name__ == "__main__":
    # Baca daftar domain dari file
    with open('data.py', 'r') as file:
        domains = file.read().splitlines()

    # Periksa SSL untuk setiap domain dan cetak hasilnya
    for domain in domains:
        expiry_date, days_left = check_ssl_expiry(domain)
        if expiry_date:
            print(f"Domain: {domain}\nExpiry Date: {expiry_date}\nDays Left: {days_left} days\n")
        else:
            print(f"Domain: {domain}\nError: {days_left}\n")


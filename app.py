from flask import Flask, render_template, request, redirect, url_for
import os
import ssl
import socket
import subprocess
from datetime import datetime


app = Flask(__name__)
# route untuk menampilkan from html
@app.route('/')
def index():
    return render_template('form.html')
# route untuk submit data ke file data.py
@app.route('/submit', methods=['POST'])
def submit():
    data = request.form['data']
    with open('data.py', 'a') as file:
        file.write(data + '\n')
    return redirect(url_for('index'))
# route ke show data dan reander html untuk show 
@app.route('/show')
def show():
    with open('data.py', 'r') as file:
        data = file.readlines()
    return render_template('show.html', data=data)
# route untuk menghapus 
@app.route('/delete', methods=['POST'])
def delete():
    data_to_delete = request.form['data']
    with open('data.py', 'r') as file:
        lines = file.readlines()
    with open('data.py', 'w') as file:
        for line in lines:
            if line.strip() != data_to_delete:
                file.write(line)
    return redirect(url_for('show'))
# route unutk chech ssl live 
def check_ssl_certificate(hostname, port=443):
    try:
        # Membuat koneksi SSL ke server
        context = ssl.create_default_context()
        with context.wrap_socket(socket.create_connection((hostname, port)), server_hostname=hostname) as sock:
            # Mendapatkan sertifikat SSL dari koneksi
            cert = sock.getpeercert()

            # Mendapatkan informasi tentang sertifikat
            subject = dict(x[0] for x in cert['subject'])
            issued_to = subject.get('commonName', None)
            issued_by = dict(x[0] for x in cert['issuer'])
            expiration_date = datetime.strptime(cert['notAfter'], "%b %d %H:%M:%S %Y %Z")

            # Menyiapkan informasi sertifikat
            cert_info = {
                "issued_to": issued_to,
                "issued_by": issued_by.get('organizationName', 'N/A'),
                "expiration_date": expiration_date
            }

            return cert_info
    except ssl.SSLError as e:
        return {"error": str(e)}
    except socket.error as e:
        return {"error": str(e)}

@app.route('/', methods=['GET', 'POST'])
def form():
    cert_info = None

    if request.method == 'POST':
        website = request.form['website']
        cert_info = check_ssl_certificate(website)

    return render_template('form.html', cert_info=cert_info)

@app.route('/run_script', methods=['POST'])
def run_script():
    # Jalankan skrip bash Anda di sini
    # Gantilah /path/to/your_script.sh dengan jalur skrip bash yang sebenarnya
    subprocess.run(['/bin/bash', '/home/eric/python/ssl-checker.sh'])
    return 'Script has been executed successfully!'
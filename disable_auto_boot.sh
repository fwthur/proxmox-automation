#!/bin/bash

# Membaca file users.txt
while IFS=, read -r pct_id phone_number
do
    # Menghapus spasi tambahan jika ada
    pct_id=$(echo $pct_id | xargs)
    
    # Menonaktifkan start on boot untuk kontainer dengan pct_id yang sesuai
    pct set $pct_id -onboot 0
    
    # Menampilkan pesan untuk setiap kontainer yang diproses
    echo "Autostart untuk container ID $pct_id telah dinonaktifkan."
done < users.txt

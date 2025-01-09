#!/bin/bash

# Path ke file yang berisi daftar LXC ID dan username
USER_FILE="users.txt"

# Validasi file input
if [[ ! -f "$USER_FILE" ]]; then
    echo "Error: File $USER_FILE tidak ditemukan."
    exit 1
fi

# Proses setiap baris di file
while IFS=', ' read -r LXC_ID USERNAME; do
    echo "Proses: Menghapus user ${USERNAME}@pve dan LXC ${LXC_ID}"

    # Hentikan LXC jika sedang berjalan
    if pct status "${LXC_ID}" &>/dev/null; then
        LXC_STATUS=$(pct status "${LXC_ID}" | awk '{print $2}')
        if [[ "$LXC_STATUS" == "running" ]]; then
            echo "Menghentikan LXC ${LXC_ID}..."
            if ! pct stop "${LXC_ID}"; then
                echo "Error: Gagal menghentikan LXC ${LXC_ID}"
                continue
            fi
        fi

        # Hapus LXC
        echo "Menghapus LXC ${LXC_ID}..."
        if ! pct destroy "${LXC_ID}"; then
            echo "Error: Gagal menghapus LXC ${LXC_ID}"
            continue
        fi
    else
        echo "Peringatan: LXC ${LXC_ID} tidak ditemukan, melewati proses penghapusan LXC."
    fi

    # Hapus user
    echo "Menghapus user ${USERNAME}@pve..."
    if ! pveum user del "${USERNAME}@pve"; then
        echo "Error: Gagal menghapus user ${USERNAME}@pve"
        continue
    fi

    echo "Sukses: User ${USERNAME}@pve dan LXC ${LXC_ID} berhasil dihapus."
done < "$USER_FILE"

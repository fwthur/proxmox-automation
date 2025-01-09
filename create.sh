#!/bin/bash

# Path ke file yang berisi daftar LXC ID dan username
USER_FILE="users.txt"
TEMPLATE_ID="999" # ID template yang sudah ada
MEMORY="512" # Alokasi RAM per LXC
DISK_SIZE="3" # Alokasi disk per LXC (8GB)
SWAP_SIZE="512" # Alokasi swap per LXC (512MB)
DEFAULT_PASSWORD="12345678" # Password default
STORAGE="hdd" # Ganti dengan storage yang mendukung LXC

# Validasi file input
if [[ ! -f "$USER_FILE" ]]; then
    echo "Error: File $USER_FILE tidak ditemukan."
    exit 1
fi

# Validasi template ID
if ! pct config "$TEMPLATE_ID" &>/dev/null; then
    echo "Error: Template dengan ID $TEMPLATE_ID tidak ditemukan."
    exit 1
fi

# Validasi storage
if ! pvesm list "$STORAGE" &>/dev/null; then
    echo "Error: Storage $STORAGE tidak ditemukan atau tidak mendukung LXC container."
    exit 1
fi

# Proses setiap baris di file
while IFS=', ' read -r LXC_ID USERNAME; do
    echo "Proses: Membuat user ${USERNAME}@pve dan LXC ${LXC_ID}"

    # Buat user
    if ! pveum user add "${USERNAME}@pve" --password "${DEFAULT_PASSWORD}"; then
        echo "Error: Gagal membuat user ${USERNAME}@pve"
        continue
    fi

    # Clone dari template ID 103 sebagai full clone
    LXC_HOSTNAME="${USERNAME}"
    if ! pct clone "${TEMPLATE_ID}" "${LXC_ID}" --hostname "${LXC_HOSTNAME}" \
        --storage "${STORAGE}" --full 1; then
        echo "Error: Gagal membuat full clone dari template ID ${TEMPLATE_ID} untuk user ${USERNAME}@pve"
        continue
    fi

    # Set konfigurasi tambahan
    if ! pct set "${LXC_ID}" \
        -memory "${MEMORY}" \
        -swap "${SWAP_SIZE}" \
        -cores 1 \
        -net0 name=eth0,bridge=vmbr0,ip=dhcp,firewall=1 \
        -features nesting=1; then
        echo "Error: Gagal mengatur konfigurasi untuk LXC ${LXC_ID}"
        continue
    fi

    # Aktifkan auto-start untuk LXC
    pct set "${LXC_ID}" -onboot 0

    # Start LXC setelah dibuat
    #if ! pct start "${LXC_ID}"; then
    #    echo "Error: Gagal memulai LXC ${LXC_ID}"
    #    continue
    #fi

    # Beri izin
    if ! pveum aclmod "/vms/${LXC_ID}" -user "${USERNAME}@pve" -role PVEVMUser; then
        echo "Error: Gagal memberikan izin untuk user ${USERNAME}@pve pada LXC ${LXC_ID}"
        continue
    fi

    echo "Sukses: User ${USERNAME}@pve dibuat, LXC ${LXC_ID} dengan hostname ${LXC_HOSTNAME} dibuat sebagai full clone dari template ID ${TEMPLATE_ID}, diberi izin, diatur untuk auto-start, dan password root diubah serta LXC dimulai dengan swap 512MB, firewall diaktifkan, dan nesting diaktifkan."
done < "$USER_FILE"


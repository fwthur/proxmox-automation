# proxmox-automation

# Proxmox Automation Scripts for VM and User Management

This repository contains automation scripts for managing Proxmox VE containers (LXC) and users based on a `users.txt` file. These scripts streamline the process of creating and deleting containers, managing user permissions, and configuring container settings.

## Features

1. **Auto-create LXC containers and users:**
   - Creates LXC containers for students based on a template.
   - Configures memory, disk, swap, and other container settings.
   - Adds users with default passwords and grants appropriate permissions.

2. **Auto-destroy LXC containers and users:**
   - Stops and removes LXC containers.
   - Deletes associated Proxmox users.

3. **Disable auto-boot for LXC containers:**
   - Disables auto-start for specified containers.

## Scripts

- **`create.sh`**: Creates LXC containers and users based on `users.txt`.
- **`destroy.sh`**: Removes LXC containers and users based on `users.txt`.
- **`disable_auto_boot.sh`**: Disables auto-boot for containers listed in `users.txt`.

## Usage

### Prerequisites

1. Ensure Proxmox VE is installed and running.
2. Place the scripts and `users.txt` file in the same directory.

### File Structure

- `users.txt`: Contains a list of LXC IDs and usernames in the format:
  ```
  <LXC_ID>, <USERNAME>
  ```

### Steps

1. **Create LXC Containers and Users**
   ```bash
   bash create.sh
   ```
   - Ensure the `users.txt` file is populated with the desired LXC IDs and usernames.

2. **Disable Auto-Boot**
   ```bash
   bash disable_auto_boot.sh
   ```
   - This script disables the auto-start feature for containers.

3. **Destroy LXC Containers and Users**
   ```bash
   bash destroy.sh
   ```
   - Removes the LXC containers and associated users defined in `users.txt`.

## Example

Sample `users.txt` file:
```
101, student1
102, student2
```

- Running `create.sh` will:
  - Create LXC containers `101` and `102`.
  - Add users `student1` and `student2`.

- Running `destroy.sh` will:
  - Remove containers `101` and `102`.
  - Delete users `student1` and `student2`.

- Running `disable_auto_boot.sh` will:
  - Disable auto-boot for containers `101` and `102`.

## Background

As an educator, I created these scripts to simplify the process of managing LXC containers for my students. This automation ensures an efficient workflow for creating and deleting resources based on the needs of my class.

## License

This project is open-source and available under the [MIT License](LICENSE).

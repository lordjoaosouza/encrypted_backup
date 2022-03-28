#!/usr/bin/env bash

sudo echo

# paths
backup_path="/testbackup"  # backup origin
storage_path="/mnt/backup"  # backup destination     


device() {
  # input a device
  echo; read -p "Type device to storage backup: /dev/" device;
  device="/dev/$device"

  # check if device exists
  test_device=$(sudo find /dev -wholename $device)
  if test $test_device; then
    echo; echo "Device $device found."
    mountpoint_check
  else
    echo; echo "Device $device not found."
    exit
  fi
}

mount_device() {
  mnt_dev=$"sudo mount -v $device $storage_path"

  # check mountpoint
  mnt_check="mountpoint -q -- $storage_path"

  if ! $mnt_check; then
    echo; echo "Device $device not mounted on $storage_path.";
    while true; do
      read -p "Want to mount? (y/n): " proceed
      case $proceed in
          [Yy]* ) $mnt_dev; echo; break;;
          [Nn]* ) exit;;
          * ) echo "Invalid option.";;
      esac
    done
  else
    echo; echo "Device $device already mounted on $storage_path."; echo;
  fi
}

mountpoint_check() {
  create_mnt="sudo mkdir $storage_path"

  # check if directory exists
  if [ -d "$storage_path" ]; then
    mount_device
  else
    echo; echo "Mountpoint $storage_path do not exists."
    while true; do
      read -p "Want to create $storage_path? (y/n): " proceed
      case $proceed in
          [Yy]* ) $create_mnt; device; mount_device; echo; break;;
          [Nn]* ) echo; echo "End of application."; exit;;
          * ) echo "Invalid option.";;
      esac
    done
  fi
}


# TO CREATE MENU

# test
echo "Backup script started."
device 

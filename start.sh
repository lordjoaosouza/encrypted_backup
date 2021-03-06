#!/usr/bin/env bash

sudo echo

# paths
backup_path="/testbackup"  # backup origin
storage_path="/mnt/backup" # backup destination

end() {
  # end application
  echo
  echo "End of application."
  exit
}

device() {
  # input a device
  echo
  read -p "Type device to storage backup: /dev/" device
  device="/dev/$device"

  # check if device exists
  test_device=$(sudo find /dev -wholename $device)
  while ! test $test_device; do
    echo
    echo "Device $device not found."
    read -p "Want choose another device? (y/n): " option
    case $option in
    [Yy]*)
      device
      ;;
    *)
      end
      ;;
    esac
  done

  echo
  echo "Device $device found."
  menu
}

menu() {
  echo
  echo "0 - End application;"
  echo "1 - Clear disk;"
  echo "2 - Set LUKS encryptation;"
  echo "3 - Start backup."
  read -p "Select an option: " option
  case $option in
  1)
    clear
    menu
    ;;
  2)
    encrypt
    menu
    ;;
  3)
    backup
    menu
    ;;
  *)
    end
    ;;
  esac
}

in_use() {
  # check device use (if busy: force stop)
  echo
}

clear() {
  echo
  read -p "This will erase data. Really want to proceed? (y/n): " option
  case $option in
  [Yy]*)
    # clear disk
    sudo wipefs -a $device
    echo
    echo "Done disk cleaning."
    ;;
  esac
}

encrypt() { # TODO: check 3 times wrong passwords
  # set up LUKS encryptation
  sudo cryptsetup luksFormat $device

  case $? in
  0)
    echo
    echo "Done disk encrypting."
    ;;
  1)
    echo "Failed disk encrypting."
    ;;
  2)
    echo
    echo "Failed disk encrypting."
    encrypt
    ;;
  esac
}

open_encryptation() {
  # open LUKS encryption
  echo
}

close_encryptation() {
  # close LUKS encryption
  echo
}

directory() {
  # check directory to backup
  echo
}

backup() {
  # start backup
  echo
}

mount_device() {
  mnt_dev=$"sudo mount -v $device $storage_path"

  # check mountpoint
  mnt_check="mountpoint -q -- $storage_path"

  if ! $mnt_check; then
    echo
    echo "Device $device not mounted on $storage_path."
    read -p "Want to mount? (y/n): " option
    case $option in
    [Yy]*)
      $mnt_dev
      echo
      ;;
    *)
      menu
      ;;
    esac
  else
    echo
    echo "Device $device already mounted on $storage_path."
    echo
  fi
}

mountpoint_check() {
  create_mnt="sudo mkdir $storage_path"

  # check if directory exists
  if [ -d "$storage_path" ]; then
    mount_device
  else
    echo
    echo "Mountpoint $storage_path do not exists."
    read -p "Want to create $storage_path? (y/n): " option
    case $option in
    [Yy]*)
      $create_mnt
      device
      mount_device
      echo
      break
      ;;
    *)
      menu
      ;;
    esac
  fi
}

# start script
echo "Backup script started."
device

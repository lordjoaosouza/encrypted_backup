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
    ;;
  2)
    encrypt
    ;;
  *)
    end
    ;;
  esac

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

  menu
}

encrypt() {
  # set up LUKS encryptation
  sudo cryptsetup luksFormat $device

  if [ $? == 0 ]; then
    echo
    echo "Done disk encrypting."
  elif [ $? == 1 ]; then
    echo "Failed disk encrypting."
  else
    echo
    echo "Failed disk encrypting."
  fi

  menu
}

open_encryptation() {
  echo
  echo "To implement"
}

close_encryptation() {
  echo
  echo "To implement"
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

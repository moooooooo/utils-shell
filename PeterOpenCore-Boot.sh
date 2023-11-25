#!/usr/bin/env bash

# orig repo:
# https://github.com/kholia/OSX-KVM.git

# Special thanks to:
# https://github.com/Leoyzen/KVM-Opencore
# https://github.com/thenickdude/KVM-Opencore/
# https://github.com/qemu/qemu/blob/master/docs/usb2.txt
#
# after running fetch-macOS-v2.py, do the next 2
#
# dmg2img -i BaseSystem.dmg BaseSystem.img
# qemu-img create -f qcow2 mac_hdd_ng.img 750G
#
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)

############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

# This script works for Big Sur, Catalina, Mojave, and High Sierra. Tested with
# macOS 10.15.6, macOS 10.14.6, and macOS 10.13.6.

ALLOCATED_RAM="24576" # MiB
CPU_SOCKETS="1"
CPU_CORES="8"
CPU_THREADS="8"

REPO_PATH="."
OVMF_DIR="."

# shellcheck disable=SC2054
args=(
  -enable-kvm -m "$ALLOCATED_RAM" -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,"$MY_OPTIONS"
  # -machine q35
  -machine ubuntu-q35
  -usb -device usb-kbd -device usb-tablet
  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS"
  -device usb-ehci,id=ehci
  # -device usb-kbd,bus=ehci.0
  # -device usb-mouse,bus=ehci.0
  -device nec-usb-xhci,id=xhci
  -global nec-usb-xhci.msi=off
  -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off
  # -device usb-host,vendorid=0x8086,productid=0x0808  # 2 USD USB Sound Card
  # -device usb-host,vendorid=0x1b3f,productid=0x2008  # Another 2 USD USB Sound Card
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly=on,file="$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="$REPO_PATH/$OVMF_DIR/OVMF_VARS-1920x1080.fd"
  -smbios type=2
  -device ich9-intel-hda -device hda-duplex
  -device ich9-ahci,id=sata
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore/OpenCore.qcow2"
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot
  -device ide-hd,bus=sata.3,drive=InstallMedia
  -drive id=InstallMedia,if=none,file="$REPO_PATH/BaseSystem.img",format=raw
  -drive id=MacHDD,if=none,file="$REPO_PATH/mac_hdd_ng.img",format=qcow2
  -device ide-hd,bus=sata.4,drive=MacHDD
  # --------------------------------------------------------------------------------
  # Peter - test img 
  # --------------------------------------------------------------------------------
  # -drive id=MacHDDPtr,if=none,file="/home/peter/src/mac_hdd_peter.img",format=qcow2
  # -device ide-hd,bus=sata.5,drive=MacHDDPtr
  # end peter test
  # --------------------------------------------------------------------------------
  # Peter emily hdd
  # -device ide-hd,bus=sata.5,drive=Spinning
  # -drive id=Spinning,if=none,file="/dev/sda2",format=raw
  # end emily hdd
  # --------------------------------------------------------------------------------
  # Peter - Windows disk
  # -device ide-hd,bus=sata.5,drive=Windows
  # -drive id=Windows,if=none,file="/dev/sdc",format=raw
  # end Windows disk
  # --------------------------------------------------------------------------------
  # -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  # -netdev user,id=net0 -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  # -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27  # Note: Use this line for High Sierra
  -monitor stdio
  -device vmware-svga,vgamem_mb=64
)

qemu-system-x86_64 "${args[@]}"

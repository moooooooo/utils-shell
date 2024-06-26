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
  # -device usb-ehci,id=ehci
  # -device usb-kbd,bus=ehci.0
  # -device usb-mouse,bus=ehci.0
  # -device nec-usb-xhci,id=xhci
  -global nec-usb-xhci.msi=off
  -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off
  # -device usb-host,vendorid=0x8086,productid=0x0808  # 2 USD USB Sound Card
  # -device usb-host,vendorid=0x1b3f,productid=0x2008  # Another 2 USD USB Sound Card
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly=on,file="$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="$REPO_PATH/$OVMF_DIR/OVMF_VARS-1920x1080.fd"
  -smbios type=2
  # -device ich9-intel-hda 
  # -device hda-duplex
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
  # change to 6 if using emily
  # -drive id=MacHDDPtr,if=none,file="/home/peter/src/mac_hdd_peter.img",format=qcow2
  # -device ide-hd,bus=sata.5,drive=MacHDDPtr
  # end peter test
  # --------------------------------------------------------------------------------
  # Peter emily hdd
  # -device ide-hd,bus=sata.5,drive=Spinning
  # -drive id=Spinning,if=none,file="/dev/sda2",format=raw
  # end emily hdd
  # --------------------------------------------------------------------------------
  # Peter Seagate usb hdd
  # change to 6 if using emily
  # -device ide-hd,bus=sata.5,drive=pm-TimeMachine
  # -drive id=pm-TimeMachine,if=none,file="/dev/sdd1",format=raw
  # end Seagate usb hdd
  # --------------------------------------------------------------------------------
  # Peter sonoma tst
  # -drive id=SonomaHDD,if=none,file="/mnt/apple/pm-sonoma.img",format=qcow2
  # -device ide-hd,bus=sata.5,drive=SonomaHDD
  # --------------------------------------------------------------------------------
  # Peter - Windows disk
  # change to 6 if using emily
  # -device ide-hd,bus=sata.5,drive=Windows
  # -drive id=Windows,if=none,file="/dev/sdc",format=raw
  # end Windows disk
  # --------------------------------------------------------------------------------
  # -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  # -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  # -netdev user,id=net0 -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  # -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27  # Note: Use this line for High Sierra
  # next 2 commented out Peter Dec 13th, 2023
  # -monitor stdio
  # -device vmware-svga,vgamem_mb=64
  # my nVidia 2nd card for VGA PAssthrough
  # get id's by running:
  # lspci -nn | grep "VGA\|Audio"
  # 04:00.0 VGA compatible controller [0300]: NVIDIA Corporation GT218 [GeForce 210] [10de:0a65] (rev a2)
  # The first value (04:00.0) is the BDF ID, and the last (10de:0a65) is the Device ID. Cards with a built-in audio controller have to be passed together, so note the IDs for both subdevices.
  # -------------------------------------------------------------------------
  # -vga std \
  #  -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1 \
  #  -device vfio-pci,host=04:00.0,bus=port.1,multifunction=on \
    # -device vfio-pci,host=04:00.0,bus=port.1,multifunction=on,romfile=/path/to/card.rom \
  #  -device vfio-pci,host=04:00.1,bus=port.1 \
  # -------------------------------------------------------------------------
  # -vga qxl 
  #  -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1 \
  #  -device vfio-pci,host=26:00.0,bus=port.1,multifunction=on,romfile=/path/to/card.rom \
  #  -device vfio-pci,host=26:00.1,bus=port.1 \
  # from the boot-passthrough.sh script
  # -device vfio-pci,host=04:00.0,multifunction=on,romfile="$REPO_PATH/my-nvidia.rom"
  # -audiodev '{"id":"audio1","driver":"spice"}' 
  # -spice port=5900,addr=127.0.0.1,disable-ticketing=on,image-compression=off,seamless-migration=on 
  # -vga qxl 
 
 -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=64,vgamem_mb=64,max_outputs=1,bus=pcie.0 \
  -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1
  -device vfio-pci,host=04:00.0,bus=port.1,multifunction=on
  -device vfio-pci,host=04:00.1,bus=port.1


  
  # -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=16,max_outputs=1,bus=pcie.0 \
  # -device ich9-intel-hda,id=sound0,bus=pcie.0,addr=0x1b \
  # -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0,audiodev=audio1 \
  # -chardev spicevmc,id=charredir0,name=usbredir \
  # -device usb-redir,chardev=charredir0,id=redir0,bus=usb.0,port=2 \
  # -chardev spicevmc,id=charredir1,name=usbredir \
  # -device usb-redir,chardev=charredir1,id=redir1,bus=usb.0,port=3 \
  # -device vfio-pci,host=0000:04:00.0,id=hostdev0,bus=pci.5,addr=0x0 \
  # -device vfio-pci,host=0000:04:00.1,id=hostdev1,bus=pci.6,addr=0x0 \




  # next is NIC
  # <!-- 0000:05:00:0 Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller-->
  #  <hostdev mode="subsystem" type="pci" managed="yes">
  #    <source>
  #      <address domain="0x0000" bus="0x05" slot="0x00" function="0x0"/>
  #    </source>
  #    <address type="pci" domain="0x0000" bus="0x09" slot="0x00" function="0x0"/>
  #  </hostdev>
  #  <!-- end NIC block -->
  -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,  
	# -vnc 0.0.0.0:1,password -k en-us
	# -vnc 0.0.0.0:1 -k en-us
)

qemu-system-x86_64 "${args[@]}"

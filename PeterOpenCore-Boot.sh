#!/usr/bin/env bash

# orig repo:
# https://github.com/kholia/OSX-KVM.git

# Special thanks to:
# https://github.com/Leoyzen/KVM-Opencore
# https://github.com/thenickdude/KVM-Opencore/
# https://github.com/qemu/qemu/blob/master/docs/usb2.txt
# -------------------------------------------------------
# Peter here.
# read the following:
# If you're using my script PeterOpenCore-Boot.sh ? choose Ventura when you run fetch-macOS-v2.py below
# If you're going to run the stock OpenCore-Boot-macOS.sh or OpenCore-Boot.sh ?
# Try Sonoma - it may actually work.
# I know i got it working once.
#
# after running fetch-macOS-v2.py, do the next 2
#
# dmg2img -i BaseSystem.dmg BaseSystem.img
# qemu-img create -f qcow2 mac_hdd_ng.img 750G
#
# 750G is expected size you might go to. 
#
# Next used to be required - i haven't needed to, Peter
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)
#  
#  The rest of the settings are specific to me.
#  Check the stock OpenCore-Boot-macOS.sh or OpenCore-Boot.sh 
#  And use vindiff or VS Code and compare and experiment.
#  email me peter.moore350@gmail.com email subject "macOS on qemu"
#  i'll do my best.
#  cheers
#

############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

# ALLOCATED_RAM="24576" # MiB
ALLOCATED_RAM="16384" # MiB
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
  -usb 
  -device usb-kbd 
  -device usb-tablet
  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS"
  # -device usb-ehci,id=ehci
  # -device usb-kbd,bus=ehci.0
  # -device usb-mouse,bus=ehci.0
  # -device nec-usb-xhci,id=xhci
  # <controller type="usb" index="0" model="qemu-xhci" ports="15">
  #    <address type="pci" domain="0x0000" bus="0x02" slot="0x00" function="0x0"/>
  #  </controller>
  #  Peter Oct 2
  # -global nec-usb-xhci.msi=off
  # -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off
  -device qemu-xhci,id=xhci
  -global nec-usb-xhci.msi=off
  -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off
  # End Peter
  # -device usb-host,vendorid=0x8086,productid=0x0808  # 2 USD USB Sound Card
  # -device usb-host,vendorid=0x1b3f,productid=0x2008  # Another 2 USD USB Sound Card
  -device usb-host,vendorid=0x1c75,productid=0x0219  # Arturia Keystep 37
  -device usb-host,vendorid=0xfc02,productid=0x0101  # USB MIDI plugged into H&K GMD40
  -device usb-host,vendorid=0x08bb,productid=0x2902  # The mixer (Texas Instruments PCM2902)
  # These are commented out because i actually use them in Linux and passing them through
  # to the macOS Ventura VM will cause issues on the underlying Linux host.
  # The mixer above is actually switched off in Linux as i'm using HDMI out for sound on Linux.
  # The sound works fine in the macOS VM, but somethimes you have t select it which is fine.
  # -device usb-host,vendorid=0x1edb,productid=0xbe49  # ATEM Mini
  # -device usb-host,vendorid=0x046d,productid=0x085e  # Logitech BRIO
  # -device usb-host,vendorid=0x0fd9,productid=0x0060  # Elgato Stream Deck



  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly=on,file="$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="$REPO_PATH/$OVMF_DIR/OVMF_VARS-1920x1080.fd"
  -smbios type=2
  # -device ich9-intel-hda 
  # -device hda-duplex
  -device ich9-ahci,id=sata
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore/OpenCore.qcow2"
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot
  # -----------------------------------------------
  # Re-enable this is recovering/installing Peter Oct 1, 2024
  # -device ide-hd,bus=sata.3,drive=InstallMedia
  # -----------------------------------------------
  -drive id=InstallMedia,if=none,file="$REPO_PATH/BaseSystem.img",format=raw
  -drive id=MacHDDNew,if=none,file="$REPO_PATH/mac_hdd_ng.img",format=qcow2
  -device ide-hd,bus=sata.4,drive=MacHDDNew
  # --------------------------------------------------------------------------------
  # Peter emily hdd
  # -device ide-hd,bus=sata.5,drive=Spinning
  # -drive id=Spinning,if=none,file="/dev/sda2",format=raw
  # end emily hdd
  # --------------------------------------------------------------------------------
  # Peter Seagate usb hdd
  # change if using emily and check line 61 and comment out the InstallMedia line
  -device ide-hd,bus=sata.5,drive=pmTimeMachine
  -drive id=pmTimeMachine,if=none,file="/dev/sdd",format=raw
  # end Seagate usb hdd
  # --------------------------------------------------------------------------------
  # Peter - Windows disk
  # change if using emily
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
   -vga qxl 
#   qxl driver uses ram_size_mb, vram_size_mb, and vram64_size_mb
#   Peter Oct 7, 2024 - next line didt seem to work but it didn't break anything
#   maybe play around with removing id= and bus=
  -device qxl,id=video0,ram_size=67108864,ram_size_mb=64,vram_size=67108864,vram64_size_mb=64,vgamem_mb=64,max_outputs=1,bus=pcie.0 
  #  -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1 \
  #  # -device vfio-pci,host=26:00.0,bus=port.1,multifunction=on,romfile=/path/to/card.rom \
  #  -device vfio-pci,host=18:00.0,bus=port.1,multifunction=on \
  #  -device vfio-pci,host=18:00.1,bus=port.1 \
  # from the boot-passthrough.sh script
  # -device vfio-pci,host=04:00.0,multifunction=on,romfile="$REPO_PATH/my-nvidia.rom"
  # -audiodev '{"id":"audio1","driver":"spice"}' 
  # -spice port=5900,addr=127.0.0.1,disable-ticketing=on,image-compression=off,seamless-migration=on 
  # -vga qxl 
 # Peter Spt 11, 2024 commented out
 # -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=64,vgamem_mb=64,max_outputs=1,bus=pcie.0 \
 # -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1
 # -device vfio-pci,host=04:00.0,bus=port.1,multifunction=on
 # -device vfio-pci,host=04:00.1,bus=port.1
 # Peter Spt 11, 2024 end commented out
  # -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=16,max_outputs=1,bus=pcie.0 \
  # -device ich9-intel-hda,id=sound0,bus=pcie.0,addr=0x1b \
  # -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0,audiodev=audio1 \
  # -chardev spicevmc,id=charredir0,name=usbredir \
  # -device usb-redir,chardev=charredir0,id=redir0,bus=usb.0,port=2 \
  # -chardev spicevmc,id=charredir1,name=usbredir \
  # -device usb-redir,chardev=charredir1,id=redir1,bus=usb.0,port=3 \
  # -device vfio-pci,host=0000:04:00.0,id=hostdev0,bus=pci.5,addr=0x0 \
  # -device vfio-pci,host=0000:04:00.1,id=hostdev1,bus=pci.6,addr=0x0 \
  #################################################################################################################
  # USB devices in the ports i usually use them in, Go to Line 48 to use them                                     #
  #################################################################################################################
  # 003:007 Arturia KeyStep 37
  # <hostdev mode="subsystem" type="usb" managed="yes">
  # <source>
  #   <vendor id="0x1c75"/>
  #   <product id="0x0219"/>
  # </source>
  # <address type="usb" bus="0" port="4"/>
  # </hostdev>
  #################################################################################################################
  # 003:002 0xfc02 USB MIDI Interface (plugged in to the H&K Grand Meister Deluxe 40)
  # <hostdev mode="subsystem" type="usb" managed="yes">
  # <source>
  #   <vendor id="0xfc02"/>
  #   <product id="0x0101"/>
  # </source>
  # <address type="usb" bus="0" port="5"/>
  # </hostdev>
  #################################################################################################################
  # 005:002 Blackmagic Design - ATEM Mini
  # <hostdev mode="subsystem" type="usb" managed="yes">
  # <source>
  #   <vendor id="0x1edb"/>
  #   <product id="0xbe49"/>
  # </source>
  # <address type="usb" bus="0" port="6"/>
  # </hostdev>
  #################################################################################################################
  # 005:004 Elgato Systems GmbH Stream Deck
  # <hostdev mode="subsystem" type="usb" managed="yes">
  # <source>
  #   <vendor id="0x0fd9"/>
  #   <product id="0x0060"/>
  # </source>
  # <address type="usb" bus="0" port="7"/>
  # </hostdev>
  #################################################################################################################
  # 006:002 Logitech BRIO Ultra HD Webcam
  # <hostdev mode="subsystem" type="usb" managed="yes">
  # <source>
  #   <vendor id="0x046d"/>
  #   <product id="0x085e"/>
  # </source>
  # <address type="usb" bus="0" port="8"/>
  # </hostdev>
  #################################################################################################################
  # 001:003 Texas Instruments PCM2902 Audio Codec - the USB to the Xenyx QX1222 USB Mixer
  # <hostdev mode="subsystem" type="usb" managed="yes">
  # <source>
  #   <vendor id="0x08bb"/>
  #   <product id="0x2902"/>
  # </source>
  # <address type="usb" bus="0" port="9"/>
  # </hostdev>
  #
  #
  #
  #
  #################################################################################################################
  # You can get the list of the devices that is possible to add to the VM by running the following command (print a list of QEMU supported devices by category):

# qemu-system-x86_64 -device help

# Additionally, the options per device can be determined by running:

# qemu-system-x86_64 -device device_name,help
#################################################################################################################
# qemu-system-x86_64 -device qxl,help
# qxl options:
#   acpi-index=<uint32>    -  (default: 0)
#   addr=<int32>           - Slot and optional function number, example: 06.0 or 06 (default: -1)
#   cmdlog=<uint32>        -  (default: 0)
#   debug=<uint32>         -  (default: 0)
#   failover_pair_id=<str>
#   global-vmstate=<bool>  -  (default: false)
#   guestdebug=<uint32>    -  (default: 0)
#   max_outputs=<uint16>   -  (default: 0)
#   multifunction=<bool>   - on/off (default: false)
#   ram_size=<uint32>      -  (default: 67108864)
#   ram_size_mb=<uint32>   -  (default: 4294967295)
#   revision=<uint32>      -  (default: 5)
#   rombar=<uint32>        -  (default: 1)
#   romfile=<str>
#   romsize=<uint32>       -  (default: 4294967295)
#   surfaces=<int32>       -  (default: 1024)
#   vgamem_mb=<uint32>     -  (default: 16)
#   vram64_size_mb=<uint32> -  (default: 4294967295)
#   vram_size=<uint64>     -  (default: 67108864)
#   vram_size_mb=<uint32>  -  (default: 4294967295)
#   x-pcie-ari-nextfn-1=<bool> - on/off (default: false)
#   x-pcie-err-unc-mask=<bool> - on/off (default: true)
#   x-pcie-extcap-init=<bool> - on/off (default: true)
#   x-pcie-lnksta-dllla=<bool> - on/off (default: true)
#   xres=<uint32>          -  (default: 0)
#   yres=<uint32>          -  (default: 0)
#
#################################################################################################################



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

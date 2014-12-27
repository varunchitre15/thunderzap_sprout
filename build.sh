 #
 # Copyright © 2014, Varun Chitre "varun.chitre15" <varun.chitre15@gmail.com>
 #
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #
KERNEL_DIR=$PWD
ZIMAGE=$KERNEL_DIR/arch/arm/boot/zImage
MKBOOTIMG=$KERNEL_DIR/tools/mkbootimg
MKBOOTFS=$KERNEL_DIR/tools/mkbootfs
ROOTFS=$KERNEL_DIR/root.fs
BOOTIMG=$KERNEL_DIR/boot.img
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
# Modify the following variable if you want to build
export CROSS_COMPILE="/root/cm11/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7/bin/arm-eabi-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="varun.chitre15"
export KBUILD_BUILD_HOST="Monster-Machine"

compile_kernel ()
{
echo -e "$blue***********************************************"
echo "          Compiling ThunderZap kernel          "
echo -e "***********************************************$nocol"
make sprout_defconfig
make -j32
if ! [ -a $ZIMAGE ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
}

compile_bootimg ()
{
echo -e "$yellow*************************************************"
echo "             Creating boot image for $2"
echo -e "*************************************************$nocol"
$MKBOOTFS $1/ > $KERNEL_DIR/ramdisk.cpio
cat $KERNEL_DIR/ramdisk.cpio | gzip > $KERNEL_DIR/root.fs
$MKBOOTIMG --kernel $ZIMAGE --ramdisk $KERNEL_DIR/root.fs  --base 0x80000000 --kernel_offset 0x00008000 --ramdisk_offset 0x04000000 --tags_offset 0x00000100 --output $KERNEL_DIR/boot.img
if ! [ -a $ROOTFS ];
then
echo -e "$redRamdisk creation failed$nocol"
exit 1
fi
if ! [ -a $BOOTIMG ];
then
echo -e "$redBoot image creation failed$nocol"
exit 1
fi
finally_done
}

finally_done ()
{
echo -e "$cyan BOOT Image installed on: $BOOTIMG$nocol"
}

case $1 in
cm11)
compile_kernel
compile_bootimg ramdisk-cm11 CM11
;;
stock)
compile_kernel
compile_bootimg ramdisk Stock
;;
cm12)
compile_kernel
compile_bootimg ramdisk-cm12 CM12
;;
clean)
make ARCH=arm -j8 clean mrproper
rm -rf $KERNEL_DIR/ramdisk.cpio $KERNEL_DIR/root.fs $KERNEL_DIR/boot.img
rm -rf include/linux/autoconf.h
;;
*)
echo -e "Add valid option\nValid options are:\n./build.sh (stock|cm11|cm12|clean)"
exit 1
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"

KERNEL_DIR=$PWD
ZIMAGE=$KERNEL_DIR/arch/arm/boot/zImage
make ARCH=arm CROSS_COMPILE=/root/cm11/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7/bin/arm-eabi- -j8 clean mrproper
rm $KERNEL_DIR/ramdisk.cpio $KERNEL_DIR/root.fs $KERNEL_DIR/boot.img
rm include/linux/autoconf.h

KERNEL_DIR=$PWD
ZIMAGE=$KERNEL_DIR/arch/arm/boot/zImage
MKBOOTIMG=$KERNEL_DIR/tools/mkbootimg
MKBOOTFS=$KERNEL_DIR/tools/mkbootfs
ROOTFS=$KERNEL_DIR/root.fs
BUILD_START=$(date +"%s")
export CROSS_COMPILE="/root/cm11/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7/bin/arm-eabi-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="varun.chitre15"
export KBUILD_BUILD_HOST="Monster-Machine"

compile_kernel ()
{
make sprout_defconfig
make -j32
if ! [ -a $ZIMAGE ];
then
echo "Kernel Compilation failed! Fix the errors!"
exit 1
fi
}

compile_bootimg ()
{
echo "Creating boot image for $2"
$MKBOOTFS $1/ > $KERNEL_DIR/ramdisk.cpio
cat $KERNEL_DIR/ramdisk.cpio | gzip > $KERNEL_DIR/root.fs
$MKBOOTIMG --kernel $ZIMAGE --ramdisk $KERNEL_DIR/root.fs  --base 0x80000000 --kernel_offset 0x00008000 --ramdisk_offset 0x04000000 --tags_offset 0x00000100 --output $KERNEL_DIR/boot.img
if ! [ -a $ROOTFS ];
then
echo "Ramdisk creation failed"
exit 1
fi
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
echo "Add valid option"
exit 1
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

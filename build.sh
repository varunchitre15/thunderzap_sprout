KERNEL_DIR=$PWD
ZIMAGE=$KERNEL_DIR/arch/arm/boot/zImage
MKBOOTIMG=$KERNEL_DIR/tools/mkbootimg
MKBOOTFS=$KERNEL_DIR/tools/mkbootfs
BUILD_START=$(date +"%s")
if [ -a $ZIMAGE ];
then
rm $ZIMAGE $KERNEL_DIR/ramdisk.cpio $KERNEL_DIR/root.fs $KERNEL_DIR/boot.img
fi
export CROSS_COMPILE="/root/cm11/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7/bin/arm-eabi-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="varun.chitre15"
export KBUILD_BUILD_HOST="Monster-Machine"
make sprout_defconfig
make
if [ -a $ZIMAGE ];
then
echo "Creating boot image"
$MKBOOTFS ramdisk/ > $KERNEL_DIR/ramdisk.cpio
cat $KERNEL_DIR/ramdisk.cpio | gzip > $KERNEL_DIR/root.fs
$MKBOOTIMG --kernel $ZIMAGE --ramdisk $KERNEL_DIR/root.fs  --base 0x80000000 --kernel_offset 0x00008000 --ramdisk_offset 0x04000000 --tags_offset 0x00000100 --output $KERNEL_DIR/boot.img
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
else
echo "Compilation failed! Fix the errors!"
fi

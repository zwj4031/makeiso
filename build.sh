#!/usr/bin/env sh
echo -n "checking for gettext ... "
if [ -e "$(which msgfmt)" ]
then
    echo "ok"
else
    echo "not found\nPlease install gettext."
    exit
fi
echo -n "checking for xorriso ... "
if [ -e "$(which xorriso)" ]
then
    echo "ok"
else
    echo "not found\nPlease install xorriso."
    exit
fi
echo -n "checking for grub ... "
if [ -e "$(which grub-mkimage)" ]
then
    echo "ok"
else
    echo "not found\nPlease install grub."
    exit
fi
echo -n "checking for mtools ... "
if [ -e "$(which mtools)" ]
then
    echo "ok"
else
    echo "not found\nPlease install mtools."
    exit
fi

if [ -d "build" ]
then
    rm -r build
fi
mkdir build

echo "common files"
cp -r boot build/

cp grub/locale/*.mo build/boot/grubfm/locale/
cd lang
for po in */fm.po; do
  msgfmt ${po} -o ../build/boot/grubfm/locale/fm/${po%/*}.mo
done
cd ..

echo "Language"
echo "1. Simplified Chinese"
echo "2. Traditional Chinese"
echo "3. English (United States)"
echo "4. Turkish"
echo "5. German"
echo "6. Vietnamese"
echo "7. Russian"
echo "8. Hebrew"
echo "9. Spanish"
echo "10. Polish"
echo "11. Ukrainian"
echo "12. French"
read -p "Please make a choice: " choice
case "$choice" in
    2)
        echo "zh_TW"
        cp lang/zh_TW/lang.sh build/boot/grubfm/
        ;;
    3)
        echo "en_US"
        ;;
    4)
        echo "tr_TR"
        cp lang/tr_TR/lang.sh build/boot/grubfm/
        ;;
    5)
        echo "de_DE"
        cp lang/de_DE/lang.sh build/boot/grubfm/
        ;;
    6)
        echo "vi_VN"
        cp lang/vi_VN/lang.sh build/boot/grubfm/
        ;;
    7)
        echo "ru_RU"
        cp lang/ru_RU/lang.sh build/boot/grubfm/
        ;;
    8)
        echo "he_IL"
        cp lang/he_IL/lang.sh build/boot/grubfm/
        ;;
    9)
        echo "es_ES"
        cp lang/es_ES/lang.sh build/boot/grubfm/
        ;;
    10)
        echo "pl_PL"
        cp lang/pl_PL/lang.sh build/boot/grubfm/
        ;;
    11)
        echo "uk_UA"
        cp lang/uk_UA/lang.sh build/boot/grubfm/
        ;;
    12)
        echo "fr_FR"
        cp lang/fr_FR/lang.sh build/boot/grubfm/
        ;;
    *)
        echo "zh_CN"
        cp lang/zh_CN/lang.sh build/boot/grubfm/
        ;;
esac

echo "x86_64-efi"
mkdir build/boot/grubfm/x86_64-efi
for modules in $(cat arch/x64/optional.lst)
do
    echo "copying ${modules}.mod"
    cp grub/x86_64-efi/${modules}.mod build/boot/grubfm/x86_64-efi/
done
cp arch/x64/*.efi build/boot/grubfm
cp arch/x64/*.gz build/boot/grubfm
cd build
find ./boot | cpio -o -H newc > ./memdisk.cpio
cd ..
rm -r build/boot/grubfm/x86_64-efi
rm build/boot/grubfm/*.efi
rm build/boot/grubfm/*.gz
modules=$(cat arch/x64/builtin.lst)
grub-mkimage -m ./build/memdisk.cpio -d ./grub/x86_64-efi -p "(memdisk)/boot/grubfm" -c arch/x64/config.cfg -o grubfmx64.efi -O x86_64-efi $modules

echo "i386-efi"
mkdir build/boot/grubfm/i386-efi
for modules in $(cat arch/ia32/optional.lst)
do
    echo "copying ${modules}.mod"
    cp grub/i386-efi/${modules}.mod build/boot/grubfm/i386-efi/
done
cp arch/ia32/*.efi build/boot/grubfm
cp arch/ia32/*.gz build/boot/grubfm
cd build
find ./boot | cpio -o -H newc > ./memdisk.cpio
cd ..
rm -r build/boot/grubfm/i386-efi
rm build/boot/grubfm/*.efi
rm build/boot/grubfm/*.gz
modules=$(cat arch/ia32/builtin.lst)
grub-mkimage -m ./build/memdisk.cpio -d ./grub/i386-efi -p "(memdisk)/boot/grubfm" -c arch/ia32/config.cfg -o grubfmia32.efi -O i386-efi $modules
rm build/memdisk.cpio

echo "i386-pc"
builtin=$(cat arch/legacy/builtin.lst) 
mkdir build/boot/grubfm/i386-pc
modlist="$(cat arch/legacy/insmod.lst) $(cat arch/legacy/optional.lst)"
for modules in $modlist
do
    echo "copying ${modules}.mod"
    cp grub/i386-pc/${modules}.mod build/boot/grubfm/i386-pc/
done
cp arch/legacy/insmod.lst build/boot/grubfm/
cp arch/legacy/grub.exe build/boot/grubfm/
cp arch/legacy/duet64.iso build/boot/grubfm/
cp arch/legacy/memdisk build/boot/grubfm/
cp arch/legacy/*.gz build/boot/grubfm/
cd build
find ./boot | cpio -o -H newc | gzip -9 > ./fm.loop
cd ..
rm -r build/boot
grub-mkimage -d ./grub/i386-pc -p "(memdisk)/boot/grubfm" -c arch/legacy/config.cfg -o ./build/core.img -O i386-pc $builtin
cat grub/i386-pc/cdboot.img build/core.img > build/fmldr
rm build/core.img
cp arch/legacy/MAP build/
cp -r arch/legacy/ntboot/* build/
touch build/ventoy.dat

xorriso -as mkisofs -R -hide-joliet boot.catalog -b fmldr -no-emul-boot -allow-lowercase -boot-load-size 4 -boot-info-table -o grubfm.iso build

dd if=/dev/zero of=build/efi.img bs=1M count=16
mkfs.vfat build/efi.img
mmd -i build/efi.img ::EFI
mmd -i build/efi.img ::EFI/BOOT
mcopy -i build/efi.img grubfmx64.efi ::EFI/BOOT/BOOTX64.EFI
mcopy -i build/efi.img grubfmia32.efi ::EFI/BOOT/BOOTIA32.EFI
xorriso -as mkisofs -R -hide-joliet boot.catalog -b fmldr -no-emul-boot -allow-lowercase -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e efi.img -no-emul-boot -o grubfm_multiarch.iso build

rm -r build

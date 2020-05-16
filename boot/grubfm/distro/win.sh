source ${prefix}/func.sh;

function auto_swap {
  if regexp '^hd[0-9a-zA-Z,]+$' ${grubfm_disk};
  then
    regexp -s devnum '^hd([0-9]+).*$' ${grubfm_disk};
    if test "devnum" != "0";
    then
      drivemap -s (hd0) (${grubfm_disk});
    fi;
  fi;
}

if [ -z "${grubfm_startbat}" -o ! -f "${grubfm_startbat}" ];
then
  set grubfm_startbat="(install)/start.bat";
fi;

function win_isoboot {
  set lang=en_US;
  terminal_output console;
  set installiso="${grubfm_path}";
  tr --set=installiso "/" "\\";
  loopback -m envblk ${prefix}/null.cpio;
  save_env -s -f (envblk)/null.cfg installiso;
  cat (envblk)/null.cfg;
  loopback wimboot ${prefix}/wimboot.gz;
  loopback install ${prefix}/install.gz;
  if [ "$grub_platform" = "pc" ];
  then
    set enable_progress_indicator=1;
    linux16 (wimboot)/wimboot;
    if [ -z "${2}" ];
    then
      initrd16 newc:bootmgr:(wimboot)/bootmgr \
               newc:bootmgr.exe:(wimboot)/bootmgr.exe \
               newc:bcd:(wimboot)/bcd \
               newc:boot.sdi:(wimboot)/boot.sdi \
               newc:null.cfg:(envblk)/null.cfg \
               newc:mount_x64.exe:(install)/mount_x64.exe \
               newc:mount_x86.exe:(install)/mount_x86.exe \
               newc:start.bat:${grubfm_startbat} \
               newc:winpeshl.ini:(install)/winpeshl.ini \
               newc:boot.wim:"${1}";
    else
      initrd16 newc:bootmgr:(wimboot)/bootmgr \
               newc:bootmgr.exe:(wimboot)/bootmgr.exe \
               newc:bcd:(wimboot)/bcd \
               newc:boot.sdi:(wimboot)/boot.sdi \
               newc:null.cfg:(envblk)/null.cfg \
               newc:mount_x64.exe:(install)/mount_x64.exe \
               newc:mount_x86.exe:(install)/mount_x86.exe \
               newc:start.bat:${grubfm_startbat} \
               newc:winpeshl.ini:(install)/winpeshl.ini \
               newc:autounattend.xml:"${2}" \
               newc:boot.wim:"${1}";
    fi;
    auto_swap;
    set gfxmode=1920x1080,1366x768,1024x768,800x600,auto;
    terminal_output gfxterm;
    boot;
  else
    if [ -z "${2}" ];
    then
      wimboot @:bootmgfw.efi:(wimboot)/bootmgfw.efi \
              @:bcd:(wimboot)/bcd \
              @:boot.sdi:(wimboot)/boot.sdi \
              @:null.cfg:(envblk)/null.cfg \
              @:mount_x64.exe:(install)/mount_x64.exe \
              @:mount_x86.exe:(install)/mount_x86.exe \
              @:start.bat:${grubfm_startbat} \
              @:winpeshl.ini:(install)/winpeshl.ini \
              @:boot.wim:"${1}";
    else
      wimboot @:bootmgfw.efi:(wimboot)/bootmgfw.efi \
              @:bcd:(wimboot)/bcd \
              @:boot.sdi:(wimboot)/boot.sdi \
              @:null.cfg:(envblk)/null.cfg \
              @:mount_x64.exe:(install)/mount_x64.exe \
              @:mount_x86.exe:(install)/mount_x86.exe \
              @:start.bat:${grubfm_startbat} \
              @:winpeshl.ini:(install)/winpeshl.ini \
              @:autounattend.xml:"${2}" \
              @:boot.wim:"${1}";
    fi;
  fi;
}

function xml_list {
  # autounattend.xml
  if [ -f "(${grubfm_device})${grubfm_dir}"*.xml ];
  then
    clear_menu;
    menuentry $"Install Windows without autounattend.xml" "${1}" --class nt6 {
      win_isoboot "${2}";
    }
    for xml in "(${grubfm_device})${grubfm_dir}"*.xml;
    do
      regexp --set=1:xml_name '^.*/(.*)$' "${xml}";
      menuentry $"Load ${xml_name}" "${1}" "${xml}" --class nt6 {
        win_isoboot "${2}" "${3}";
      }
    done;
    source ${prefix}/global.sh;
  else
    win_isoboot "${1}";
  fi;
}

if test -f (loop)/sources/boot.wim; then
  xml_list "(loop)/sources/boot.wim";
else
  if test -f (loop)/x64/sources/boot.wim; then
    menuentry $"Install Windows (x64)" --class nt6 {
      xml_list "(loop)/x64/sources/boot.wim";
    }
  fi;
  if test -f (loop)/x86/sources/boot.wim; then
    menuentry $"Install Windows (x86)" --class nt6 {
      xml_list "(loop)/x86/sources/boot.wim";
    }
  fi;
  source ${prefix}/global.sh;
fi;

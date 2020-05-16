source ${prefix}/func.sh;
if [ -f "${theme_fm}" ];
then
  export theme=${theme_fm};
fi;

hiddenentry "[F1] HELP" --hotkey f1 {
  configfile ${prefix}/help.sh;
}

hiddenentry "[F2] ${grubfm_name}" --hotkey f2 {
  grubfm_open "${grubfm_file}";
}

hiddenentry "[F3] OS DETECT" --hotkey f3 {
  configfile ${prefix}/osdetect.sh;
}

hiddenentry "[F4] SETTINGS" --hotkey f4 {
  configfile ${prefix}/settings.sh;
}

hiddenentry "[F5] PXE BOOT MENU" --hotkey f5 {
  configfile ${prefix}/netboot.sh;
}

hiddenentry "[F6] POWER OFF" --hotkey f6 {
  configfile ${prefix}/power.sh;
}

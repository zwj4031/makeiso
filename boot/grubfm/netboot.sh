source $prefix/global.sh;

function gpudriver {

menuentry $"vesa" --class screen {
export gpu_driver=vesa; configfile $prefix/netboot.sh
}


menuentry $"default" --class screen {
export gpu_driver=default; configfile $prefix/netboot.sh
}


menuentry $"modesetting" --class screen {
export gpu_driver=modesetting; configfile $prefix/netboot.sh
}


menuentry $"fbdev" --class screen {
export gpu_driver=fbdev; configfile $prefix/netboot.sh
}

}




menuentry $"启动netcopy 网络同传接收端[旧版]" --class slackware {
echo wait........;
export enable_progress_indicator=1;
 linux ($linux)/linux/vmlinuz netcopymode=1 netcopyold=1 guiexec=netcopy kernel_parameters=debug gpu_driver=$gpu_driver
 initrd ($linux)/linux/initrd.xz;
}

menuentry $"启动netcopy 网络同传接收端[新版]" --class slackware {
echo wait........;
export enable_progress_indicator=1;
 linux ($linux)/linux/vmlinuz netcopymode=1 guiexec=netcopy kernel_parameters=debug gpu_driver=$gpu_driver
 initrd ($linux)/linux/initrd.xz;
}

menuentry $"启动传统ghost网络克隆客户端[会话名mousedos]" --class ghost {
echo wait........;
export enable_progress_indicator=1;
 linux ($linux)/linux/vmlinuz guiexec=netghost kernel_parameters=debug gpu_driver=$gpu_driver
 initrd ($linux)/linux/initrd.xz;
}


menuentry $"启动porteus 网启服务器[发送端][dhcp]" --class slackware {
echo wait........;
export enable_progress_indicator=1;
 linux ($linux)/linux/vmlinuz myip=169.254.1.1 netcopyold=1 guiexec=netcopy pxe kernel_parameters=debug gpu_driver=$gpu_driver
 initrd ($linux)/linux/initrd.xz;
}

menuentry $"启动porteus 网启服务器[发送端][proxydhcp]" --class slackware {
echo wait........;
export enable_progress_indicator=1;
 linux ($linux)/linux/vmlinuz guiexec=netcopy pxe netcopyold=1 kernel_parameters=debug gpu_driver=$gpu_driver
 initrd ($linux)/linux/initrd.xz;
}

#menuentry $"启动porteus 旧内核[可输入中文]" --class slackware {
#echo wait........;
#export enable_progress_indicator=1;
# mkinitrd -c a ($linux)/linux/initrd.xz;
# mkinitrd -a a ($linux)/linux/init init;
# mkinitrd -a a ($linux)/linux/old old;
# linux ($linux)/linux/oldvmlinuz kernel_parameters=debug gpu_driver=$gpu_driver;
# initrd (a)
#}



menuentry $"切换兼容性(启动失败请尝试)[当前:$gpu_driver]" --class screen {
 clear_menu; gpudriver;
}



menuentry $"(在线安装Linux)  [网络] $arch" --class gnu-linux {
set lang=en_US; terminal_output console;
net_dhcp;
echo wait...................;
$chain (http,boot.netboot.xyz)/ipxe/$netbootxyz
}

menuentry $"本地" --class hdd {
 netboot; grubfm_set --boot 0; clear_menu; grubfm;
}

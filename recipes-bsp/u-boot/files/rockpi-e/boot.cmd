# DO NOT EDIT THIS FILE
#
# Please edit /boot/uEnv.txt to set supported parameters
#

setenv load_addr "0x05000000"
setenv overlay_error "false"
# default values
setenv overlay_prefix "rockchip"
setenv verbosity "1"
setenv console " "
setenv rootfstype "ext4"
setenv docker_optimizations "on"

echo "Boot script loaded from ${devtype} ${devnum}"

if test -e ${devtype} ${devnum}:4 ${prefix}uEnv.txt; then
	load ${devtype} ${devnum}:4 ${load_addr} ${prefix}uEnv.txt
	env import -t ${load_addr} ${filesize}
fi

setenv bootargs "console=tty1 console=${console} rw root=PARTUUID=${rootuuid} rootfstype=${rootfstype} init=/sbin/init rootwait"

if test "${docker_optimizations}" = "on"; then setenv bootargs "${bootargs} cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1"; fi

load ${devtype} ${devnum}:4 ${kernel_addr_r} ${prefix}${kernelimg}

load ${devtype} ${devnum}:4 ${fdt_addr_r} ${prefix}${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536
for overlay_file in ${overlays}; do
	if load ${devtype} ${devnum}:4 ${load_addr} ${prefix}overlays/${overlay_file}.dtbo; then
		echo "Applying kernel provided DT overlay ${overlay_file}.dtbo"
		fdt apply ${load_addr} || setenv overlay_error "true"
	fi
done
for overlay_file in ${user_overlays}; do
	if load ${devtype} ${devnum}:4 ${load_addr} ${prefix}overlay-user/${overlay_file}.dtbo; then
		echo "Applying user provided DT overlay ${overlay_file}.dtbo"
		fdt apply ${load_addr} || setenv overlay_error "true"
	fi
done
if test "${overlay_error}" = "true"; then
	echo "Error applying DT overlays, restoring original DT"
	load ${devtype} ${devnum}:4 ${fdt_addr_r} ${prefix}${fdtfile}
else
	if load ${devtype} ${devnum}:4 ${load_addr} ${prefix}overlays/${overlay_prefix}-fixup.scr; then
		echo "Applying kernel provided DT fixup script (${overlay_prefix}-fixup.scr)"
		source ${load_addr}
	fi
	if test -e ${devtype} ${devnum}:4 ${prefix}overlay-user/fixup.scr; then
		load ${devtype} ${devnum}:4 ${load_addr} ${prefix}overlay-user/fixup.scr
		echo "Applying user provided fixup script (overlay-user/fixup.scr)"
		source ${load_addr}
	fi
fi
booti ${kernel_addr_r} - ${fdt_addr_r}
# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr

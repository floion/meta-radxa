DEFAULT_PREFERENCE = "1"

DESCRIPTION = "Radxa CM3 IO U-Boot"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

include u-boot-rockpi.inc

SRC_URI = " \
	git://github.com/radxa/u-boot.git;branch=stable-4.19-rock3; \
	file://0001-Use-local-command.h-file-instead-of-system-file.patch \
	file://0002-Suppress-maybe-uninitialized-warning.patch \
	file://${MACHINE}/0001-to-avoid-warnings-when-compiling-with-GCC-8.1.patch \
	file://${MACHINE}/boot.cmd \
	file://${MACHINE}/uEnv.txt \
	file://${MACHINE}/idbloader.img \
	file://${MACHINE}/u-boot.itb \
"

SRCREV = "693c4cd017e57a6af8e471494be5e8780c041b08"

do_compile_append () {
	oe_runmake -C ${S} O=${B}/${config} BL31=${DEPLOY_DIR_IMAGE}/radxa-binary/bl31.elf spl/u-boot-spl.bin u-boot.dtb u-boot.itb
	./tools/mkimage -n rk3568 -T rksd -d ${DEPLOY_DIR_IMAGE}/radxa-binary/ddr.bin:spl/u-boot-spl.bin ${DEPLOY_DIR_IMAGE}/idbloader.img
}

do_deploy_append() {
	install -D -m 644 ${B}/u-boot.itb ${DEPLOYDIR}/
}

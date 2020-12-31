CROSS_COMPILE = aarch64-linux-gnu-
STARTUP_DEFS=-D__STARTUP_CLEAR_BSS -D__START=main
INCLUDE = -I.
CFLAGS  = -g -march=armv8-a -O1 -Wl,--build-id=none -nostdlib -fno-builtin $(INCLUDE)
LDSCRIPTS=-L. -T u-boot-spl.lds -lgcc
LFLAGS= $(LDSCRIPTS)

test: test.img

test.img: test.bin
	./rkbin/tools/loaderimage --pack --uboot $< $@ 0x200000 --size 1024 1
	mkimage -n rk3399 -T rksd -d ./rkbin/bin/rk33/rk3399_ddr_800MHz_v1.24.bin idbloader.img
	cat ./rkbin/bin/rk33/rk3399_miniloader_v1.26.bin >> idbloader.img
	./rkbin/tools/trust_merger trust.ini

test.bin: test.elf
	$(CROSS_COMPILE)objcopy -O binary $< $@
	$(CROSS_COMPILE)objdump -S $< > test.list

test.elf: start.S exceptions.S crt0_64.S test.c uart.c printf.c timer.c clock.c gpio.c pwm.c i2c.c spi.c mmc.c
	$(CROSS_COMPILE)gcc $(CFLAGS) $^ $(LFLAGS) -o $@

.PHONY: burn_sdcard clean test

burn_sdcard: test.img
	sudo dd if=idbloader.img of=/dev/mmcblk0 seek=64 conv=notrunc,fsync
	sudo dd if=test.img of=/dev/mmcblk0 seek=16384 conv=notrunc,fsync
	sudo dd if=trust.img of=/dev/mmcblk0 seek=24576 conv=notrunc,fsync

clean:
	rm -f *.img test.bin *.elf test.list

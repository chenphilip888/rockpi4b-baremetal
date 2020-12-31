Bare metal experiments on the ROCK PI 4B board.
Purpose: To initialize ddr, load test code from sd card to ddr and run test code from ddr.

Cross compiler used : aarch64-linux-gnu-
The following 11 tests are included: ( see below for tests summary )
1. uart test
2. led test
3. button test
4. pwm led test
5. i2c lcd test
6. tongsong
7. servo
8. spi oled test
9. ddr test
a. mmc test
b. dmac test

-------------------------------------------------------------------
To compile and flash to sd card:
cd rockpi4b-baremetal
git clone https://github.com/rockchip-linux/rkbin.git
make clean
make test
plugin a formated sd card to PC ( see below to format sd card )
make burn_sdcard
plugin the sd card to ROCK PI 4B board.
Connect ROCK PI 4B board gpio Pin 10 to serial USB cable RX.
Connect ROCK PI 4B board gpio pin 8 to serial USB cable TX. 
Connect ROCK PI 4B board gpio pin 39 to serial USB cable ground. 
Type "script ~/outputfile.txt" on PC.
Plugin serial USB cable to PC.
Type "sudo screen /dev/ttyUSB0 1500000" on PC.
Power on the ROCK PI 4B board.
It should display the test menu with 11 test items on PC.
After tests done, hit q to exit tests.
Power off the ROCK PI 4B board.
Unplug serial USB cable from PC.
Type "exit" on PC.

-------------------------------------------------------------------------
To format sd card using PC:
plugin sd card to PC.
sudo dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=1024 conv=notrunc,fsync
sudo parted -s /dev/mmcblk0 mklabel gpt
sudo parted -s /dev/mmcblk0 unit s mkpart loader1 64 8063
sudo parted -s /dev/mmcblk0 unit s mkpart loader2 16384 24575
sudo parted -s /dev/mmcblk0 unit s mkpart trust 24576 32767
sudo parted -s /dev/mmcblk0 unit s mkpart boot 32768 1081343
sudo parted -s /dev/mmcblk0 set 4 boot on
sudo parted -s /dev/mmcblk0 -- unit s mkpart rootfs 1081344 -34s
export ROOT_UUID="B921B045-1DF0-41C3-AF44-4C6F280D3FAE"
sudo gdisk /dev/mmcblk0 <<EOF
x
c
5
${ROOT_UUID}
w
y
EOF
sync
eject sd card. 
Plugin sd card to PC again.
sudo fdisk -l /dev/mmcblk0
sudo mkfs.ext4 /dev/mmcblk0p1
sudo mkfs.ext4 /dev/mmcblk0p2
sudo mkfs.ext4 /dev/mmcblk0p3
sudo mkfs.vfat /dev/mmcblk0p4
sudo mkfs.ext4 -U ${ROOT_UUID} /dev/mmcblk0p5
sync
eject sd card.

-----------------------------------------------------------------------
Here are the summary of the tests: ( see rk3328_gpio.png )
These tests used Seeed Grove starter kit LED, button, buzzer, Grove-LCD RGB Backlight V3.0 JHD1313M2, Analog Servo and Adafruit SSD1306 128x32 SPI OLED Display.
1. uart test. 
   This test is to test uart tx and rx.
   Connect gpio pin 10 to serial USB cable RX.
   Connect gpio pin 8 to serial USB cable TX.
   Connect gpio pin 39 to serial USB cable ground.
   Enter a sentence and hit return key. 
2. led test.
   This test will blink led 5 times. 
   Connect gpio pin 32 to led control. 
   Connect gpio pin 2 to led 5V. 
   Connect gpio pin 9 to led ground.
3. button test. 
   Connect gpio pin 32 to led control. 
   Connect gpio pin 2 to led 5V. 
   Connect gpio pin 9 to led ground. 
   Connect gpio pin 23 to button control.
   Connect gpio pin 4 to button 5V.
   Connect gpio pin 6 to button ground.
4. pwm led test.
   This test will dim led 10 times.
   Connect gpio pin 13 to led control.
   Connect gpio pin 2 to led 5V.
   Connect gpio pin 9 to led ground.
5. i2c lcd test.
   This test will change lcd backlight color for 5 cycles.
   Then it will display two sentences on lcd display.
   Connect gpio pin 3 to lcd display SDA.
   Connect gpio pin 5 to lcd display SCL.
   Connect gpio pin 2 to lcd display 5V.
   Connect gpio pin 9 to lcd display ground.
6. tongsong.
   This test will generate song using buzzer.
   Connect gpio pin 13 to buzzer control.
   Connect gpio pin 2 to buzzer 5V.
   Connect gpio pin 9 to buzzer ground. 
7. servo.
   This test will turn servo 90 degree - 180 degree - 90 degree - 0 degree etc.
   Connect gpio pin 13 to servo control.
   Connect gpio pin 2 to servo 5V.
   Connect gpio pin 9 to servo ground.
8. spi oled test.
   This test will show some ascii characters on the oled display.
   Connect gpio pin 32 to oled display DC.
   Connect gpio pin 24 to oled display CS.
   Connect gpio pin 19 to oled display TX.
   Connect gpio pin 23 to oled display CLK.
   Connect gpio pin 1 to oled display 3.3V.
   Connect gpio pin 9 to oled display ground.
9. ddr test.
   This test will write random data to ddr address from 0x1000000 to 0x7ffffff
   Then read ddr address from 0x1000000 to 0x7ffffff compare to expected data.
   It will stop when any data mismatch.
a. mmc test.
   This test will read sd card lba 32768.
   Then read sd card lba 6283260.
   Then write incremental data to sd card lba 6283260.
   Then read data from sd card lba 6283260.
b. dmac test.
   This test will dma from ddr address 0x1000000 to ddr address 0x20000000 for 16 KB.
   Then dma from ddr address 0x20000000 to ddr address 0x30000000 for 16 KB.

-----------------------------------------------------------------------------
Download compiler from :
wget https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
sudo tar xvf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz  -C /usr/local/
export PATH=/usr/local/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin:$PATH
which aarch64-linux-gnu-gcc

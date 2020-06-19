### Put here the path to kernel sources! ###
KERNELDIR := /home/redsuser/Desktop/linux

obj-m := te2_socf.o

PWD := $(shell pwd)
WARN := -W -Wall -Wstrict-prototypes -Wmissing-prototypes

all: empty

empty:
	@echo "Building with kernel sources in $(KERNELDIR)"
	$(MAKE) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C $(KERNELDIR) M=$(PWD) ${WARN}

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions modules.order Module.symvers

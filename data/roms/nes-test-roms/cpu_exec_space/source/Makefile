all:	../test_cpu_exec_space_ppuio.nes \
	../test_cpu_exec_space_apu.nes

#####
../test_cpu_exec_space_ppuio.nes: test_cpu_exec_space_ppuio.o
	ld65  -o $@ $^ -v -C nes.cfg

test_cpu_exec_space_ppuio.o: test_cpu_exec_space_ppuio.s
	ca65 --smart -o $@ $^ -t nes -v -I common -DCUSTOM_IRQ -DCUSTOM_NMI

#####
../test_cpu_exec_space_apu.nes: test_cpu_exec_space_apu.o
	ld65  -o $@ $^ -v -C nes.cfg

test_cpu_exec_space_apu.o: test_cpu_exec_space_apu.s
	ca65 --smart -o $@ $^ -t nes -v -I common -DCUSTOM_IRQ -DCUSTOM_NMI

#####
clean:
	rm -f test_cpu_exec_space_ppuio.o ../test_cpu_exec_space_ppuio.nes
	rm -f test_cpu_exec_space_apu.o ../test_cpu_exec_space_apu.nes

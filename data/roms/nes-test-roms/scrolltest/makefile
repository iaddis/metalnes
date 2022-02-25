all: scroll.nes

scroll.nes: scroll.bin scrollhd.bin scrtest.chr scrtest.blk scrtest.map scrtest.pal
        copy /B scrollhd.bin+scroll.bin scroll.nes

scroll.bin: scroll.s
        dasm scroll.s -oscroll.bin -f3 -v3 -p3

scrollhd.bin: scrollhd.s
        dasm scrollhd.s -oscrollhd.bin -f3 -v3 -p3

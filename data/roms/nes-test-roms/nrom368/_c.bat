rem this file compiles C source file with given name into NES file
rem it is useful to compile few projects at once without repeating the build script
path=path;..\bin\
set CC65_HOME=..\
cc65 -Oi %1.c --add-source
ca65 crt0.s
ca65 %1.s
ld65 -C nes.cfg -o %1.nes crt0.o %1.o runtime.lib
del %1.s
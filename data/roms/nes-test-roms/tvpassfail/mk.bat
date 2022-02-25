\nesdev\cc65\bin\ca65 tv.s
if errorlevel 1 goto End
\nesdev\cc65\bin\ld65 tv.o -C nes.ini -o tv.prg --mapfile map.txt
if errorlevel 1 goto End
copy /b tv.prg+tv.chr tv.nes
tv.nes
:End
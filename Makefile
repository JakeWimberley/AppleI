%.bin: %.asm
	sbasm $<

mancala: mancala.bin
	xclip < mancala.bin

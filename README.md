# SNES Speed Test

SNES Speed Test, SA-1 Speed Test or just Speed Test is a homebrew ROM for measuring
the CPU speed of SA-1 CPU and SNES CPU under certain conditions. It assumes a NTSC
frequency and calculates the clock speed based on how many operations made between
two V-Blanks.

Features:
 * SA-1 speed measuring
 * High accuracy
 * Testing against many devices operation (ROM, I-RAM, BW-RAM, WRAM)
 * Testing while running DMA and H-DMA in parallel.
 * Error handling for faulty cases during tests.
 * Measures up to ~60 MHz, for overclock testing.
 * Display version number of PPU1, PPU2, S-CPU and SA-1.
 
## Expected Values
What are the expected speed values?

### SA-1 Speed Test
SNES Operation | SA-1 Operation | SA-1 Speed
---------------|----------------|------------
WRAM|ROM|10.74 MHz
ROM|ROM|Unknown, 5~9 MHz
WRAM|I-RAM|10.74 MHz
ROM|I-RAM|10.74 MHz
WRAM|BW-RAM|5.37 MHz
ROM|BW-RAM|5.37 MHz
I-RAM|I-RAM|10.74 MHz
BW-RAM|BW-RAM|5.37 MHz
HDMA ROM|ROM|Unknown, 8~10 MHz
HDMA WRAM|ROM|10.74 MHz
DMA ROM|ROM|Unknown, 5~9 MHz
DMA ROM|I-RAM|10.74 MHz

There's two therioes about ROM <-> ROM bus conflict. One that will make SA-1 CPU
always run at 5.37 MHz and another that makes only every fourth SA-1 cycle access
the ROM at 5.37 MHz, which implies at ~8.59 MHz speed. Only actual real hardware
testing against SA-1 carts will confirm or deny it.

### SNES Speed Test

SNES Operation | HDMA | SNES Speed
---------------|------|------------
ROM|No|2.60 MHz
WRAM|No|2.60 MHz
I-RAM|No|3.47 MHz
ROM|Yes|1.82 MHz
WRAM|Yes|1.82 MHz
I-RAM|Yes|2.42 MHz

Note that the WRAM refreshes (~40 master cycles per scanline) is what makes the bus
speed don't reach the nominal 2.68/3.58 MHz.
 
## Current Results

### bsnes
Version: v106r44

![bsnes](img/bsnesv106r44.png?raw=true "bsnes")

### sd2snes
Version: 1.8.0 + RedGuy SA-1 v06 -- picture by terminator2k2

![sd2snes](img/sd2snes06.jpg "sd2snes")

### Snes9x
Version: 1.56.2

![Snes9x](img/snes9x1562.png?raw=true "Snes9x")

### ZSNES
Version: 1.51

More versions can be found [here](img/zsnes).

![ZSNES](img/zsnes151.png?raw=true "ZSNES")

### no$sns
Version: 1.6

![no$sns](img/nosns16.png?raw=true "no$sns")

### Snes9x for 3DS
Version: 1.30 -- picture by LX5.

![Snes9x for 3DS](img/snes9x_for_3ds_130.png?raw=true "Snes9x for 3DS")

### Real hardware
To be tested.

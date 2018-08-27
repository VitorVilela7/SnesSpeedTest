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
 
## Current Results

### bsnes
Version: v106r44

![bsnes](img/bsnesv106r44.png?raw=true "bsnes")

### Snes9x
Version: 1.56.2

![Snes9x](img/snes9x1562.png?raw=true "Snes9x")

### ZSNES
Version: 1.51

![ZSNES](img/zsnes151.png?raw=true "ZSNES")

### no$sns
Version: 1.6

![no$sns](img/nosns16.png?raw=true "no$sns")

### sd2snes
To be tested.

### Real hardware
To be tested.

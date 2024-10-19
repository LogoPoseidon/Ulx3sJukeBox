# Jukebox FPGA Project README
## Project Overview
This project is an audio playback system built on the ULX3S FPGA. It reads audio data stored on an SD card and plays it through a 4-bit Pulse Width Modulation (PWM) DAC. The system is controlled using seven buttons (btn[6:0]), where each button triggers the playback of a different song stored in sectors on the SD card. The audio is output in stereo through two 4-bit channels (audio_l and audio_r).

## Files Overview
### Hardware Design (Verilog Modules):
1. topmodule.v:
    The main module of the design, connecting all the submodules like the SD card controller, DAC, and button control logic. It includes:
        A state machine to manage system resets and operations.
        Audio playback control through a simple clock divider to generate a 32kHz sample rate.
        Integration of the SD card reader and DAC.

1. SDKartenLeser.v:
        The SD card management module. This handles reading data from specific sectors of the SD card (songs) and passing it to a FIFO queue for playback.
        Song management, Button and LED Controll.

1. sd_controller.v:
        A lower-level module responsible for the communication with the SD card via SPI. It manages SD card reads and provides the data to SDKarte.
        Taken from the [internet](https://web.mit.edu/6.111/volume2/www/f2019/tools/sd_controller.v).

1. queue.v:
        A FIFO queue module used for buffering the audio data from the SD card before playback.

1. dacpwm.v:
        The PWM-based DAC module that converts 8-bit PCM data into a PWM signal suitable for audio output. This is used to generate the stereo 4-bit audio output.
        Taken from [github](https://github.com/emard/ulx3s-misc/blob/master/examples/audio/hdl/dacpwm.v).

## Software (C Program):
convert_pcm_to_hex.c:
    A C program to convert 8-bit PCM audio data into a hex format. This format is used for initializing the audio data in simulation or loading onto the FPGA. The program reads a .raw file containing PCM audio samples and converts it into a .hex file, with one sample per line. This hexes written in that file should be written on the SDCard starting using for example [hxd](https://mh-nexus.de/de/hxd/)

## System Features
1. Audio Playback from SD Card:
        The system reads audio data from an SD card, specifically using SPI mode. The SD card stores several songs, each located in different sectors. The system can queue up to 2048 bytes of audio data at a time.

1. Button Control:
        btn[0] to btn[6]: Selects which song to play from the SD card, with each button mapped to a different sector range (representing a different song).

1. Audio Output:
        The system outputs audio through two 4-bit channels (audio_l and audio_r), which represent the left and right stereo channels, respectively.
        Audio data is sampled at 32kHz using a clock divider within the FPGA design.

1. Song Selection:
        Each song is located in specific sector ranges on the SD card, and the system switches between songs by modifying the sector address based on button presses.

## How to Use

1. Loading Songs on SD Card:
        The system expects audio data in 8-bit signed PCM format (32kHz), stored in specific sectors of the SD card. The songs must be written to the card Define the Songstart Sector for each Song in SDKarteLeser:
    ```Sector = 32000/512*(60*SongstartMin+SongstartSec)```
    and the end of Song7 with the same formula.

1. Button Controls:
        Use btn[0] to btn[6] to switch between songs.
    Compiling the C Program: The provided convert_pcm_to_hex.c program can be compiled with gcc or any C compiler:
    ```gcc convert_pcm_to_hex.c -o convert_pcm_to_hex```
    Then run it to convert a raw PCM file to a .hex file:
    ```./convert_pcm_to_hex```

1. Programming the FPGA: Ensure that all Verilog files are included in your FPGA synthesis tool (like Yosys, nextpnr) and upload the bitstream to the ULX3S FPGA.

## Future Improvements

1. Audio Quality Enhancement:
    Experiment with higher bit-depth or different DAC designs to improve the audio quality.

# Uxn-compatible sound samples

Sources:

* all the `st-XX.lha` files from http://aminet.net/mods/inst/ for the samples themselves, and

* [st-xx-lha-convert](https://git.sr.ht/~ft/snippets/tree/master/item/st-xx-lha-convert) from [~ft/snippets](https://git.sr.ht/~ft/snippets) to convert the Amiga files properly.

## How to use

All the files in the `wav` directory match the paths in `uxn` and are there to help you choose the samples you like.

The files in `uxn` are split into two directories:

* the `11025` files are sampled at 11.025 kHz and should be played in Uxn at two octaves below middle C for their natural pitch, in other words, by writing `#24` to `pitch` instead of `#3c`; and

* the `22050` files are samples at 22.050 kHz and should be played only one octave below middle C for their natural pitch, by writing `#30` to `pitch` instead of `#3c`.

The samples in `22050` usually sound crisper than the ones in `11025`, but they take up twice the space for the same amount of time. Samples that were over 8 KiB large before conversion have been excluded from this repository as too few of them would fit in the 64 KiB of Uxn memory to be that useful. If you'd like samples longer than that, edit `convert.sh` and comment out the indicated line.

## Converting samples yourself

The `convert.sh` does all the work here, and requires Bash and SoX to be installed to work. If you have already downloaded the `st-XX.lha` files, copy them into the same directory as `convert.sh` to avoid downloading all the archives again.


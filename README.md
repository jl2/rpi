# rpi

This is a small library for doing stuff on the Raspberry Pi using Common Lisp.  Right now it can control the GPIO pins, but I plan on adding support for I2C and SPI later.

The easiest way to get started with the library is to clone it into your ASDF/QuickLisp search path:
```bash
cd ~/src/lisp
git clone https://github.com/jl2/rpi
```

Then start a REPL or load Slime, and type:
```commonlisp
(ql:quickload 'rpi)

(rpi:enable-pin 4)
(rpi:set-direction 4 :out)
(dotimes (i 20)
  (rpi:set-pin 4 1)
  (sleep 0.5)
  (rpi:set-pin 4 0)
  (sleep 0.5))
(rpi:disable-pin 4)
```

I'm not 100% sure what my plans are for this library, but right now it works well enough to access GPIO pins, so I'm putting it on GitHub.

One goal of this library was to be able to access the GPIO pins as a non-root user.  It requires setting up udev rules, but it's possible.  Unfortunately, I don't think there's any way to use I2C or SPI without root access, so I just write a WiringPi wrapper.

# FAQ

1. Why not create a binding for WiringPi?

    I considered it, but I needed a library that allowed GPIO access as a non-root user.  I couldn't figure out non-root access with WiringPi, so I wrote my own.

    Another downside of wrapping WiringPi is that I think the external dependency will complicate putting the library in QuickLisp.

2. What is libgpio?

    libgpio is a small shared library that reads and writes to the psuedo-files in /sys/class/gpio/*.  This should be possible in pure Lisp, but for some reason the sys file system hates the  buffering that SBCL's library does.



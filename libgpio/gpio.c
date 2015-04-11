/*
  gpio.c

  Copyright (c) 2015, Jeremiah LaRocco <jeremiah.larocco@gmail.com>

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

*/

/*
  The simplest possible GPIO library.
 */

#include <stdio.h>

/*
  Whether a pin is being used for input or output.
*/
enum pin_direction {in, out};

/*
  Turn on a pin
*/
void enable_pin(int pn) {
     FILE *outf = fopen("/sys/class/gpio/export", "wb");
     fprintf(outf, "%d", pn);
     fclose(outf);
}

/*
   Turn off a pin
*/
void disable_pin(int pn) {
     FILE *outf = fopen("/sys/class/gpio/unexport", "wb");
     fprintf(outf, "%d", pn);
     fclose(outf);
}

/*
  Set the direction of the specified pin
*/
void set_direction(int pn, enum pin_direction direction) {
     static char* dirs[] = {"in", "out"};
     char buffer[256] = {'\0'};
     snprintf(buffer, 255, "/sys/class/gpio/gpio%d/direction", pn);
     FILE *outf = fopen(buffer, "wb");
     fprintf(outf, dirs[direction]);
     fclose(outf);
}

/*
  Set the value of the specified pin.
  value == 0 turns off the signal
  value != 0 turns on the signal
*/
void set_pin(int pn, int value) {
     char buffer[256] = {'\0'};
     snprintf(buffer, 255, "/sys/class/gpio/gpio%d/value", pn);
     FILE *outf = fopen(buffer, "wb");
     fprintf(outf, "%d", value);
     fclose(outf);
}

/*
  Read the value of the specified pin.
  Returns 0 if the pin is not set
  Returns 1 otherwise
*/
int get_pin(int pn) {
     char buffer[256] = {'\0'};
     snprintf(buffer, 255, "/sys/class/gpio/gpio%d/value", pn);
     FILE *inf = fopen(buffer, "rb");
     int rval=0;
     fscanf(inf, "%d", &rval);
     fclose(inf);
     return rval;
}

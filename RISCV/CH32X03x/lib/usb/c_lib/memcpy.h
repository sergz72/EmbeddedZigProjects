#ifndef _MEMCPY_H
#define _MEMCPY_H

static void inline usb_memcpy(unsigned char *dest, const unsigned char *src, unsigned int n)
{
  while (n--)
    *dest++ = *src++;
}

#endif

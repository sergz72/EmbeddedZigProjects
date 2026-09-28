#ifndef __CH32X035_USBFS_DEVICE_EXPORT_H_
#define __CH32X035_USBFS_DEVICE_EXPORT_H_

#ifdef __cplusplus
extern "C" {
#endif

void USBFS_Device_Init(void);
void USBFS_RCC_Init(void);

unsigned int CDC_Receive(unsigned char *buffer, unsigned int buffer_size);
void CDC_Transmit(unsigned char *buffer, unsigned int length);
int CDC_getch(void);

#ifdef __cplusplus
}
#endif


#endif

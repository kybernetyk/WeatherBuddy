/*
 *  thermodino.c
 *  WeatherBuddy
 *
 *  Access Module for an (my) arduino thermometer connected
 *  to a serial port. 
 *
 *  The arduino sends us plain text containing the sensor's
 *  voltage and current room temperature. 
 *
 *  Created by jrk on 26/7/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "thermodino.h"
#include <fcntl.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <memory.h>
#include <stdlib.h>

//therm_device = posix path to serial port (like "/dev/cu.xxx")
//returns: temperature in centrigrade
float td_get_temp (const char *therm_device)
{
	int fd = open (therm_device,O_RDONLY);
	if (fd == -1)
		return -273.0f;
	
	unsigned char c;
	int readcount = 0;

	char tmpbuffer[255];
	memset(tmpbuffer, 0x00,255);
	
	char *p = tmpbuffer;

	while(1)
	{
		read(fd,&c,sizeof(unsigned char));
		*p++ = c;

		if (c == '\r' || c == '\n' || ++readcount >= 254)
		{	
			*p = 0; //terminate the bitch
			break;
		}
	}
	close(fd);
	
	if (readcount <= 0)
		return -273.0f;

	//we get something like this:
	//747 mV = 24.70 C
	int start = -1;
	for (int i = 0; i < strlen(tmpbuffer); i++)
	{
		if (tmpbuffer[i] == '=')
			start = i + 2;
		if (tmpbuffer[i] == 'C')
			tmpbuffer[i-1] = 0;
	}

	if (start >= 0)
	{
		float ret = atof(tmpbuffer+start);
		return ret;
	}
	
	return -273.0f;
}

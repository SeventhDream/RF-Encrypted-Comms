// rf95_reliable_datagram_client.cpp
// -*- mode: C++ -*-
// Example app showing how to create a simple addressed, reliable messaging client
// with the RHReliableDatagram class, using the RH_RF95 driver to control a RF95 radio.
// It is designed to work with the other example rf95_reliable_datagram_server.
//
// Requires Pigpio GPIO library. Install by downloading and compiling from
// http://abyz.me.uk/rpi/pigpio/, or install via command line with
// "sudo apt install pigpio". To use, run "make" at the command line in
// the folder where this source code resides. Then execute application with
// sudo ./rf95_reliable_datagram_client.
// Tested on Raspberry Pi Zero and Zero W with LoRaWan/TTN RPI Zero Shield
// by ElectronicTricks. Although this application builds and executes on
// Raspberry Pi 3, there seems to be missed messages and hangs.
// Strategically adding delays does seem to help in some cases.

//(9/20/2019)   Contributed by Brody M. Based off rf22_reliable_datagram_client.pde.
//              Raspberry Pi mods influenced by nrf24 example by Mike Poublon,
//              and Charles-Henri Hallard (https://github.com/hallard/RadioHead)


#include <pigpio.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

#include <RHReliableDatagram.h>
#include <RH_RF95.h>

//Function Definitions
void sig_handler(int sig);

//Pin Definitions
#define RFM95_CS_PIN 8
#define RFM95_IRQ_PIN 25
#define RFM95_LED 4

//Client and Server Addresses
#define CLIENT_ADDRESS 1
#define SERVER_ADDRESS 2

//RFM95 Configuration
#define RFM95_FREQUENCY  915.00
#define RFM95_TXPOWER 14

// Singleton instance of the radio driver
RH_RF95 rf95(RFM95_CS_PIN, RFM95_IRQ_PIN);

// Class to manage message delivery and receipt, using the driver declared above
RHReliableDatagram manager(rf95, CLIENT_ADDRESS);

//Flag for Ctrl-C
int flag = 0;

//Main Function
int main (int argc, const char* argv[] )
{
	if (gpioInitialise()<0)
	{
		printf( "\n\nRPI rf95_reliable_datagram_client startup Failed.\n" );
		return 1;
	}

	gpioSetSignalFunc(2, sig_handler); //2 is SIGINT. Ctrl+C will cause signal.

	printf( "\nRPI rf95_reliable_datagram_client startup OK.\n" );
	printf( "\nRPI GPIO settings:\n" );
	printf("CS-> GPIO %d\n", (uint8_t) RFM95_CS_PIN);
	printf("IRQ-> GPIO %d\n", (uint8_t) RFM95_IRQ_PIN);
#ifdef RFM95_LED
	gpioSetMode(RFM95_LED, PI_OUTPUT);
	printf("\nINFO: LED on GPIO %d\n", (uint8_t) RFM95_LED);
	gpioWrite(RFM95_LED, PI_ON);
	gpioDelay(500000);
	gpioWrite(RFM95_LED, PI_OFF);
#endif

	if (!rf95.init())
	{
		printf( "\n\nRF95 Driver Failed to initialize.\n\n" );
		return 1;
	}

	/* Begin Manager/Driver settings code */
	printf("\nRFM 95 Settings:\n");
	printf("Frequency= %d MHz\n", (uint16_t) RFM95_FREQUENCY);
	printf("Power= %d\n", (uint8_t) RFM95_TXPOWER);
	printf("Client(This) Address= %d\n", CLIENT_ADDRESS);
	printf("Server Address= %d\n", SERVER_ADDRESS);
	rf95.setTxPower(RFM95_TXPOWER, false);
	rf95.setFrequency(RFM95_FREQUENCY);
	rf95.setThisAddress(CLIENT_ADDRESS);
	rf95.setHeaderFrom(CLIENT_ADDRESS);
	rf95.setHeaderTo(SERVER_ADDRESS);
	/* End Manager/Driver settings code */

	/* Begin Datagram Client Code */
	uint8_t data[] = "Hello World!";
	// Dont put this on the stack:
	uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];

	while(!flag)
	{
		Serial.println("Sending to rf95_reliable_datagram_server");
		// Send a message to manager_server
#ifdef RFM95_LED
		gpioWrite(RFM95_LED, PI_ON);
#endif
		if (manager.sendtoWait(data, sizeof(data), SERVER_ADDRESS))
		{
			// Now wait for a reply from the server
			uint8_t len = sizeof(buf);
			uint8_t from;
			if (manager.recvfromAckTimeout(buf, &len, 2000, &from))
			{
				Serial.print("got reply from : 0x");
				Serial.print(from, HEX);
				Serial.print(": ");
				Serial.println((char*)buf);
			}
			else
			{
				Serial.println("No reply, is rf95_reliable_datagram_server running?");
			}
		}
		else
			Serial.println("sendtoWait failed");
#ifdef RFM95_LED
		gpioWrite(RFM95_LED, PI_OFF);
#endif
		gpioDelay(500000);
	}
	printf( "\nrf95_reliable_datagram_client Tester Ending\n" );
	gpioTerminate();
	return 0;
}

void sig_handler(int sig)
{
	flag=1;
}

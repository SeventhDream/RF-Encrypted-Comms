# Radio Frequency Encrypted Communications

## **Problem Statement:**
Wirelessly transmit a secure text-based message that only the target receiver can read in plain text.

## **Functional Requirements:**
- Message input by the user using a PC and keyboard connected to the transmitter circuit
- The transmitter must encrypt the message to prevent interceptors from reading the message contents without permission
- Data encoded and transmitted over 433MHz radio frequency
- Message recipient inputs decryption passkey into receiver circuit via physical numpad
- The receiver circuit must decode the data bundle and use the inputted passkey to decrypt the message back into plain text
- The receiver circuit must display the received text data on an LCD screen.

## **Hardware Components:**
- 2x Arduino Nano microcontrollers 
- 1x **433 MHz Radio Frequency Receiver Module** - https://surplustronics.co.nz/products/11377-ask-transmitter-and-receiver-kit
- 1x **20x4 LCD with I2C communication capabilities** - https://surplustronics.co.nz/products/10071-lcd-display-lcd1602-module-blue-screen
- 1x **4x3 Keypad** - https://surplustronics.co.nz/products/6183-keypad-switch-16-key
- 1x **Breadboard** - https://www.jaycar.com.au/arduino-compatible-breadboard-with-400-tie-points/p/PB8820
- **Jumper Wires** - https://www.jaycar.com.au/150mm-plug-to-plug-jumper-leads-40-piece/p/WC6024

## **Software Packages:**
- **Arduino IDE** - https://www.arduino.cc/en/software/
- **Processing Development Environment** - https://processing.org/download
- **RadioHead Library** - https://www.airspayce.com/mikem/arduino/RadioHead/
- **AESLib Library** - https://github.com/suculent/thinx-aes-lib

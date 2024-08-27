# Radio Frequency Encrypted Communications

**Problem Statement:** Wirelessly transmit a secure text-based message that only the target receiver can read in plain text.

**Functional Requirements:**
- Message input by the user using a PC and keyboard connected to the transmitter circuit
- The transmitter must encrypt the message to prevent interceptors from reading the message contents without permission
- Data encoded and transmitted over 433MHz radio frequency
- Message recipient inputs decryption passkey into receiver circuit via physical numpad
- The receiver circuit must decode the data bundle and use the inputted passkey to decrypt the message back into plain text
- The receiver circuit must display the received text data on an LCD screen.

**Hardware Components:**
- 2x Arduino Nano microcontrollers
- 1x 433 MHz Radio Frequency Receiver Module
- 1x 20x4 LCD with I2C communication capabilities
- 1x 4x3 Keypad
- 1x Breadboard
- Jumper Wires

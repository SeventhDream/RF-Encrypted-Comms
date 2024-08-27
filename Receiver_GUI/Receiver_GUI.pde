Skip to content
DEV Community
Find related posts...
Powered by  Algolia
Log in
Create account

3
Jump to Comments
0
Save

Cover image for RF Encrypted Communication System
Ogamba K
Ogamba K
Posted on Apr 16, 2021


4

3
RF Encrypted Communication System
#
processing
#
p5
#
arduino
In this tutorial, we'll go through how you can send encrypted data from one Arduino to another. The receiver must then enter the correct password to view the decrypted message.

We will work with the Arduino Uno development board, though any equivalent microprocessor will do.

The 433MHz RF module kit is a transmitter-receiver pair (sometimes packaged with an antenna but any standard 17cm wire will work just fine) that sends information one-way. Read more about the RF module here.
There are other long-range radio communication tools out there, so feel free to swap out the RF module for something better.

What you will need
Component  Quantity
Arduino Uno  2
433 MHz RF Receiver Module  1 (Transmitter-Receiver Pair)
20x4 LCD with I2C  1
4x3 Keypad  1
Breadboard  1
Jumper wires  1
(Optional) 17cm Antenna  2
(Optional) Solder on the antennas
You may need to solder the antennas onto the RF module to improve the coverage if you want to transmit over longer distances. For prototyping purposes, you may skip this step.

Installing the Software
You will need to install the Arduino IDE to upload sketches to the Arduino boards and the Processing Development Environment for the GUI. You will also need to download the RadioHead Library and include it in the Arduino libraries.

Alt Text

Finally, download this AESLib Arduino encryption library.

So let's get started!

Setup
This is the transmitter setup.

Alt Text

This is the circuit I implemented.

Alt Text

This is the receiver setup.

Alt Text

This is the implemented circuit.

Alt Text

The code
First, let's start with Processing. Open a new file and copy the code below and run it to create the user interface. We will use the GUI to send data to the transmitter circuit instead of writing messages and the encryption key directly to the serial.
// Import ControlP5, Serial, Regex libraries
import processing.serial.*;
import controlP5.*;
import java.util.regex.*;
// Create Serial object
Serial port;
// Create ControlP5 object
ControlP5 controlP5;
// Create Textfield objects
Textfield messageField;
Textfield keyField;
// Create Textarea objects
Textarea errorField;
Textarea cipherText;
// Create PFont objects
PFont font;
PFont smallerFont;

String encryptionKey;
String message;
String errorMessage;
String dataSent;
String inBuffer = null;

int lf = 10; // Linefeed in ASCII

// Setup the processing programme
void setup() {
    size(700, 800); // Window size (width, height)
    font = createFont("Calibri", 30); // Set font type, sizes
    smallerFont = createFont("Calibri", 20);

    try {
        port = new Serial(this, Serial.list()[0], 57600); // Set Serial to first availble port, baudrate 57600
        port.clear(); // Clear serial
        inBuffer = port.readStringUntil(lf); // Throw out the first reading, in case we started reading 
        inBuffer = null; // in the middle of a string from the sender.
    } catch(Exception e) { // In case of unavailable Serial port
        errorMessage = "Please connect the device to the USB port and relaunch the application";
        println(errorMessage); // Print error message and error type in the Terminal
        println(e);
    }

    controlP5 = new ControlP5(this);

    keyField = controlP5
       .addTextfield("key") // Set name of textfield in quotes
       .setPosition(100, 100) // Set position (x, y)
       .setSize(500, 50) // Set size (width, height)
       .setFont(font) // Set font
       .setAutoClear(false); // Remove auto clear on ENTER
    messageField = controlP5
       .addTextfield("message") // Set name of textfield in quotes
       .setPosition(100, 200) // Set position (x, y)
       .setSize(500, 50) // Set size (width, height)
       .setFont(font) // Set font
       .setAutoClear(false); // Remove auto clear on ENTER
    // Set textareas
    errorField = controlP5
       .addTextarea("error") // Set name of textarea in quotes
       .setPosition(100, 300) // Set position (x, y)
       .setSize(500, 50) // Set size (width, height)
       .setFont(smallerFont); // Set font
    cipherText = controlP5
       .addTextarea("ciphertext") // Set name of textarea in quotes
       .setPosition(100, 600) // Set position (x, y)
       .setSize(500, 100) // Set size (width, height)
       .setFont(smallerFont) // Set font
       .setColorBackground(color(21,27,84));
    // Set label for textarea "cihertext"
    controlP5.addTextlabel("cipherLabel") // Set name of textlabel in quotes
       .setPosition(100, 700) // Set position (x, y)
       .setSize(500, 50) // Set size (width, height)
       .setFont(font) // Set font
       .setValue("CIPHERTEXT"); // Set textlabel value in quotes
    // Set buttons which call functions Send, Clear when clicked
    controlP5.addButton("Send") // Set name of button in quotes
       .setPosition(300, 400) // Set position (x, y)
       .setSize(100, 50) // Set size (width, height)
       .setFont(font); // Set font
    controlP5.addButton("Clear") // Set name of button in quotes
       .setPosition(300, 500) // Set position (x, y)
       .setSize(100, 50) // Set size (width, height)
       .setFont(font); // Set font
}

void draw() {
    try {
        background(180);
        while(port.available() > 0) {
            inBuffer = port.readStringUntil(lf); // Read string from buffer until new line feed   
            if (inBuffer != null) {
                println(inBuffer); // Display encrypted message that is currently transmitting
                cipherText.setText(inBuffer);
            }
        }       
    } catch(Exception e) { // In case of unavailable Serial port
        errorMessage = "Please connect the device to the USB port and relaunch the application";
        errorField.setText(errorMessage); // Display error message in error field
    }
}
//Process message to be sent
void Send() {
    encryptionKey = keyField.getText(); // Set strings from the textfields entries
    message = messageField.getText();
    // Check that the key, message are 16 characters long
    if (encryptionKey.length() == 16 && message.length() == 16) {
        // Check that the encryption key only contains 16 numbers
        if (Pattern.matches("[0-9]{16}", encryptionKey)) {
            dataSent = encryptionKey + "|" + message; // Data sent has the separator "|"
            port.write(dataSent);
            errorField.clear();
        } else { // Error message
            errorMessage = "Key must be an unsigned whole number";
            errorField.setText(errorMessage);
        }    
    } else { // Error message
        errorMessage = "Key must be 16 characters long & Message must be 16 characters long";
        errorField.setText(errorMessage);
    }
}
//Clear the key,message and error fields
void Clear() {
    keyField.clear();
    messageField.clear();
    errorField.clear();
}
Next, we'll work on the transmitter setup. Create a new Arduino sketch. Make sure you extract the AESLib files into the same folder as the Arduino sketch. Copy the code into the Arduino sketch and upload it to the transmitter Arduino Uno.
// Include AES Encryption Library
#include "AESLib.h"
// Include RadioHead Amplitude Shift Keying Library
#include <RH_ASK.h>
// Include dependant SPI Library
#include <SPI.h>

// Create Amplitude Shift Keying Object
RH_ASK rf_driver;

void setup() {
  // put your setup code here, to run once:
  // Initialize ASK Object
  rf_driver.init();
  // Setup Serial Monitor
  Serial.begin(57600);
}

void loop() {
  // put your main code here, to run repeatedly:
  uint8_t key[17]; // 16 characters + 1 for null character
  char text[17]; // 16 characters + 1 for null character

  if (Serial.available() > 0) {
    String msgString = Serial.readString(); // Read data string
    String strkey;
    String message;

    // Split string into two values
    for (int i = 0; i < msgString.length(); i++) {
      if (msgString.substring(i, i + 1) == "|") {
        strkey = msgString.substring(0, i);
        message = msgString.substring(i + 1);

        break;
      }
    }
    // Assign values to key, text
    strkey.toCharArray(key, strkey.length() + 1);
    message.toCharArray(text, message.length() + 1);
    // Encrypt message using the key with AES-128 ECB mode
    aes128_enc_single(key, text);
  }
  // Send output character
  rf_driver.send((uint8_t *)text, strlen(text));
  rf_driver.waitPacketSent();
  // Print encrypted text to Serial Monitor
  Serial.print("encrypted:");
  Serial.println(text);
  delay(1000);
}
Lastly, create another Arduino sketch and copy the code below. Once again, extract the AESLib files into the folder containing the Arduino sketch. Upload this sketch on the receiver Arduino Uno.
// Include Wire Library for I2C
#include <Wire.h>
// Include NewLiquidCrystal Library for I2C
#include <LiquidCrystal_I2C.h>
// Include RadioHead Amplitude Shift Keying Library
#include <RH_ASK.h>
// Include dependant SPI Library
#include <SPI.h>
// Include the Keypad library
#include <Keypad.h>
// Include AES Encryption Library
#include "AESLib.h"

// Length of password + 1 for null character
#define Password_Length 17
// Character to hold password input
char Data[Password_Length];
// Counter for character entries
byte data_count = 0;
// Character to hold key input
char customKey;

// Constants for row and column sizes
const byte ROWS = 4;
const byte COLS = 3;

// Array to represent keys on keypad
char hexaKeys[ROWS][COLS] = {
  {'1', '2', '3'},
  {'4', '5', '6'},
  {'7', '8', '9'},
  {'*', '0', '#'}
};

// Connections to Arduino
byte rowPins[ROWS] = {9, 8, 7, 6};
byte colPins[COLS] = {5, 4, 3};

// Create keypad object
Keypad customKeypad = Keypad(makeKeymap(hexaKeys), rowPins, colPins, ROWS, COLS);

// Define LCD pinout
const int  en = 2, rw = 1, rs = 0, d4 = 4, d5 = 5, d6 = 6, d7 = 7, bl = 3;

// Define I2C Address - change if reqiuired
const int i2c_addr = 0x3F;

LiquidCrystal_I2C lcd(i2c_addr, en, rw, rs, d4, d5, d6, d7, bl, POSITIVE);

// Create Amplitude Shift Keying Object
RH_ASK rf_driver;

void setup() {
  // put your setup code here, to run once:
  // Initialize ASK Object
  rf_driver.init();
  // Set display type as 20 char, 4 rows
  lcd.begin(20, 4);
  //  Setup Serial Monitor
  Serial.begin(57600);
  // Print on first row
  lcd.setCursor(0, 0);
  lcd.print("Up and Running!");

  // Wait 1 second
  delay(1000);

  // Print on second row
  lcd.setCursor(0, 1);
  lcd.print("Setting up ...");

  // Wait 4 seconds
  delay(4000);

  // Clear the display
  lcd.clear();
}

void loop() {
  // put your main code here, to run repeatedly:
  // Set buffer to size of expected message
  uint8_t buf[16];
  uint8_t buflen = sizeof(buf);
  // Initialize LCD and print
  lcd.setCursor(0, 0);
  lcd.print("Enter Password:");
  // Look for keypress
  customKey = customKeypad.getKey();
  if (customKey) {
    // Enter keypress into array and increment counter
    Data[data_count] = customKey;
    lcd.setCursor(data_count, 1);
    lcd.print(Data[data_count]);
    data_count++;
  }

  if (customKey == '*') {
    // '*' keypress to clear the LCD display, Data
    clearData();
  }

  // See if we have reached the password length
  if (data_count == Password_Length - 1) {
    delay(1000);
    lcd.setCursor(0, 3);
    lcd.print("Processing ...");
    // Check if received packet is correct size
    if (rf_driver.recv(buf, &buflen)) {
      uint8_t * key = (uint8_t *)Data;
      char * text = (char *)buf;
      Serial.print("encrypted:");
      Serial.println(text);
      Serial.print("key:");
      Serial.println((char *)key);
      // Message received is decrypted, displayed
      aes128_dec_single(key, text);
      Serial.print("decrypted:");
      Serial.println(text);
      // Clear the LCD display
      lcd.clear();
      lcd.setCursor(0, 0);
      // Display decrypted text
      lcd.print("Message Received: ");
      lcd.setCursor(0, 1);
      lcd.print(text);
      // Wait 30 seconds
      delay(30000);
      // Clear data and LCD display
      clearData();
    }
  } else if (data_count >= Password_Length) {
    // Clear LCD dispaly, Data if password exceeds 16 characters
    clearData();
  }
}

void clearData() {
  // Clear LCD display
  lcd.clear();

  // Go through array and clear data
  while (data_count != 0) {
    Data[data_count--] = 0;
  }
  return;
}
Demonstration
Connect the transmitter setup to a USB port and run the Processing sketch. Type in your own 16-character long message and password and click send.

Alt Text

Connect the receiver setup to a USB port and open the serial monitor. Make sure it is connected to the right port with the baud rate set at 57600. Enter the password when prompted.

Alt Text

Alt Text

Note: The message will only persist for 30 seconds before prompting you to enter a password again.

Wrapping up
An encrypted RF Communication System can be pretty useful when trying to limit access to a broadcasted message. Although the RF 433MHz module is limited in range, it is a fairly inexpensive way to implement wireless connectivity between two IoT devices.

Happy Coding!

💡 One last tip before you go

Tired of spending so much on your side projects? 😒
We have created a membership program that helps cap your costs so you can build and experiment for less. And we currently have early-bird pricing which makes it an even better value! 🐥

Check out DEV++

Top comments (3)
Subscribe
pic
Add to the discussion
 
 
sheno profile image
Theenisharan
•
Nov 3 '23

Hi, im currently facing an issue where when i launch the code on the processing application, it gives me an error that says this

"Please connect the device to the USB port and relaunch the application
java.lang.RuntimeException: Error opening serial port COM3: Port busy
ControlP5 2.2.6 infos, comments, questions at sojamo.de/libraries/controlP5"

The error dissapears once i close the Arduino IDE, so im guessing that my serial port is not able to be used on 2 applications at the same time. Could you provide me with some help? I would greatly appreciate it cause I don't have much time left to try to project.

Thanks.


2
 likes
Like
Reply
 
 
ogambakerubo profile image
Ogamba K 
•
Nov 4 '23

Hello,

This error can occur when the port is already in use by another application or process. So, if the Arduino app is currently connected to the Arduino board, Processing cannot connect to your device on the USB port. To fix this, check if any other applications are using the serial port. If so, close them and try again.


1
 like
Like
Reply
 
 
sheno profile image
Theenisharan
•
Nov 27 '23

Hi,

Thank you for your solution, but I have a new issue where my messages is not being received in the Arduino app for the recevier code. Do you know why this issue is happening?

Could you provide me with some help? I would really be thankful because I have limited time to complete the project.

Image description


1
 like
Like
Reply
Code of Conduct • Report abuse
Read next
maosite profile image
Comparison on Six Self-Hosted WAF
Monster Lee - Aug 26

squadcasthq profile image
Navigating the Complexity of IT Operations: A Guide for Startups
Squadcast.com - Aug 26

jit_data profile image
[LATEST] Power BI vs Zoho Analytics: The Ultimate Showdown
Jit - Aug 26

saurabhkurve profile image
Lesser-Known HTML Attributes: Examples and Use Cases
Saurabh Kurve - Aug 26


Ogamba K
Follow
Software developer and Arduino enthusiast.
Location
Nairobi, Kenya
Joined
Sep 18, 2020
Trending on DEV Community 
Ben Halpern profile image
Meme Monday
#jokes #watercooler #discuss
Ben Sinclair profile image
Did you come to development from a different career?
#career #watercooler #discuss
Madza profile image
17 Open Source Alternatives to Your Favorite Software and Apps 🔥👨‍💻
#opensource #webdev #coding #productivity
// Import ControlP5, Serial, Regex libraries
import processing.serial.*;
import controlP5.*;
import java.util.regex.*;
// Create Serial object
Serial port;
// Create ControlP5 object
ControlP5 controlP5;
// Create Textfield objects
Textfield messageField;
Textfield keyField;
// Create Textarea objects
Textarea errorField;
Textarea cipherText;
// Create PFont objects
PFont font;
PFont smallerFont;

String encryptionKey;
String message;
String errorMessage;
String dataSent;
String inBuffer = null;

int lf = 10; // Linefeed in ASCII

// Setup the processing programme
void setup() {
    size(700, 800); // Window size (width, height)
    font = createFont("Calibri", 30); // Set font type, sizes
    smallerFont = createFont("Calibri", 20);

    try {
        port = new Serial(this, Serial.list()[0], 57600); // Set Serial to first availble port, baudrate 57600
        port.clear(); // Clear serial
        inBuffer = port.readStringUntil(lf); // Throw out the first reading, in case we started reading 
        inBuffer = null; // in the middle of a string from the sender.
    } catch(Exception e) { // In case of unavailable Serial port
        errorMessage = "Please connect the device to the USB port and relaunch the application";
        println(errorMessage); // Print error message and error type in the Terminal
        println(e);
    }

    controlP5 = new ControlP5(this);

    keyField = controlP5
       .addTextfield("key") // Set name of textfield in quotes
       .setPosition(100, 100) // Set position (x, y)
       .setSize(500, 50) // Set size (width, height)
       .setFont(font) // Set font
       .setAutoClear(false); // Remove auto clear on ENTER
    messageField = controlP5
       .addTextfield("message") // Set name of textfield in quotes
       .setPosition(100, 200) // Set position (x, y)
       .setSize(500, 50) // Set size (width, height)
       .setFont(font) // Set font
       .setAutoClear(false); // Remove auto clear on ENTER
    // Set textareas
    errorField = controlP5
       .addTextarea("error") // Set name of textarea in quotes
       .setPosition(100, 300) // Set position (x, y)
       .setSize(500, 50) // Set size (width, height)
       .setFont(smallerFont); // Set font
    cipherText = controlP5
       .addTextarea("ciphertext") // Set name of textarea in quotes
       .setPosition(100, 600) // Set position (x, y)
       .setSize(500, 100) // Set size (width, height)
       .setFont(smallerFont) // Set font
       .setColorBackground(color(21,27,84));
    // Set label for textarea "cihertext"
    controlP5.addTextlabel("cipherLabel") // Set name of textlabel in quotes
       .setPosition(100, 700) // Set position (x, y)
       .setSize(500, 50) // Set size (width, height)
       .setFont(font) // Set font
       .setValue("CIPHERTEXT"); // Set textlabel value in quotes
    // Set buttons which call functions Send, Clear when clicked
    controlP5.addButton("Send") // Set name of button in quotes
       .setPosition(300, 400) // Set position (x, y)
       .setSize(100, 50) // Set size (width, height)
       .setFont(font); // Set font
    controlP5.addButton("Clear") // Set name of button in quotes
       .setPosition(300, 500) // Set position (x, y)
       .setSize(100, 50) // Set size (width, height)
       .setFont(font); // Set font
}

void draw() {
    try {
        background(180);
        while(port.available() > 0) {
            inBuffer = port.readStringUntil(lf); // Read string from buffer until new line feed   
            if (inBuffer != null) {
                println(inBuffer); // Display encrypted message that is currently transmitting
                cipherText.setText(inBuffer);
            }
        }       
    } catch(Exception e) { // In case of unavailable Serial port
        errorMessage = "Please connect the device to the USB port and relaunch the application";
        errorField.setText(errorMessage); // Display error message in error field
    }
}
//Process message to be sent
void Send() {
    encryptionKey = keyField.getText(); // Set strings from the textfields entries
    message = messageField.getText();
    // Check that the key, message are 16 characters long
    if (encryptionKey.length() == 16 && message.length() == 16) {
        // Check that the encryption key only contains 16 numbers
        if (Pattern.matches("[0-9]{16}", encryptionKey)) {
            dataSent = encryptionKey + "|" + message; // Data sent has the separator "|"
            port.write(dataSent);
            errorField.clear();
        } else { // Error message
            errorMessage = "Key must be an unsigned whole number";
            errorField.setText(errorMessage);
        }    
    } else { // Error message
        errorMessage = "Key must be 16 characters long & Message must be 16 characters long";
        errorField.setText(errorMessage);
    }
}
//Clear the key,message and error fields
void Clear() {
    keyField.clear();
    messageField.clear();
    errorField.clear();
}
Thank you to our Diamond Sponsor Neon for supporting our community.

DEV Community — A constructive and inclusive social network for software developers. With you every step of your journey.

Home
DEV++
Podcasts
Videos
Tags
DEV Help
Forem Shop
Advertise on DEV
DEV Challenges
DEV Showcase
About
Contact
Guides
Software comparisons
Code of Conduct
Privacy Policy
Terms of use
Built on Forem — the open source software that powers DEV and other inclusive communities.

Made with love and Ruby on Rails. DEV Community © 2016 - 2024.

#!/usr/bin/env python3

from RPi import GPIO
import time


# blinking function
def blink(pin):
    GPIO.output(pin, GPIO.HIGH)
    time.sleep(.1)
    GPIO.output(pin, GPIO.LOW)
    time.sleep(.1)
    return


def test_leds():
    # to use Raspberry Pi board pin numbers
    GPIO.setmode(GPIO.BOARD)
    pins = [11, 12, 15]
    # set up GPIO output channel
    for pin in pins:
        GPIO.setup(pin, GPIO.OUT)

    # blink GPIO17 50 times
    for i in range(0, 50):
        for pin in pins:
            blink(pin)


def test_button():
    GPIO.setmode(GPIO.BCM)

    button = 23
    GPIO.setup(button, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    while True:
        GPIO.wait_for_edge(button, GPIO.RISING)

        print("Button Pressed")

        GPIO.wait_for_edge(button, GPIO.FALLING)

        print("Button Released")


test_button()

GPIO.cleanup()

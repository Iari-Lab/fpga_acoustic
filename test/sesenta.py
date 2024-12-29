#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import math
import numpy as np

from koheron import command

class Sesenta(object):
    def __init__(self, client):
        self.client = client
        self.mic_size = 1<<10

    @command()
    def reset_clk_mics(self):
        pass

    @command()
    def reset_clk_leds(self):
        pass

    @command()
    def reset_led(self):
        pass

    @command()
    def set_nsamples(self, samples):
        pass

    @command()
    def get_mics(self, samples):
        return self.client.recv_vector(dtype='uint32')


    # @command()
    # def get_data(self):
    #     return self.client.recv_array(16, dtype='float64')

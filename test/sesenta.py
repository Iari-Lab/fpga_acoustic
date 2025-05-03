#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import math
import numpy as np

from koheron import command

class QRP(object):
# class Sesenta(object):
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
    def cic_on(self):
        pass

    @command()
    def cic_off(self):
        pass

    @command()
    def avg_on(self):
        pass

    @command()
    def avg_off(self):
        pass

    @command()
    def dig_on(self):
        pass

    @command()
    def dig_off(self):
        pass

    @command()
    def reset_led(self):
        pass

    @command()
    def set_rate(self, rate):
        pass

    @command()
    def set_cic(self, sel):
        pass

    @command()
    def set_f1(self, freq):
        pass

    @command()
    def set_nsamples(self, samples):
        pass

    @command()
    def get_mics1(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mic(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics_ad(self, samples):
        return self.client.recv_vector(dtype='uint32')

    @command()
    def get_micsu(self, samples):
        return self.client.recv_vector(dtype='uint32')

    # @command()
    # def get_data(self):
    #     return self.client.recv_array(16, dtype='float64')

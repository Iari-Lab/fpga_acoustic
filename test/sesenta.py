#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import math
import numpy as np

from koheron import command

class Sesenta(object):
    def __init__(self, client):
        self.client = client

    @command()
    def reset_led(self):
        pass

    @command()
    def record(self):
        pass

    @command()
    def bf(self):
        pass
    @command()
    def beamf(self, mic):
        pass

    @command()
    def set_rate(self, rate):
        pass

    @command()
    def set_mic_sel(self, sel):
        pass


    @command()
    def set_led_sel(self, sel):
        pass

    @command()
    def set_nsamples(self, samples):
        pass

    @command()
    def get_mics6(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics4(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics_bram(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def read_mics6(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def read_mics4(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics_dut(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mic_ith(self, mic_idx):
        return self.client.recv_array(4096, dtype='int32')

    @command()
    def get_mics_ith(self, samples, mic_idx):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_micsu(self, samples):
        return self.client.recv_vector(dtype='uint32')


d18, d19, 0
d20, d21, 1
d22, d23, 2
d24, d25, 3
d26, d27, 4
d28, d29, 5
d30, d31, 6

mics_order = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
mics_map = [59 - i for i in mics_order]  # Map FPGA mic indices to physical mic numbers

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
    def set_rate(self, rate):
        pass

    @command()
    def set_mic_sel(self, sel):
        pass

    @command()
    def set_nsamples(self, samples):
        pass

    @command()
    def get_mics6(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def read_mics6(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics_dut(self, samples):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_mics_ith(self, samples, mic_idx):
        return self.client.recv_vector(dtype='int32')

    @command()
    def get_micsu(self, samples):
        return self.client.recv_vector(dtype='uint32')

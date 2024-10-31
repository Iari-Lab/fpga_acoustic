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
    def trigger_mic_rst(self):
        pass

    @command()
    def trigger_addr_count_rst(self):
        pass

    @command()
    def trigger_led_rst(self):
        pass

    @command()
    def get_mic(self):
        return self.client.recv_uint32()

    @command()
    def set_nsamples(self, samples):
        pass

    @command()
    def start(self):
        pass

    @command()
    def get_data(self, mic_id):
        return self.client.recv_vector(dtype='float64')

    # @command()
    # def get_data(self):
    #     return self.client.recv_array(16, dtype='float64')

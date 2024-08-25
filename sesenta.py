#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import math
import numpy as np

from koheron import command

class Sesenta(object):
    def __init__(self, client):
        self.client = client
        self.mic_size = 1<<12

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
        return np.int32(self.client.recv_array(self.mic_size, dtype='uint32'))

    @command()
    def get_mic1(self):
        return np.int32(self.client1.recv_array(self.mic_size, dtype='uint32'))

    @command()
    def get_mic2(self):
        return np.int32(self.client1.recv_array(self.mic_size, dtype='uint32'))

    @command()
    def get_mic3(self):
        return np.int32(self.client1.recv_array(self.mic_size, dtype='uint32'))

    @command()
    def get_mic4(self):
        return np.int32(self.client1.recv_array(self.mic_size, dtype='uint32'))

    @command()
    def get_mic5(self):
        return np.int32(self.client1.recv_array(self.mic_size, dtype='uint32'))

    @command()
    def get_mic6(self):
        return np.int32(self.client1.recv_array(self.mic_size, dtype='uint32'))

    @command()
    def get_mic7(self):
        return np.int32(self.client1.recv_array(self.mic_size, dtype='uint32'))
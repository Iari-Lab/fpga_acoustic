#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import math
import numpy as np

from koheron import command

class Sesenta(object):
    def __init__(self, client):
        self.client = client
        self.mic_size = 1<<14

    @command()
    def trigger_mic_rst(self):
        pass

    @command()
    def trigger_addr_count_rst(self):
        pass

    @command()
    def get_mic(self):
        return np.int32(self.client.recv_array(self.mic_size, dtype='uint32'))

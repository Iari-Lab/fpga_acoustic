#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import dlti, dstep
from scipy.fftpack import fft
from scipy.signal import step, lti
import numpy as np
import os
import time
from sesenta import Sesenta
from koheron import connect
import matplotlib
from scipy.io.wavfile import write
from matplotlib import pyplot as plt
from matplotlib.lines import Line2D

class Acoustic():

    def __init__(self, *args, **kwargs):
        self.driver = None
        self.host = None

    def initialize_driver(self, host):
        self.host = os.getenv('MYIR_HOST', host)
        client = connect(host, 'Sesenta', restart=False)
        self.driver = Sesenta(client)

    def data_bram_ith(self,ith):
        print("Collecting data for mic index:", ith)
        mic = self.driver.get_mic_ith(ith)
        self.plot_all([mic], "{}".format(ith), test= ith)

    def data_flow_ith(self, samples, name, test):
        print("Collecting data for mic index:", test)
        mics = self.driver.get_mics_ith(samples, test)
        reshaped_array = np.vstack([mics[i::4] for i in range(4)])
        print(reshaped_array)
        self.plot_all(reshaped_array, "{}".format(name), test= test)

    def plot_all(self, data_arrays, name, filedir="mini", test=0):
        """
        Plots multiple arrays same plot
    
        """
        # plt.subplots(figsize=(10, 6))
        plt.figure(figsize=(12, 8))
        # plt.figure(figsize=(10, 6))
        
        for idx, data in enumerate(data_arrays):
            time_axis = np.arange(len(data))
            # np.save(f"../{filedir}/{name}{idx}.npy", data)
            plt.plot(time_axis, data, label="{} {}".format(name, idx))  
    
        plt.title("{}".format(name))
        plt.xlabel("Time (s)")
        plt.ylabel("Amplitude")
        plt.grid(True)
        plt.legend()
        plt.tight_layout()
        # plt.savefig(f"../{filedir}/{name}_{test}.png", dpi=300, bbox_inches='tight')
        plt.show(block= False)


    def gen_audio(self, data, name):
        data_centered = data - np.mean(data)
        data_normalized = data_centered / np.max(np.abs(data_centered))
        data_int16 = np.int16(data_normalized * 32767)
        sample_rate = 48000  # For example, if your decimated audio is 48 kHz
        write("{}.wav".format(name), sample_rate, data_int16)
        print("Saving data to data.npy", data)

def main(trigger_addr_count=False):
    fpga = Acoustic() 
    fpga.initialize_driver('192.168.8.138')
    fpga.data_stream(1)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--trigger", help="Enable trigger_addr_count_rst", action="store_true")
    args = parser.parse_args()
    main(args.trigger)




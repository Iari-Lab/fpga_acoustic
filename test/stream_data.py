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

    def data_stream_diga2(self, samples, name, test):
        mics = self.driver.get_mics_ad(samples)
        reshaped_array = np.vstack([mics[i::3] for i in range(3)])
        # analog_mic = reshaped_array[1]
        analog_mic = reshaped_array[1].astype(np.int32)
        dig_mic = reshaped_array[0].astype(np.int32)
        dig_mic_fir = reshaped_array[2].astype(np.int32)
        self.plot_step_response(analog_mic, "{}_{}_{}".format(name, "analog", test))
        self.gen_audio(analog_mic,"{}_{}_{}".format(name, "analog", test))
        self.plot_step_response(dig_mic, "{}_{}_{}".format(name, "digital_cic", test))
        self.gen_audio(dig_mic,"{}_{}_{}".format(name, "digital_cic", test))
        self.plot_step_response(dig_mic_fir, "{}_{}_{}".format(name, "digital_fir", test))
        self.gen_audio(dig_mic_fir,"{}_{}_{}".format(name, "digital_fir", test))


    def data_flow_ith(self, samples, name, test):
        print("Collecting data for mic index:", test)
        mics = self.driver.get_mics_ith(samples, test)
        reshaped_array = np.vstack([mics[i::4] for i in range(4)])
        print(reshaped_array)
        self.plot_all(reshaped_array, "{}".format(name), test= test)

    def data_stream_pro6(self, samples, channels, name, filedir):
        mics = self.driver.get_mics6(samples)
        print("Data received:", len(mics))
        dma1, dma2 = np.split(mics,2)
        print("Data split:", dma1, len(dma1))
        mics_posedge = np.vstack([dma1[i::channels] for i in range(channels)]) # dma1
        self.plot_all(mics_posedge, "{}_dma1".format(name), filedir)
        mics_negedge = np.vstack([dma2[i::channels] for i in range(channels)]) #dma2
        self.plot_all(mics_negedge, "{}_dma2".format(name), filedir)

    def data_stream_pro(self, samples, channels, name):
        mics = self.driver.get_mics(samples)
        print("Data received:", len(mics))
        dma1, dma2 = np.split(mics,2)
        print("Data split:", dma1, len(dma1))
        # _channels = 6
        # NOTE: we are not using the last 2 values from the 512 buffers from the dmas, so those mics are 0
        # mics_posedge = np.vstack([dma1[i::_channels] for i in range(_channels)]) # dma1
        mics_posedge = np.vstack([dma1[i::channels] for i in range(channels)]) # dma1
        # for i in range(channels):
        #     self.gen_audio(mics_posedge[i],"{}{}".format(name, i))
        self.plot_all(mics_posedge[:6], "{}_dma1".format(name))
        mics_negedge = np.vstack([dma2[i::channels] for i in range(channels)]) #dma2
        # mics_negedge = np.vstack([dma2[i::_channels] for i in range(_channels)]) #dma2
        # for i in range(channels):
        #     self.gen_audio(mics_negedge[i],"{}{}".format(name, i))
        self.plot_all(mics_negedge[:6], "{}_dma2".format(name))

    def plot_all(self, data_arrays, name, filedir="mini", test=0):
        """
        Plots multiple arrays same plot
    
        """
        # plt.subplots(figsize=(10, 6))
        plt.figure(figsize=(12, 8))
        # plt.figure(figsize=(10, 6))
        
        for idx, data in enumerate(data_arrays):
            time_axis = np.arange(len(data))
            np.save(f"../{filedir}/{name}{idx}.npy", data)
            plt.plot(time_axis, data, label="{} {}".format(name, idx))  
    
        plt.title("{}".format(name))
        plt.xlabel("Time (s)")
        plt.ylabel("Amplitude")
        plt.grid(True)
        plt.legend()
        plt.tight_layout()
        plt.savefig(f"../{filedir}/{name}_{test}.png", dpi=300, bbox_inches='tight')
        # plt.show()


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




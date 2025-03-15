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
# from sesenta import QRP
from sesenta import Sesenta
from koheron import connect
import matplotlib
from scipy.io.wavfile import write
matplotlib.use('TKAgg')
from matplotlib import pyplot as plt
from matplotlib.lines import Line2D
from multiprocessing import Process, Queue
from multiprocessing.managers import BaseManager

class QueueManager(BaseManager):
    pass

QueueManager.register('get_queue')
class Acoustic():

    def __init__(self, *args, **kwargs):
        self.driver = None
        self.host = None

    def initialize_driver(self, host):
        self.host = os.getenv('MYIR_HOST', host)
        # client = connect(host, 'Sesenta', restart=False)
        client = connect(host, 'lockin', restart=False)
        self.driver = Sesenta(client)
        # self.driver = Sesenta(client)
        # self.driver.reset_clk_leds() 
        # self.driver.reset_clk_mics()
        # self.driver.set_rate(64)
        # self.driver.set_f1(640)
        # self.driver.reset_led()

    def set_rate(self, rate):
        self.driver.set_rate(rate)


    def data_streameru(self, samples, name):
        mics = self.driver.get_mics1(samples)
        reshaped_array = mics.reshape(8, samples)
        # for i in range(samples):
        for i in range(8):
            self.plot_step_response(reshaped_array[i], "{}{}".format(name, i))
            self.gen_audio(reshaped_array[i],"{}{}".format(name, i))
        # self.plot_spectrum(mics)
        # self.plot_freq_response(mics)
        # self.plot_step_response(mics, name)
        # self.gen_audio(mics, name)

    # def data_streamer(self, samples, name):
    #     mics = self.driver.get_mics(samples)
    #     # self.plot_spectrum(mics)
    #     # self.plot_freq_response(mics)
    #     self.plot_step_response(mics, name)
    #     self.gen_audio(mics, name)

    def data_streamer(self, samples, name):
        mics = self.driver.get_mics(samples)
        # self.plot_spectrum(mics)
        # self.plot_freq_response(mics)
        self.plot_step_response(mics, name)
        self.gen_audio(mics, name)

    def plot_spectrum(self, data):
        # Remove DC offset
        data = data - np.mean(data)
        
        # Compute FFT
        n = len(data)
        fs = 48e3  # Decimated sample rate
        spectrum = np.abs(np.fft.fft(data))
        freqs = np.fft.fftfreq(n, d=1/fs)
        
        # Plot only the positive frequencies
        half_n = n // 2
        plt.figure(figsize=(10, 5))
        plt.plot(freqs[:half_n], spectrum[:half_n])
        plt.xlabel("Frequency (Hz)")
        plt.ylabel("Magnitude")
        plt.title("Spectrum of PDM Mic Signal (DC Removed), 192 decimation CIC")
        plt.xlim(0, 300)
        plt.grid()
        plt.savefig('spectrum1.png')
        plt.show()

    def plot_step_response(self, data, name):
        # Remove baseline offset (using the first part of the signal)
        # baseline = np.mean(data[:int(0.1 * len(data))])  # averag
        # data = data - baseline

        # data = data - np.mean(data)
        time_axis = np.arange(len(data))
        plt.figure(figsize=(8, 4))
        plt.plot(time_axis, data, label="{}".format(name))
        plt.title("{}".format(name))
        plt.xlabel("Time (s)")
        plt.ylabel("Amplitude")
        plt.grid(True)
        # plt.xlim(0, 1000) 
        plt.legend()
        plt.tight_layout()
        plt.savefig("{}".format(name))
        plt.show()

    def plot_freq_response(self, data, fs=48e3):
        # Remove DC offset
        data = data - np.mean(data)
        
        # Optionally, apply a window function if desired
        # window = np.hanning(len(data))
        # data = data * window
        
        n = len(data)
        fft_data = np.fft.fft(data)
        freq = np.fft.fftfreq(n, d=1/fs)
        
        # Take only the positive frequencies
        idx = np.where(freq >= 0)
        freq = freq[idx]
        magnitude = np.abs(fft_data[idx]) / n
        
        magnitude_db = 20 * np.log10(np.maximum(magnitude, 1e-12))
        plt.figure(figsize=(8, 4))
        plt.plot(freq, magnitude_db, label='Frequency Response')
        plt.title("Frequency Response (DC Removed), 192 Dec")
        plt.xlabel("Frequency (Hz)")
        plt.ylabel("Magnitude (dB)")
        plt.xlim(0, 300) 
        plt.grid(True)
        plt.legend()
        plt.tight_layout()
        plt.savefig('freq_response1.png')
        plt.show()

    def gen_audio(self, data, name):
        data_centered = data - np.mean(data)
        data_normalized = data_centered / np.max(np.abs(data_centered))
        data_int16 = np.int16(data_normalized * 32767)
        sample_rate = 48000  # For example, if your decimated audio is 48 kHz
        write("{}.npy".format(name), sample_rate, data_int16)
        print("Saving data to data.npy", data)
        np.save("{}.npy".format(name), data)

    def data_stream(self, samples):
        manager = QueueManager(address=('localhost', 50000), authkey=b'abc')
        manager.connect()
        data_queue = manager.get_queue()
        mics = self.driver.get_mics(samples)
        for i in range(mics):
            sample = grouped[i].tolist()
            data_point = sample, i
            print(data_point)
            data_queue.put(data_point)

    def data_stream_live(self, samples=1, enable_transfer=False, isv2=False):
        chunks = 16
        n = samples // chunks
        manager = QueueManager(address=('localhost', 50000), authkey=b'abc')
        manager.connect()
        data_queue = manager.get_queue()
        for i in range(n):
            try:
                mics = self.driver.get_mics(chunks)
                print(mics)
                data_point = mics, i
                print(i)
                data_queue.put(data_point)
                # for j in range(chunks):
                #     sample = mics
                #     # sample = mics[i].tolist()
                #     data_point = sample, j
                #     print(data_point)
                #     data_queue.put(data_point)
            except KeyboardInterrupt:
                break  

   # def plot_spectrum(self, data):
    #     # Compute spectrum
    #     n = len(data)
    #     fs = 48e3
    #     freqs = np.fft.fftfreq(n, d=1/fs)
    #     spectrum = np.abs(fft(data))

    #     # Plot spectrum
    #     plt.figure(figsize=(10, 5))
    #     plt.plot(freqs,spectrum)  # Plot positive frequencies
    #     # plt.plot(freqs[:n // 2], spectrum[:n // 2])  # Plot positive frequencies
    #     plt.xlabel("Frequency (Hz)")
    #     plt.ylabel("Magnitude")
    #     plt.title("Spectrum of PDM Mic Signal")
    #     plt.grid()
    #     plt.savefig('spectrum.png')
    #     plt.show()

    # def plot_step_response(self, data):
    #     time_axis = np.arange(len(data)) / 48e3
        
    #     plt.figure(figsize=(8, 4))
    #     plt.plot(time_axis, data, label='Step Response')
    #     plt.title("Step Response")
    #     plt.xlabel("Time (s)")
    #     plt.ylabel("Amplitude")
    #     plt.grid(True)
    #     plt.legend()
    #     plt.tight_layout()
    #     plt.savefig('step_response.png')
    #     plt.show()

    # def plot_freq_response(self, data,fs=48e3):
        
    #     n = len(data)
    #     fft_data = np.fft.fft(data)
    #     freq = np.fft.fftfreq(n, d=1/fs)
        
    #     idx = np.where(freq >= 0)
    #     freq = freq[idx]
    #     magnitude = np.abs(fft_data[idx]) / n
        
    #     magnitude_db = 20 * np.log10(np.maximum(magnitude, 1e-12))
        
    #     plt.figure(figsize=(8, 4))
    #     plt.plot(freq, magnitude_db, label='Frequency Response')
    #     plt.title("Frequency Response")
    #     plt.xlabel("Frequency (Hz)")
    #     plt.ylabel("Magnitude (dB)")
    #     plt.grid(True)
    #     plt.legend()
    #     plt.tight_layout()
    #     plt.savefig('freq_response.png')
    #     plt.show()

    # def plot_cic_step_response(decimation_rate=64, fs=3072e6, n_points=1000):
    #     fs_out = fs / decimation_rate

    #     # Define the discrete-time transfer function for one section of the CIC filter.
    #     # A CIC filter is typically implemented as a cascade of integrators and comb filters.
    #     # Here we define one stage of a comb filter as:
    #     #   b = [1, 1, ..., 1] (length = decimation_rate)
    #     #   a = [1, 0, 0, ..., 0, -1] (length = decimation_rate + 1)
    #     b = [1] * decimation_rate
    #     a = [1] + [0] * (decimation_rate - 1) + [-1]
        
    #     # Create the discrete LTI system from the coefficients.
    #     cic_system = dlti(b, a)
        
    #     # Compute the step response. dstep returns a tuple: (time_indices, [response]).
    #     t, step_resp = dstep(cic_system, n=n_points)
    #     t = np.array(t).flatten() / fs_out  # Convert time indices to seconds.
    #     step_resp = np.array(step_resp).flatten()
        
    #     # Plot the step response.
    #     plt.figure(figsize=(10, 5))
    #     plt.plot(t, step_resp)
    #     plt.xlabel("Time (s)")
    #     plt.ylabel("Amplitude")
    #     plt.title("Step Response of the CIC Filter")
    #     plt.grid()
    #     plt.show()

    def clear(self):
        manager = QueueManager(address=('localhost', 50000), authkey=b'abc')
        manager.connect()
        data_queue = manager.get_queue()
        data_point = [[]], -1
        data_queue.put(data_point)


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






















# def main():
#     """Main function to run the dynamic plot."""
#     # host = os.getenv('HOST', '192.168.8.139')
#     host = os.getenv('HOST', '192.168.0.208')
#     # host = os.getenv('HOST', 'rp-f0ab56.local')
#     sampling_frequency = 125e6 # Hz
    
#     driver = initialize_driver(host)
#     # print(f'ADC size = {driver.quad_size}')
    
#     fig, line1, t_us = initialize_plot(driver, sampling_frequency)
#     driver.trigger_addr_count_rst() 
#     # driver.trigger_mic_rst()
#     iteration_count = 0
#     try:
#         while True:
#             iteration_count += 1
#             print(iteration_count)
            
#             li=driver.get_mic()
#             print(li)
#             # line1.set_data(t_us, li)
#             # fig.canvas.draw()
#             plt.pause(0.001)
            
#     except KeyboardInterrupt:
#         print("Interrupted by user. Exiting.")
#         exit(0)

# if __name__ == '__main__':
#     main()

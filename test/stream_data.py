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
        # self.driver = QRP(client)
        self.driver = Sesenta(client)
        # self.driver.reset_clk_leds() 
        # self.driver.reset_clk_mics()
        # self.driver.set_rate(64)
        # self.driver.set_f1(640)
        # self.driver.reset_led()

    def set_rate(self, rate):
        self.driver.set_rate(rate)


    # def to_signed(unsigned_value):
    #     # Convert to signed
    #     if unsigned_value >= 0x80000000:
    #         signed_value = unsigned_value - 0x100000000
    #     else:
    #         signed_value = unsigned_value

    def data_stream_dig_unit(self, samples, name, test):
        # mics = self.driver.get_mics(samples)
        # mics = self.driver.get_mics(samples) / 7812.5
        mics = self.driver.get_mics(samples) / 640.0
        # mics = self.driver.get_mics(samples) / 2604.1
        # mics = self.driver.get_mics(samples) / 5000.0
        analog_mic = mics.astype(np.int32)
        self.plot_step_response(analog_mic, "{}_{}_{}".format(name, "analog", test))
        self.gen_audio(analog_mic,"{}_{}_{}".format(name, "analog", test))


    def data_stream_diga(self, samples, name, test, cic=0):
        if cic == 0:
            self.driver.set_cic(0)
        if cic == 3:
            self.driver.set_cic(3)
        if cic == 2:
            self.driver.set_cic(2)
        if cic == 1:
            self.driver.set_cic(1)

        mics = self.driver.get_mics_ad(samples)
        reshaped_array = np.vstack([mics[i::2] for i in range(2)])
        # analog_mic = reshaped_array[1]
        # CIC 3 48k, 64, 
        if cic == 3:
            analog_mic = reshaped_array[0].astype(np.int32) / 2604.1 
        # CIC 2 16k, 200, 
        elif cic == 2:
            analog_mic = reshaped_array[0].astype(np.int32) / 8000.0 
        # CIC 1 25k, 125, 
        elif cic == 1:
            analog_mic = reshaped_array[0].astype(np.int32) / 5000.0
        elif cic == 0:
        # 192k, 16. CIC 0 
            # analog_mic = reshaped_array[0].astype(np.int32) / 640.0
            analog_mic = reshaped_array[0].astype(np.int32) / 1280.0

        dig_mic = reshaped_array[1].astype(np.int32) 
        # dig_mic = reshaped_array[0].astype(np.int32) / 5000.0
        # dig_mic = reshaped_array[0].astype(np.int32) / 7812.5
        # dig_mic = reshaped_array[0].astype(np.int32)
        self.plot_dual_axis(analog_mic, dig_mic, "{}_{}_{}".format(name, "dual", test), "Analog Mic", "Digital Mic", True)
        # self.plot_step_response(analog_mic, "{}_{}_{}".format(name, "analog", test))
        self.gen_audio(analog_mic,"{}_{}_{}".format(name, "analog", test))
        # self.plot_step_response(dig_mic, "{}_{}_{}".format(name, "digital", test))
        self.gen_audio(dig_mic,"{}_{}_{}".format(name, "digital", test))

    def data_stream_diga2(self, samples, name, test, cic=0):
        if cic == 0:
            self.driver.set_cic(0)
        if cic == 3:
            self.driver.set_cic(3)
        if cic == 2:
            self.driver.set_cic(2)
        if cic == 1:
            self.driver.set_cic(1)

        mics = self.driver.get_mics_ad(samples)
        reshaped_array = np.vstack([mics[i::2] for i in range(2)])
        # analog_mic = reshaped_array[1]
        # CIC 3 48k, 64, 
        if cic == 3:
            analog_mic1 = reshaped_array[0].astype(np.int32) / 2604.1 
            analog_mic2 = reshaped_array[1].astype(np.int32) / 2604.1 
        # CIC 2 16k, 200, 
        elif cic == 2:
            analog_mic1 = reshaped_array[0].astype(np.int32) / 8000.0 
            analog_mic2 = reshaped_array[1].astype(np.int32) / 8000.0 
        # CIC 1 25k, 125, 
        elif cic == 1:
            analog_mic1 = reshaped_array[0].astype(np.int32) / 5000.0
            analog_mic2 = reshaped_array[1].astype(np.int32) / 5000.0
        elif cic == 0:
        # 192k, 16. CIC 0 
            # analog_mic = reshaped_array[0].astype(np.int32) / 640.0
            analog_mic1 = reshaped_array[0].astype(np.int32) / 1280.0
            analog_mic2 = reshaped_array[1].astype(np.int32) / 1280.0

        self.plot_dual_axis(analog_mic1, analog_mic2, "{}_{}_{}".format(name, "dual", test), "Analog Mic Infineon", "Analog Mic SPM", True)
        # self.plot_step_response(analog_mic, "{}_{}_{}".format(name, "analog", test))
        self.gen_audio(analog_mic1,"{}_{}_{}".format(name, "analog_infineon", test))
        # self.plot_step_response(dig_mic, "{}_{}_{}".format(name, "digital", test))
        self.gen_audio(analog_mic2,"{}_{}_{}".format(name, "analog_spm", test))

    def plot_dual_axis(self, analog_data, digital_data, title, analog_label, digital_label, block):
        time_axis = np.arange(len(analog_data)) 

        # digital_data = digital_data - np.mean(digital_data)
        analog_range = max(analog_data) - min(analog_data)
        digital_range = max(digital_data) - min(digital_data)

        # snr_analog_db = self.calculate_snr(analog_data)
        # snr_digital_db = self.calculate_snr(digital_data)

        fig, ax1 = plt.subplots(figsize=(10, 6))
        ax2 = ax1.twinx()
        
        # ax1.scatter(time_axis, analog_data, label=f"{analog_label} (Range: {analog_range:.2f} )", color='blue')
        ax1.plot(time_axis, analog_data, label=f"{analog_label} (Range: {analog_range:.2f} )", color='blue')
        ax2.plot(time_axis, digital_data, label=f"{digital_label} (Range: {digital_range:.2f} )", color='orange')
        
        ax1.set_xlabel("Time (s)")
        ax1.set_ylabel("Analog Amplitude", color='blue')
        ax2.set_ylabel("Digital Amplitude", color='orange')
        ax1.set_title(title)
        
        ax1.grid(True)
        ax1.legend(loc='upper left')
        ax2.legend(loc='upper right')
        
        plt.tight_layout()
        plt.savefig(f'{title}.png')
        plt.show(block=block)

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

    def data_flow(self, samples, name):
        mics = self.driver.get_mics3(samples)
        reshaped_array = np.vstack([mics[i::32] for i in range(32)])
        self.plot_all(reshaped_array, "{}{}".format(name, 66))
        # reshaped_array = mics.reshape(8, samples)
        # for i in range(samples):
        # for i in range(16):
        #     self.plot_step_response(reshaped_array[i], "{}{}".format(name, i))
        #     self.gen_audio(reshaped_array[i],"{}{}".format(name, i))

   
    def data_stream_pro2(self, samples, name):
        mics = self.driver.get_mics1(samples)
        reshaped_array = np.vstack([mics[i::8] for i in range(8)])
        # reshaped_array = mics.reshape(8, samples)
        # for i in range(samples):
        for i in range(8):
            self.gen_audio(reshaped_array[i],"{}{}".format(name, i))
        self.plot_all(reshaped_array, "{}{}".format(name, 66))

    def data_stream_pro(self, samples, name):
        mics = self.driver.get_mics1(samples)
        reshaped_array = np.vstack([mics[i::30] for i in range(30)])
        # reshaped_array = mics.reshape(8, samples)
        # for i in range(samples):
        for i in range(30):
            self.gen_audio(reshaped_array[i],"{}{}".format(name, i))
        self.plot_all(reshaped_array, "{}{}".format(name, 66))

    def data_streameru(self, samples, name):
        mics = self.driver.get_mics1(samples)
        reshaped_array = np.vstack([mics[i::8] for i in range(8)])
        # reshaped_array = mics.reshape(8, samples)
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
        mics = self.driver.get_mic(samples)
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

        data = data - np.mean(data)
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

    def plot_all(self, data_arrays, name):
        """
        Plots multiple arrays of data on the same plot.
    
        Parameters:
        - data_arrays: List or array of arrays, where each sub-array represents a dataset to be plotted.
        - name: The base name for the plot and legend.
        """
        # plt.subplots(figsize=(10, 6))
        # plt.figure(figsize=(10, 6))
        
        for idx, data in enumerate(data_arrays):
            time_axis = np.arange(len(data))
            plt.plot(time_axis, data, label="{} {}".format(name, idx))  # Add index to the label for distinction
    
        plt.title("{}".format(name))
        plt.xlabel("Time (s)")
        plt.ylabel("Amplitude")
        plt.grid(True)
        plt.legend()
        plt.tight_layout()
        plt.savefig("{}.png".format(name))  # Save the plot as a PNG file
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
        # data_centered = data - np.mean(data)
        # data_normalized = data_centered / np.max(np.abs(data_centered))
        # data_int16 = np.int16(data_normalized * 32767)
        # sample_rate = 48000  # For example, if your decimated audio is 48 kHz
        # write("{}.wav".format(name), sample_rate, data_int16)
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

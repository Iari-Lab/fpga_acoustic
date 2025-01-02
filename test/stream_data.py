#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import os
import time
from sesenta import Sesenta
from koheron import connect
import matplotlib
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
        client = connect(host, 'sesenta', restart=False)
        self.driver = Sesenta(client)
        self.driver.reset_clk_leds() 
        self.driver.reset_clk_mics()
        self.driver.reset_led()


    def data_stream(self, samples):
        manager = QueueManager(address=('localhost', 50000), authkey=b'abc')
        manager.connect()
        data_queue = manager.get_queue()
        mics = self.driver.get_mics(samples)
        grouped = mics.reshape(-1, 8)
        print(grouped)
        for i in range(samples):
            sample = grouped[i].tolist()
            data_point = sample, i
            print(data_point)
            data_queue.put(data_point)

    def data_stream_live(self, samples=1, enable_transfer=False, isv2=False):
        chunks = 24
        n = samples // chunks
        manager = QueueManager(address=('localhost', 50000), authkey=b'abc')
        manager.connect()
        data_queue = manager.get_queue()
        for i in range(n):
            try:
                mics = self.driver.get_mics(chunks)
                grouped = mics.reshape(-1, 8)
                print(grouped)
                for j in range(chunks):
                    sample = grouped[j].tolist()
                    data_point = sample, j
                    print(data_point)
                    data_queue.put(data_point)
            except KeyboardInterrupt:
                break  


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

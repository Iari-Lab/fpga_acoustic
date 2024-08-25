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

def initialize_driver(host):
    client = connect(host, 'sesenta', restart=False)
    driver = Sesenta(client)
    return driver

def initialize_plot(driver, sampling_frequency):
    """Initialize the dynamic plot."""
    t = np.arange(1<<14) / sampling_frequency
    t_us = 1e6 * t
    
    fig, ax = plt.subplots()
    line1 = Line2D([], [], color='green', label='mic1')
    ax.add_line(line1)
    line2 = Line2D([], [], color='green', label='mic2')
    ax.add_line(line2)
    line3 = Line2D([], [], color='green', label='mic3')
    ax.add_line(line3)
    line4 = Line2D([], [], color='green', label='mic4')
    ax.add_line(line4)
    line5 = Line2D([], [], color='green', label='mic5')
    ax.add_line(line5)
    line6 = Line2D([], [], color='green', label='mic6')
    ax.add_line(line6)
    line7 = Line2D([], [], color='green', label='mic7')
    ax.add_line(line7)
    line8 = Line2D([], [], color='green', label='mic8')
    ax.add_line(line8)

    ax.set_xlabel('Time (us)')
    ax.set_ylabel('sesenta')
    ax.set_xlim((t_us[0], t_us[-1]))
    ax.set_ylim((0, 2**30))
    ax.legend()
    
    fig.canvas.draw()
    
    return fig, line1,line2,line3,line4,line5,line6,line7,line8, t_us




def main(trigger_addr_count=False):
    """Main function to run the dynamic plot."""
    host = os.getenv('HOST', '192.168.0.208')
    sampling_frequency = 125e6 # Hz
    
    driver = initialize_driver(host)
    
    # fig, line1, t_us = initialize_plot(driver, sampling_frequency)
    fig, line1,line2,line3,line4,line5,line6,line7,line8, t_us = initialize_plot(driver, sampling_frequency)
    if not trigger_addr_count:
        driver.trigger_mic_rst() 
        driver.trigger_addr_count_rst()
        driver.trigger_led_rst()

    iteration_count = 0
    try:
        while True:
            iteration_count += 1
            print(iteration_count)
            li = driver.get_mic()
            line1.set_data(t_us, li)

            li1 = driver.get_mic1()
            line2.set_data(t_us, li1)

            li2 = driver.get_mic2()
            line3.set_data(t_us, li2)

            li3 = driver.get_mic3()
            line4.set_data(t_us, li3)

            li4 = driver.get_mic4()
            line5.set_data(t_us, li4)

            li5 = driver.get_mic5()
            line6.set_data(t_us, li5)

            li6 = driver.get_mic6()
            line7.set_data(t_us, li6)

            li7 = driver.get_mic7()
            line8.set_data(t_us, li7)

            fig.canvas.draw()
            plt.pause(0.001)
            
    except KeyboardInterrupt:
        print("Interrupted by user. Exiting.")
        exit(0)

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

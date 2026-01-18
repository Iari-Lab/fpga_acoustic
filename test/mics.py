from stream_data import Acoustic
from time import sleep
fpga = None
def record_all_mics(fpga):
    # mics_map = [i for i in range(0, 60, 2)]
    # mics = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 22, 24, 28, 30, 34, 36, 42, 44, 50, 52, 58] 
    # mapping = {i: i - 60 for i in mics}
    fpga.driver.record()
    for mic in range(8):
        fpga.data_bram_ith(mic)
        # sleep(0.5)
    fpga.driver.bf()
    # for mic in range(len(mics_map)):
    #     fpga.driver.beamf(mic)
    #     sleep(0.5)


if __name__ == "__main__":
    # ip_address = sys.argv[1]
    fpga = Acoustic()
    fpga.initialize_driver("192.168.8.236")
    # for i in range(30):
    #     fpga.data_flow_ith(1<<9, "mics", i)
'''
ipy mics.py -i
fpga.data_stream_pro6(1<<10, 4, "test", "mini")
fpga.data_brams4(9, 1<<11, "test_1", "mini")
'''
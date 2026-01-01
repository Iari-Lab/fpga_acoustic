from stream_data import Acoustic
from time import sleep
fpga = None
def record_all_mics(fpga):
    mics_map = [i for i in range(0, 60, 2)]
    fpga.driver.record()
    for mic in range(len(mics_map)):
        fpga.data_bram_ith(mic)
        sleep(0.5)

if __name__ == "__main__":
    # ip_address = sys.argv[1]
    fpga = Acoustic()
    fpga.initialize_driver("192.168.8.235")
    # for i in range(30):
    #     fpga.data_flow_ith(1<<9, "mics", i)
'''
ipy mics.py -i
fpga.data_stream_pro6(1<<10, 4, "test", "mini")
fpga.data_brams4(9, 1<<11, "test_1", "mini")
'''
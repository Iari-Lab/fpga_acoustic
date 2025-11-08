from stream_data import Acoustic

if __name__ == "__main__":
    # ip_address = sys.argv[1]
    fpga = Acoustic()
    fpga.initialize_driver("192.168.8.235")
    # for i in range(30):
    #     fpga.data_flow_ith(1<<9, "mics", i)
'''
ipy mics.py -i
fpga.data_stream_pro6(1<<10, 4, "test", "mini")
'''
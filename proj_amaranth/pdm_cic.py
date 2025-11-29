#!/usr/bin/env python3
#
# Copyright (c) 2021 Kaz Kojima <kkojima@rr.iij4u.or.jp>
# SPDX-License-Identifier: CERN-OHL-W-2.0

from amaranth import *
from amaranth.lib.fifo import SyncFIFO
from amaranth.hdl.ast import Rose, Fell
from amaranth.cli import main

from amaranth.back import verilog
from test import GatewareTestCase, sync_test_case
from test.clockdivider import SimpleClockDivider
from fixedpointcicfilter import FixedPointCICFilter
import numpy as np

class PDM(Elaboratable):
    """ PDM to PCM filter pipeline

        Attributes
        ----------
        pdm_clock_out: Signal(), output
            PDM clock signal
        pdm_data_in: Signal(), input
            PDM data signal
        pdm_clock_in: Signal(), input
            external PDM clock signal
        pdm_clock_in_en: Signal(), input
            enable external PDM clock
        pcm_strobe_out: Signal(), out
            PCM clock signal
        pcm_data_out: Signal(width), out
            PCM data signal

        Parameters
        ----------
        divisor: int
            clock divisor constant
        bitwidth: int
            width
        fraction_width: int
            fraction width
        cic_stage: int
            stage number of CIC filter
        cic_decimation: int
            decimation constant of CIC filter
        hb1_order: int
            order of the 1st Half-band filter
        hb2_order: int
            order of the 2nd Half-band filter
        fir_order: int
            order of FIR filter
        fir_cutoff: list
            start/stop band frequencies of FIR filter
        fir_rpl_att: list
            ripple/attenuation of pass/stop bands
        """
    def __init__(self,
                 divisor: int=40,
                 bitwidth: int=32,
                 cic_stage: int=5,
                 cic_decimation: int=64):
        self.pdm_clock_in_en = Signal()
        self.pdm_clock_in = Signal()
        self.pdm_clock_out = Signal()
        self.pdm_data_in = Signal()
        self.pcm_strobe_out = Signal()
        self.pcm_data_out = Signal(signed(bitwidth))

        self.divisor = divisor
        self.bitwidth = bitwidth
        self.cic_stg = cic_stage
        self.cic_decim = cic_decimation

    def elaborate(self, platform) -> Module:
        m = Module()

        pdm_clock_in_sy0 = Signal()
        pdm_clock_in_sy1 = Signal()
        base_clock = Signal()
        strobe_in = Signal()
        strobe_out = Signal()

        clk_divider = SimpleClockDivider(self.divisor)
        m.submodules.clk_divider = clk_divider
        m.d.comb += clk_divider.clock_enable_in.eq(~self.pdm_clock_in_en)
        m.d.sync += [
            pdm_clock_in_sy0.eq(self.pdm_clock_in),
            pdm_clock_in_sy1.eq(pdm_clock_in_sy0)
        ]
        m.d.sync += self.pdm_clock_out.eq(clk_divider.clock_out)

        m.d.comb += base_clock.eq(Mux(self.pdm_clock_in_en,
                                      pdm_clock_in_sy1,
                                      clk_divider.clock_out))

        strobe_in = Rose(base_clock, domain="sync")

        bw = self.bitwidth

        cic = FixedPointCICFilter(bitwidth=bw,
                                  filter_stage=self.cic_stg,
                                  decimation=self.cic_decim,
                                  verbose=False)
        m.submodules.cic = cic

        pdm_data_in_sy0 = Signal()
        pdm_data_in_sy1 = Signal()
        m.d.sync += [
            pdm_data_in_sy0.eq(self.pdm_data_in),
            pdm_data_in_sy1.eq(pdm_data_in_sy0)
        ]

        with m.If(pdm_data_in_sy1):
            m.d.comb += cic.signal_in.eq(1)
        with m.Else():
            m.d.comb += cic.signal_in.eq(-1)

        m.d.comb += [
            cic.strobe_in.eq(strobe_in),
            strobe_out.eq(cic.strobe_out),
            self.pcm_strobe_out.eq(strobe_out),
        ]

        with m.If(strobe_out):
            m.d.sync += self.pcm_data_out.eq(cic.signal_out)

        return m

class PDM2PCMTest(GatewareTestCase):
    FRAGMENT_UNDER_TEST = PDM
    FRAGMENT_ARGUMENTS = dict(divisor=8)

    @sync_test_case
    def test_pdm2pcm(self):
        dut = self.dut
        N = 4096
        v = np.load('test/sine_ord4_osr64.npy')
        yield dut.pdm_clock_in_en.eq(0)
        for i in range(N*32):
            yield dut.pdm_data_in.eq(1 if v[i//64] > 0 else 0)
            #yield dut.pdm_clock_in.eq(1 if (i%16) >= 8 else 0)
            yield
def save_file(module_name, verilog_str):
    file_out = f'{module_name}.v'
    with open(file_out, 'w') as f:
        f.write(verilog_str)

if __name__ == "__main__":

    pdm2cic = PDM()

    ports = [
        pdm2cic.pdm_clock_in_en,
        pdm2cic.pdm_clock_in,
        pdm2cic.pdm_data_in,
        pdm2cic.pcm_strobe_out,
        pdm2cic.pcm_data_out,   
        pdm2cic.pdm_clock_out, 
        pdm2cic.cic_sel

    ]
    v = verilog.convert(
        pdm2cic, name="dmic_cic", ports=ports,
        emit_src=False, strip_internal_attrs=True)
    print(v)
    save_file("{}".format("dmic_cic"), v)

# if __name__ == "__main__":

#     pdm2pcm = PDM()

#     ports = [
#         pdm2pcm.pdm_clock_in_en,
#         pdm2pcm.pdm_clock_in,
#         pdm2pcm.pdm_data_in,
#         pdm2pcm.pcm_strobe_out,
#         pdm2pcm.pcm_data_out,   
#         pdm2pcm.pdm_clock_out

#     ]
#     # main(pdm2pcm, name="PDM2PCM", ports=ports)
#     v = verilog.convert(
#         pdm2pcm, name="pdm_cic", ports=ports,
#         emit_src=False, strip_internal_attrs=True)
#     print(v)

# if __name__ == "__main__":

#     pdm2pcm = PDM2PCM()

#     ports = [
#         pdm2pcm.pdm_clock_in_en,
#         pdm2pcm.pdm_clock_in,
#         pdm2pcm.pdm_clock_out,
#         pdm2pcm.pdm_data_in,
#         pdm2pcm.pcm_strobe_out,
#         pdm2pcm.pcm_data_out
#     ]
#     main(pdm2pcm, name="PDM2PCM", ports=ports)

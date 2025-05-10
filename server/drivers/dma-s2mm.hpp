/// DMA S2MM driver
///
/// (c) Koheron

// https://www.xilinx.com/support/documentation/ip_documentation/axi_dma/v7_1/pg021_axi_dma.pdf

#ifndef __SERVER_DRIVERS_DMA_S2MM_HPP__
#define __SERVER_DRIVERS_DMA_S2MM_HPP__

#include <context.hpp>

#include <chrono>

class DmaS2MM
{
  public:
    DmaS2MM(Context& ctx_)
    : ctx(ctx_)
    , dma(ctx.mm.get<mem::dma>())
    , dma1(ctx.mm.get<mem::dma1>())
    , axi_hp0(ctx.mm.get<mem::axi_hp0>())
    , axi_hp1(ctx.mm.get<mem::axi_hp1>())
    {
        // Set AXI_HP0 to 32 bits
        axi_hp0.set_bit<0x0, 0>();
        axi_hp0.set_bit<0x14, 0>();
        // axi_hp1.set_bit<0x0, 0>();
        // axi_hp1.set_bit<0x14, 0>();
    }

    // void setup_transfer(uint32_t dest_addr, uint32_t length) {
    //     reset();
    //     ctx.print<DEBUG>("DmaS2MM::1");
    //     start();
    //     ctx.print<DEBUG>("DmaS2MM::2");
    //     set_destination_address(dest_addr);
    //     // set_destination_address(dest_addr+16384*8));
    //     ctx.print<DEBUG>("DmaS2MM::3");
    //     set_length(length);
    //     ctx.print<DEBUG>("DmaS2MM::4");
    // }
    // void wait(float transfer_duration_seconds) {
    //     float duration = transfer_duration_seconds;
    //     const auto target_duration = std::chrono::milliseconds(static_cast<uint32_t>(1000 * duration));
    //     auto remaining_time = target_duration;
    //     auto check_interval = std::chrono::milliseconds(500); // Interval for sleeping and checking status
    //     // while ( remaining_time.count() > 0 || (! idle())) {
    //     while ( remaining_time.count() > 0 ) {
    //         std::this_thread::sleep_for(check_interval);
    //         remaining_time -= check_interval;
    //     }
    //     // while (remaining_time.count() > 0) {
    //     //     std::this_thread::sleep_for(check_interval);
    //     //     remaining_time -= check_interval;
    //     // }
    // }
  void setup_transfer(uint32_t dest_addr, uint32_t dest_addr2, uint32_t length) {
        reset();
        start();
        set_destination_address(dest_addr, dest_addr2);
        set_length(length);
    }

    void wait_for_transfer(float dma_transfer_duration_seconds) {
        float t = dma_transfer_duration_seconds;
        const auto dma_duration = std::chrono::milliseconds(uint32_t(2000 * t));
        // Total sleep duration
        auto total_sleep_duration = dma_duration;
        auto sleep_interval = std::chrono::milliseconds(600); // Sleep interval in milliseconds

        ctx.print<INFO>("dma_transfer_duration_seconds: %f\n", (double)dma_transfer_duration_seconds);
        while (total_sleep_duration.count() > 0) {
            std::this_thread::sleep_for(sleep_interval);
            total_sleep_duration -= sleep_interval;
            ctx.print<INFO>("DmaS2MM::start: halted = %d, idle = %d\n", halted()?1:0, idle()?1:0);
            ctx.print<INFO>("DmaS2MM::start: halted = %d, idle = %d\n", halted1()?1:0, idle1()?1:0);
            // if (!idle() ) {
            //     ctx.print<DEBUG>("BREAK, iddle active: %d ms remaining\n", total_sleep_duration.count());
            //     break;
            // }
        }
    } 

    // // Ideally would take a std::chrono::duration as an argument
    // void wait_for_transfer(float dma_transfer_duration_seconds) {
    //     const auto dma_duration = std::chrono::milliseconds(uint32_t(1000 * dma_transfer_duration_seconds));
    //     uint32_t cnt = 0;

    //     while (! idle()) {
    //         std::this_thread::sleep_for(0.55 * dma_duration);
    //         cnt++;

    //         if (cnt > max_sleeps_cnt) {
    //             ctx.log<ERROR>("DmaS2MM::wait_for_transfer: Max number of sleeps exceeded. [set duration %f s]\n",
    //                            double(dma_transfer_duration_seconds));
    //             break;
    //         }
    //     }
    // }

  private:
    static constexpr uint32_t s2mm_dmacr  = 0x30;  // S2MM DMA Control register
    static constexpr uint32_t s2mm_dmasr  = 0x34;  // S2MM DMA Status register
    static constexpr uint32_t s2mm_da     = 0x48;  // S2MM Destination Address
    static constexpr uint32_t s2mm_length = 0x58;  // S2MM Buffer Length (Bytes)

    static constexpr uint32_t max_sleeps_cnt = 4;

    Context& ctx;
    Memory<mem::dma>& dma;
    Memory<mem::dma1>& dma1;
    Memory<mem::axi_hp0>& axi_hp0;
    Memory<mem::axi_hp1>& axi_hp1;

    void reset() {
        dma.set_bit<s2mm_dmacr, 2>();
        dma1.set_bit<s2mm_dmacr, 2>();

        // Wait for reset
        uint32_t cnt = 0;

        while (dma.read_bit<s2mm_dmacr, 2>()) {
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
            cnt++;

            if (cnt > max_sleeps_cnt) {
                ctx.log<ERROR>("DmaS2MM::reset: Max number of sleeps exceeded.\n");
                break;
            }
        }
        while (dma1.read_bit<s2mm_dmacr, 2>()) {
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
            cnt++;

            if (cnt > max_sleeps_cnt) {
                ctx.log<ERROR>("DmaS2MM::reset: Max number of sleeps exceeded.\n");
                break;
            }
        }
    }

    void start() {
        dma.set_bit<s2mm_dmacr, 0>();
        dma1.set_bit<s2mm_dmacr, 0>();

        // Wait for start up
        uint32_t cnt = 0;

        while (halted()) {
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
            cnt++;

            if (cnt > max_sleeps_cnt) {
                ctx.log<ERROR>("DmaS2MM::start: Max number of sleeps exceeded.\n");
                break;
            }
        }
        while (halted1()) {
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
            cnt++;

            if (cnt > max_sleeps_cnt) {
                ctx.log<ERROR>("DmaS2MM::start: Max number of sleeps exceeded.\n");
                break;
            }
        }
    }

    void set_destination_address(uint32_t address, uint32_t address2) {
        dma.write<s2mm_da>(address);
        dma1.write<s2mm_da>(address2);
    }


    void set_length(uint32_t length) {
        dma.write<s2mm_length>(length);
        dma1.write<s2mm_length>(length);
    }

    // Status

    bool halted() {
        return dma.read_bit<s2mm_dmasr, 0>();
    }

    bool halted1() {
        return dma1.read_bit<s2mm_dmasr, 0>();
    }

    bool idle() {
        return dma.read_bit<s2mm_dmasr, 1>();
    }

    bool idle1() {
        return dma1.read_bit<s2mm_dmasr, 1>();
    }
};

#endif // __SERVER_DRIVERS_DMA_S2MM_HPP__
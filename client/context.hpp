/// (c) Koheron

#ifndef __CONTEXT_HPP__
#define __CONTEXT_HPP__

#include <context_base.hpp>

#include <memory_manager.hpp>
#include <fpga_manager.hpp>

#include "memory.hpp"

class Context : public ContextBase
{
  public:
    Context()
    : mm()
    , fpga(*this)
    {
    }

    int init() {
        if (mm.open() < 0)
            return -1;

        return 0;
    }

    MemoryManager mm;
    FpgaManager fpga;
};

#endif // __CONTEXT_HPP__

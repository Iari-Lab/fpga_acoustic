/// (c) Koheron

#ifndef __CONTEXT_BASE_HPP__
#define __CONTEXT_BASE_HPP__

#include <syslog.hpp>

namespace koheron {
} // namespace koheron

class ContextBase
{
  private:
    koheron::SysLog *syslog;


    void set_syslog(koheron::SysLog *syslog_) {
        syslog = syslog_;
    }

  public:

    template<int severity, typename... Args>
    void log(const char *msg, Args&&... args) {
        syslog->print<severity>(msg, std::forward<Args>(args)...);
    }

    template<int severity, typename... Args>
    void print(const char *msg, Args&&... args) {
        koheron::printf(msg, std::forward<Args>(args)...);
    }

  protected:
    virtual int init() { return 0; }

};

#endif // __CONTEXT_BASE_HPP__
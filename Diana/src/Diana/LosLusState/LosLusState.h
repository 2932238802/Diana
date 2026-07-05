#pragma once

#include "lua.hpp"

namespace LosDiana
{
    class LosLuaState
    {
      public:
        LosLuaState();
        ~LosLuaState();

      public: // get
        lua_State *state();


      public: // tool
        int doString(const char *);
        int getInt();
        int doFile(const char *);

      private:
        lua_State *L_L;
    };
} // namespace LosDiana
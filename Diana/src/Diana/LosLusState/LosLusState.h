#pragma once

#include "godot_cpp/variant/string.hpp"
#include "lua.hpp"
#include <type_traits>

namespace LosDiana
{
    class LosLuaState
    {
      public:
        LosLuaState();
        ~LosLuaState();

      public: // get
        lua_State *state();

      public:                       // tool
        int doString(const char *); // F
        int getInt();               // lua_tointeger
        int doFile(const char *);
        bool isTable(int pos = -1);
        void pop(int number = 1);

        template <class T> T getfieldWithPop(const char *s, int pos = -1) // lua_getfield
        {
            T result{};
            lua_getfield(L_L, pos, s);
            if constexpr (std::is_arithmetic_v<T>)
            {
                result = static_cast<T>(lua_tonumber(L_L, -1));
            }
            else if constexpr (std::is_same<T, godot::String>::value)
            {
                result = godot::String::utf8(lua_tostring(L_L, -1));
            }
            else
            {
                // 这里表示只有 代码 走到这个位置 才会报错 因为 类型都是 0
                static_assert(sizeof(T) == 0, "getField 只支持数字类型或 godot::String");
            }
            pop();
            return result;
        }

      private:
        lua_State *L_L;
    };
} // namespace LosDiana
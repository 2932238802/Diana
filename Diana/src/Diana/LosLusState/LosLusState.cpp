

#include "LosLusState.h"
#include "lauxlib.h"
#include "lua.hpp"

namespace LosDiana
{
    /**
     * @brief Construct a new Los Lua State:: Los Lua State object
     */
    LosLuaState::LosLuaState()
    {
        L_L = luaL_newstate();
        luaL_openlibs(L_L);
    }



    /**
     * @brief Destroy the Los Lua State:: Los Lua State object
     */
    LosLuaState::~LosLuaState()
    {
        lua_close(L_L);
    }



    /**
     * @brief
     *
     * @return lua_State*
     */
    lua_State *LosLuaState::state()
    {
        return L_L;
    }



    /**
     * @brief do string
     *
     * @param s
     * @return int
     */
    int LosLuaState::doString(const char *s)
    {
        return luaL_dostring(L_L, s);
    }



    /**
     * @brief
     *
     * @return int
     */
    int LosLuaState::getInt()
    {
        int v = (int)lua_tointeger(L_L, -1);
        lua_pop(L_L, 1);
        return v;
    }



    /**
     * @brief
     *
     * @return int
     */
    int LosLuaState::doFile(const char *file)
    {
        return luaL_dofile(L_L, file);
    }

    

    /**
     * @brief
     *
     * @param pos
     * @return true
     * @return false
     */
    bool LosLuaState::isTable(int pos)
    {
        return lua_istable(L_L, pos);
    }



    /**
     * @brief 弹出栈顶
     */
    void LosLuaState::pop(int number)
    {
        lua_pop(L_L, number);
    }



} // namespace LosDiana
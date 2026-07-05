#pragma once

#include "godot_cpp/classes/node.hpp"
#include "godot_cpp/classes/wrapped.hpp"

#include "LosLusState/LosLusState.h"
#include "godot_cpp/variant/string.hpp"

namespace LosDiana
{
    class LosLua : public godot::Node
    {
        GDCLASS(LosLua, godot::Node)

      public:
        LosLua();
        ~LosLua();

      private:
        static void _bind_methods();

      public: // lua
        int hello();
        bool loadEnemy(godot::String enemy_id);

      private:
        LosLuaState LOS_state;
    };
} // namespace LosDiana
#include "LosLua.h"
#include "godot_cpp/classes/project_settings.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/variant/dictionary.hpp"
#include "godot_cpp/variant/string.hpp"
#include "godot_cpp/variant/utility_functions.hpp"
#include "lua.hpp"

namespace LosDiana
{
    /**
     * @brief Construct a new Los Lua:: Los Lua object
     */
    LosLua::LosLua() {}
    LosLua::~LosLua() {}



    /**
     * @brief _bind_methods 规定的名字
     */
    void LosLua::_bind_methods()
    {
        godot::ClassDB::bind_method(godot::D_METHOD("lLuaLoadEnemy", "id"), &LosLua::loadEnemy);
        godot::ClassDB::bind_method(godot::D_METHOD("lLuaHello"), &LosLua::hello);
    }



    /**
     * @brief lLuaHello
     */
    int LosLua::hello()
    {
        int status = LOS_state.doString("return 3 + 5");
        int result = 0;
        if (status == LUA_OK)
        {
            result = LOS_state.getInt();
        }
        return result;
    }



    /**
     * @brief loadEnemy 加载enemy
     *
     * @param enemy_id
     * @return true
     * @return false
     */
    godot::Dictionary LosLua::loadEnemy(godot::String enemy_id)
    {
        godot::Dictionary result;
        godot::String res_path  = "res://game/data/enemies/" + enemy_id + "/" + enemy_id + ".lua";
        godot::String real_path = godot::ProjectSettings::get_singleton()->globalize_path(res_path);
        int status              = LOS_state.doFile(real_path.utf8().get_data());
        if (status != LUA_OK)
        {
            godot::UtilityFunctions::print("加载敌人配置失败: ", real_path);
            return result;
        }

        if (!LOS_state.isTable())
        {
            godot::UtilityFunctions::print("栈顶配置不是表", real_path);
            LOS_state.pop();
            return result;
        }

        result["id"]                = LOS_state.getfieldWithPop<godot::String>("id");
        result["name"]              = LOS_state.getfieldWithPop<godot::String>("name");
        result["health"]            = LOS_state.getfieldWithPop<double>("health");
        result["attack"]            = LOS_state.getfieldWithPop<double>("attack");
        result["speed"]             = LOS_state.getfieldWithPop<double>("speed");
        result["stop_distance"]     = LOS_state.getfieldWithPop<double>("stop_distance");
        result["attack_range"]      = LOS_state.getfieldWithPop<double>("attack_range");
        result["discover_distance"] = LOS_state.getfieldWithPop<double>("discover_distance");
        result["attack_type"]       = LOS_state.getfieldWithPop<int>("attack_type");
        result["projectile_speed"]  = LOS_state.getfieldWithPop<double>("projectile_speed");
        result["bullet_scene"]      = LOS_state.getfieldWithPop<godot::String>("bullet_scene");
        result["sprite_frames"]     = LOS_state.getfieldWithPop<godot::String>("sprite_frames");

        LOS_state.pop(); // 弹出表

        return result;
    }


} // namespace LosDiana
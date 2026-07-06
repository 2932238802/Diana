#include "LosEntrySymbol.h"
#include "LosLua/LosLua.h"
#include "godot_cpp/classes/engine.hpp"
#include "godot_cpp/core/memory.hpp"

extern "C"
{
    GDExtensionBool GDE_EXPORT LosEntrySymbol(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library,
                                              GDExtensionInitialization *r_initialization)
    {
        godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
        init_obj.register_initializer(LosEntrySymbolInit);
        init_obj.register_terminator(LosEntrySymbolUninit);
        init_obj.set_minimum_library_initialization_level(godot::MODULE_INITIALIZATION_LEVEL_SCENE);
        return init_obj.init();
    }
}

// 全局单例 C++ 状态类
static LosDiana::LosLua * LosLuaInstance = nullptr;



/**
 * @brief 初始化
 *
 * @param p_level
 */
void LosEntrySymbolInit(godot::ModuleInitializationLevel p_level)
{
    if (p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
        return;
    // 注册 LosLua
    godot::ClassDB::register_class<LosDiana::LosLua>();
    LosLuaInstance = memnew(LosDiana::LosLua);
    godot::Engine::get_singleton()->register_singleton("LosLuaInstance", LosLuaInstance);
}



/**
 * @brief 反初始化
 *
 * @param p_level
 */
void LosEntrySymbolUninit(godot::ModuleInitializationLevel p_level)
{
    if (p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
        return;

    if(LosLuaInstance != nullptr)
    {
        godot::Engine::get_singleton()->unregister_singleton("LosLuaInstance");
        memdelete(LosLuaInstance);
        LosLuaInstance = nullptr;
    }
}
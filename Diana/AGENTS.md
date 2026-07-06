# AGENTS.md — Diana 项目上下文

> 本文件用于记录项目的**背景、目标、技术架构、开发进度与协作规范**，
> 供 AI 助手（及任何协作者）快速对齐上下文。每完成一个阶段请更新「开发进度」。

---

## 1. 项目定位

- **项目名**：Diana
- **引擎**：Godot 4.6.2 stable（Forward+ / D3D12 渲染，Jolt Physics）
- **游戏类型**：单机 **俯视角地牢闯关 Roguelite**
- **核心玩法**：
  - 最高 **999+ 层**地牢，逐层闯关
  - 每层结束可**选择一个提升点（Buff / 词条）**
  - **武器掉落**系统，多种武器
- **视觉方向**：先纯 2D 起步（`CharacterBody2D`），跑通逻辑后再考虑 2.5D / 伪 3D 升级
- **开发原则**：**先跑通逻辑，再谈画面**；**完成度 > 一切**

---

## 2. 终极目标（Why）

作者目标是**进入腾讯 / 网易等大厂做 gameplay / 引擎相关岗位**。
本项目作为求职 Demo，需要体现：
- **架构设计能力**（清晰的分层、解耦）
- **Gameplay 系统实现**（战斗、技能、AI、Roguelite 词条）
- **对引擎底层与性能的理解**（C++ 优化亮点）
- **高完成度**（一个"做完了的、好玩的"游戏）

**面试话术目标**（最终要能讲出这段）：
> 用 GDScript 搭游戏框架，用 Lua 做数据驱动的技能 / 武器 / 词条配置（支持热更），
> 当高层数海量敌人同屏出现性能瓶颈时，用 C++ GDExtension 把碰撞检测、移动计算、
> 随机地图生成重写成模块，显著提升帧率。

---

## 3. 技术架构：三语言分层（核心！）

| 层级 | 语言 | 中心职责 | 存放位置 |
|------|------|----------|----------|
| **底层核心** | **C++ / GDExtension** | 随机地图生成算法、海量单位移动/碰撞计算、核心战斗结算（性能敏感） | `src/` |
| **内容层** | **Lua** | 武器属性、技能效果、敌人 AI 行为、Buff/词条（数据驱动 + 热更） | `content/`（待建） |
| **表现/胶水层** | **GDScript** | UI、输入响应、场景流程、信号通信、动画/音效调用 | `scripts/` |

### 🕐 Lua / C++ 的引入时机（重要决策，2026-07-04 定）

**核心原则：技术要被"真实需求逼出来"，不是硬凑。先用 GDScript 跑通，遇到痛点再引入。**

- **Lua 登场时机 = 内容开始膨胀时**
  - 触发信号：开始复制粘贴一堆相似的武器/敌人/Buff 脚本、只改几个数值
  - 对应阶段：**武器系统 / Buff 词条系统**（需要多种内容时）
  - 作用：把武器/敌人/Buff 的数据和规则抽到 .lua 文件，加内容=加文件，改数值=改文本
  - 集成方式：Godot Lua 插件（godot-luaAPI / lua_gdextension）或自己用 C++ 集成 LuaJIT

- **C++ (GDExtension) 登场时机 = 遇到真实性能瓶颈时**
  - 触发信号：性能分析器显示某段逻辑吃掉大量帧时间、掉帧
  - 对应阶段：**海量敌人同屏卡顿** / **999层随机地图生成算法慢**
  - 作用：把性能热点（海量单位移动碰撞、地图生成）用 C++ 重写
  - 关键：先用 GDScript 写能跑的版本→测出慢→再用 C++ 优化（留下"优化前后帧率对比"数据，面试极有说服力）

- **反面教材（禁止）**：一上来就用 C++ 写血条、Lua 写菜单 = 过度设计
- **引入顺序 = 优秀工程师的决策故事**：GDScript 快速验证 → Lua 解耦内容 → C++ 优化性能

### 🔥 重大决策变更（2026-07-05）：作者选择提前搭 C++ GDExtension + Lua 底座（路线A）
- **背景**：作者铁了心要"硬核技术经历"，趁架构小提前把 C++/Lua 技术地基打好，避免以后大改。
  接受"搭环境期间游戏逻辑暂停几天"的代价。AI 已充分提示利弊，作者坚持路线A。
- **作者环境**：C++ 编译环境已具备 ✅
- **推进阶段（每步跑通再下一步）**：
  1. 搭 C++ 环境 + 编译出 Hello World GDExtension（godot-cpp + SCons + .dll，最难的环境关）
  2. C++ 里集成 Lua（LuaJIT/Lua 源码），跑通"C++ 读 .lua 文件"
  3. 敌人/关卡数据用 Lua 写，GDScript 经 C++ 读取（数据驱动）
  4. 回到游戏逻辑，用这套系统刷怪
- **面试价值**：自建 GDExtension + Lua 数据驱动框架 = 实打实硬核亮点
- **注意**：C++ 代码放 `src/`；此决策覆盖前面"C++暂不动手"的说明

> ~~注意：C++ 目前暂不动手~~（已被上述路线A决策覆盖）

### 📁 C++ / 构建目录约定（2026-07-05 定）
- **`scripts/`** = 脚本构建目录（放 SConstruct 等构建脚本）
- **`src/godot-cpp/`** = 官方 C++ 绑定库（4.4分支，已编译出 bin/libgodot-cpp.windows.template_debug.x86_64.lib）
- **`src/Diana/`** = 作者自己的 C++ 项目源码（GDExtension 类写这里）
- extension_api.json 已用 Godot 4.7 重新导出（--dump-extension-api），API 匹配 4.7
- 环境：Python 3.13 / SCons 4.10 / MSVC(VS in F:\VisualStdio) / Godot 4.7 (F:\Godot)

---
当前项目置在 "D:\LosAngelous\Los\Diana"

### 4.1 当前实际结构（已按功能模块重构完成 ✅）
```
D:\PR\Diana\Diana\
├── AGENTS.md
├── project.godot
├── icon.svg
├── hud_prototype.html   ← 血条HTML原型（可删）
├── autoload/            ← LosRouter.gd（事件总线）, LosPlayerState.gd（状态单例）
├── features/
│   └── player/          ← LosPlayer.tscn/.gd, bullet.tscn（+待建 LosBullet.gd）
├── levels/              ← level.tscn
├── systems/             ← camera.gd
├── ui/
│   └── hud/             ← LosHud.tscn, LosHud.gd
├── (features/inventory,crafting,shop,skills,events 空文件夹待用)
└── (assets/, src/, content/ 待用)
```

### 4.2 🎯 目标结构（按功能模块组织，2026-07-04 规划，待迁移）

**组织原则：按"功能模块"分（高内聚），而非按"文件类型"分。**
一个系统的场景+脚本+资源都放在同一个功能文件夹里，改哪个系统只进对应文件夹。

```
res://
├── autoload/              ← 全局单例（永不销毁，切场景不丢数据）
│   └── player_state.gd    ← 玩家持久状态（血量/层数/金币/背包数据）
│
├── features/             ← 【核心】按功能模块分，每个系统一个文件夹
│   ├── player/           ← player.tscn + player.gd
│   ├── inventory/        ← 背包系统
│   ├── crafting/         ← 物品合成系统
│   ├── shop/             ← 商店系统
│   ├── skills/           ← 技能系统
│   └── events/           ← 层间随机事件
│
├── levels/               ← 关卡场景（level.tscn 等）
├── ui/                   ← 通用 UI（main_menu/、hud/）
├── systems/              ← 跨模块系统脚本（camera.gd、场景管理器等）
├── content/              ← Lua 数据文件（武器/敌人/Buff 配置，未来）
├── assets/               ← 美术/音效（sprites/、audio/）
├── src/                  ← C++ 源码（GDExtension，未来）
└── AGENTS.md
```

### 4.3 ⚠️⚠️ 待办提醒：文件夹重构（重要！迁移时务必遵守）

> **AI 每次开始新任务时，若结构还是 4.1（旧结构），应主动提醒作者："要不要先做文件夹重构？"**

**迁移分工（关键坑！）**：
- ✅ **创建空文件夹** → AI 可用命令行/工具直接建（不影响引用）
- ❌ **移动已有文件**（player.tscn/gd、level.tscn、camera.gd）→ **绝对不能用命令行 mv！**
  必须由**作者在 Godot 编辑器的 FileSystem 面板里拖动**，Godot 会自动更新所有 res:// 引用路径和 uid，否则场景引用断裂、全部报错。

**迁移映射**：
- player.tscn + player.gd → features/player/
- level.tscn → levels/
- camera.gd → systems/
- （新建）player_state.gd → autoload/

---

## 4.5 🧭 架构决策必须面向未来（作者 2026-07-06 强调，最高优先级原则）

> **作者明确要求**：以后 AI 的所有回答，**不要只基于"眼前能跑通"**，必须**站在整个项目未来的架构高度**给方案，帮作者**少走弯路、不返工**。

### 核心原则
- **面向未来，不面向当下**：设计任何系统前，先问"这个东西以后会有几种/几个/怎么扩展"，按最终形态定架构，再退回到当前最小实现。
- **一次定对，避免重构**：宁可前期多想清楚职责边界，也不要"先耦合跑通、以后再拆"。作者接受"想清楚再动手"的节奏。
- **正规做法 > 临时凑合**：能用引擎/语言的正规机制解决的，不用 hack 或临时包一层的做法（例：C++ 类做 autoload 单例，直接在 C++ 层用 `register_singleton` 声明，而不是用 .tscn 包一层临时顶上）。
- **给方案时必须说明"未来会怎样"**：解释一个设计时，要讲清它在"多敌人/多关卡/海量单位/热更"等未来场景下如何演化，而不是只说当前这一步。

### 三层数据驱动架构（Lua 敌人/关卡系统的既定方向，务必遵守）
```
Lua 数据文件（内容层）
  enemy_1.lua (怪属性表)  /  level_1.lua (关卡刷怪表)
		↓ 读取
LosLua (C++ 数据访问层)  —— ★只吐 Dictionary 数据，绝不 instantiate 游戏对象
		↓ Dictionary
LosLevel (GDScript 总指挥/管理层) —— 读关卡表、生成敌人、setup_from_config 分发、L_enemies[] 管理
		↓ setup_from_config(config)
LosEnemy (GDScript 实体层) —— ★被动接收 config，只管自己表现/移动，不知道数据从哪来
```
**三条铁律**：
1. LosLua 只吐数据，绝不创建/持有游戏对象（数据访问层与实体层永不直接对话）。
2. LosLevel 是唯一"总指挥"，负责生成、分发、管理敌人（持有 `L_enemies[]`）。
3. LosEnemy 被动接收（依赖注入），不主动找数据源，方便换数据源/测试。

**扩展性目标（最终形态）**：
- 加新怪 = 加一个 `enemy_X.lua`，C++/GDScript 一行不改
- 加新关卡 = 加一个 `level_X.lua`（含 spawns 列表），代码不改
- 调难度 = 改 lua 文本的 count/数值，不动代码
- 性能：敌人属性配置应"读一次缓存复用"，不要每刷一只怪都重读 Lua 文件（面向海量单位）

### 关于 LosLua 单例（2026-07-06 决策：走 C++ 层正规 autoload）
- **决策**：LosLua 作为全局 Lua 环境基础设施，做成 **autoload 单例**，全程只有一个 `lua_State`，所有关卡共用；**不随关卡场景生生死死**（换关卡不该重建 Lua 环境，有创建/销毁成本）。
- **实现方式（作者选定：C++ 层直接声明，非 .tscn 临时包一层）**：
  在 GDExtension 初始化回调里，用 `godot::Engine::get_singleton()->register_singleton("LosLua", instance)` 注册；在终止回调里 `unregister_singleton` 并释放。详见「§8.2 C++ GDExtension autoload 单例」。
- **连带影响**：Level 场景里**不再挂 LosLua 子节点**；GDScript 里从 `$LosLua.xxx` 改为全局 `LosLua.xxx`（与 LosRouter/LosPlayerState 一致，不带 `$`）。

---

## 5. 作者背景与协作规范（重要！）

### 作者技术底子
- **C++**：熟悉指针、类、内存分配（有基础）✅
- **Lua**：写过 ✅
- **Godot / GDScript**：**不熟练**，正在学习中 ⚠️

### 教学协作规范（务必遵守）
- **明确分工（作者 2026-07-04 定，2026-07-05 再次强调）**：
  - **只有 `.tscn` 场景 / UI 配置 → AI 可直接修改**（节点结构、坐标、颜色、输入映射等）
  - **其他所有代码 → 作者本人写**：`.gd`(GDScript)、`.cpp/.h`(C++)、`.lua`、SConstruct、.gdextension 等
	AI 只讲原理、给代码内容供参考、答疑、review，**绝不直接写入这些文件**
  - ⚠️ AI 曾误直接写 C++ 文件，作者已纠正。**除 .tscn 外一律不动手写文件**
- **讲解代码时必须标注"写在哪个文件"（作者要求）**：
  每段代码前明确说明它属于哪个文件的实际路径（如"👉 写在 `features/player/LosPlayer/LosPlayer.gd`"），
  避免作者把代码写错文件。
- **以教学引导为主**：作者想边学边做。讲清楚"该建什么、怎么设计、为什么这样写"，
  让作者**自己动手写**；不要直接甩完整代码。
- 给移动/逻辑时，**给"零件"和思路，不给完整答案**，除非作者明确说"你来写/你帮我改"。
- **重视原理与架构**：多用作者熟悉的 C++ 概念类比（继承、成员、解耦等）。
- **循序渐进**：每一步必须跑通再进入下一步，不跑通不往下走（避免连环出错）。

### ⚠️ AI 操作边界（作者 2026-07-06 明确强调，务必遵守）
- **编译工作 AI 不做**：不主动运行 `scons` / `python -m SCons` 等任何编译/构建命令。编译由作者自己执行，AI 只提供编译指令文本、讲原理、看报错。
- **不随便动本地文件**：除 `.tscn` 和 `AGENTS.md`（作者明确要求记录时）外，AI 不主动创建/修改/移动任何本地文件（包括不主动跑构建产生文件）。需要改动时，先说明、给内容，由作者自己动手。
- **例外**：作者明确说"你来做/你帮我改/你移动"时，AI 才执行对应操作。

### 已纠正的编码习惯
- GDScript **不写分号 `;`**（C++ 习惯，需改掉）
- 输入用**动作名（Action）**而非物理键码；命名表达**意图**（`move_left`）而非按键（`KEY_LEFT`）
- 数值属性用 `@export` 暴露，为将来 Lua 数据驱动做准备

---

## 6. 开发进度

### ✅ 已完成
1. 建立工程与目录结构（scripts / scene / src）
2. 理解 Godot 核心机制：
   - `_ready()`（初始化，只调一次，类比构造函数）
   - `_process(delta)` vs `_physics_process(delta)`（渲染帧 vs 固定物理帧）
   - `delta` 帧率无关原理（速度 × delta）
   - 节点（Node）与场景（.tscn）关系；`.gd` 与 `.tscn` 是独立文件（多对多）
   - 继承机制：`extends CharacterBody2D`，`velocity`（成员变量）与 `move_and_slide()`（成员函数）来自基类
   - 输入系统解耦哲学：动作名 ↔ 物理按键映射
3. 创建 `player.gd`，`extends CharacterBody2D`

### ✅ 已完成：玩家移动 + 相机跟随（阶段完成！）
- player.tscn 节点树：Player(CharacterBody2D) + Sprite2D(icon.svg) + CollisionShape2D(CircleShape2D) + Camera2D
- 移动三件套写完：`Input.get_vector(...)` → `velocity = direction * L_speed` → `move_and_slide()`
- 输入映射已配置（注意：动作名用 `L_KEY_LEFT/RIGHT/UP/DOWN`，绑定**方向键 ← → ↑ ↓**，非 WASD）
- main_scene 已设为 player 场景，F5 可直接运行
- ✅ 已验证：方向键可移动方块，相机跟随

### ✅ 已完成：第一个地牢房间（4面墙）+ 移动碰撞全部跑通 🎉
- level.tscn 结构：Level(Node2D) → Player(实例) + Walls(Node2D容器) → WallTop/Bottom/Left/Right
- 每面墙 = StaticBody2D + CollisionShape2D(RectangleShape2D) + Polygon2D(红色外观)
- 房间内部空间约 800×600，玩家出生中心 (0,0)
- 玩家可移动、相机跟随、四面墙有效挡住玩家（碰撞验证通过）
- ⚠️ **重要经验教训**：主场景(Main Scene)一度错设为 player.tscn（无墙），导致长时间"看不到墙"。
  已改为 level.tscn。以后新增场景注意确认 Main Scene 指向正确。
- 调试技能记录：用 print(global_position) 打印坐标定位问题；分清 Remote 节点树看运行时实际加载的场景

### 📌 待办：确认主场景
- 需确认 项目设置 → Application → Run → Main Scene = level.tscn（若还是 player.tscn 请改过来）

### ⏳ 下一步计划
1. **敌人原型**（Enemy 场景，会朝玩家移动的追踪 AI）
2. 战斗系统（攻击、受击、血量）
3. 武器掉落 → 层间提升点选择
4. 引入 Lua 数据驱动（武器/词条配置）
5. C++ GDExtension 重构性能热点（随机地图生成 / 海量单位）
6. 后续房间考虑改用 TileMap（正规地牢做法）

### 📌 已清理
- player.gd 分号已删除 ✅

### ✅ 已完成（Los 前缀版，最新进度）🎉
- **状态系统**：LosPlayerState(数据单例) + LosRouter(事件总线,ls_health_changed信号) + LosHud(订阅信号更新血条/能量条)。数据→总线→UI 三层解耦
- **相机**：LosCamera.gd 挂 Level 独立 Camera2D，空格归位 + 鼠标贴边滚屏(MOBA式)
- **射击**：按住A瞄准→左键射击(点射/连射fire_timer)；LosBullet(Area2D)飞行+超距/撞击消失；instantiate动态生成加到Level
- **敌人+战斗循环**：LosEnemy追踪AI(找player组)+防贴脸(L_stopDistance)；alterHealth(正回负扣)→die；子弹撞enemy组→扣血→死亡。**核心战斗打通！**

### ⚠️⚠️ 重大坑记录（务必记住）
1. **碰撞层(collision_layer/mask)必须在 Godot Inspector 里设！** AI 在外部改 tscn 的碰撞层会被 Godot 重新保存覆盖。敌人 Layer=第3格(enemy)/Mask=第2格(Wall)
2. 多实例不设 position 会都在(0,0)重叠 → 曾造成"敌人贴脸甩不掉"假象
3. groups：玩家=["player"]，敌人=["enemy"]，用 is_in_group 识别
4. @export 值被 tscn 保存值覆盖，改脚本默认值不生效时去 Inspector 改
5. 命名统一 Los 前缀：LosPlayer/LosEnemy/LosBullet/LosHud/LosCamera/LosRouter/LosPlayerState/LosLevel

### ⏳ 真·下一步计划（覆盖上面旧列表）
1. **敌人血条**（受击显示，2秒无伤害自动隐藏，红色无数字）← 进行中
2. 敌人发子弹打玩家（联动 HUD 扣血）
3. 刷怪器（生成多个敌人）
4. 武器掉落 → 层间提升点选择
5. 主菜单 game.tscn + 场景切换
6. Lua 数据驱动（武器多了之后）
7. C++ GDExtension（性能瓶颈时）
8. 待美化：瞄准虚线、怪物图抠白底、UI Theme

### 🏗️ 关卡/敌人架构决策（2026-07-05，作者主动提出，重要！）
- **关卡管理器 LosLevel.gd**（挂 LosLevel.tscn 根节点=当前关卡总指挥，每关重建）
  vs **LosPlayerState 单例**（跨关卡持久数据：层数L_currentLevel/血量）—— 职责分离
- **一个 LosLevel.tscn 模板反复重载**，不做999个场景。每次 _ready 读 LosPlayerState.L_currentLevel 决定刷什么
- **清怪判定用"管理器持有敌人列表 L_enemies"**（不用全局组遍历，性能好、归属清晰、契合海量敌人目标）；
  组(enemy)仅保留用于子弹碰撞识别(is_in_group)。用 filter+is_instance_valid 清理已死敌人再计数
- **刷怪用数组 `@export var L_enemyScenes: Array[PackedScene]`**（不是每种怪一个变量！），pick_random 随机刷。
  加新怪=往数组拖，代码不动。终极形态=Lua敌人属性表+关卡刷怪表（种类多了再上）
- 刷怪数量现用简单公式（如 2+层数），将来抽到 Lua 数据
- 敌人 die() 里：remove_from_group("enemy") + LosRouter.ls_enemy_died.emit(get_instance_id(), L_currentLevel)
- **作者架构意识强**：已主动预判"关卡数据如何反映""敌人种类如何扩展"等扩展性问题

---

## 6.5 🎉 里程碑：Lua 数据驱动全链路打通（2026-07-06）

### ✅ 已完成：Lua → C++ → GDScript → 敌人 数据驱动全链路
1. **C++ GDExtension 编译链路跑通**（SCons + libdiana.dll），集成 Lua 5.4 源码到 `src/Lua/`
2. **LosLuaState 封装 lua_State**：doFile/doString/isTable/pop + 泛型 `getfieldWithPop<T>`（if constexpr 按类型分流 tonumber/tostring）
3. **LosLua.loadEnemy** 读 `game/data/enemies/enemy_1/enemy_1.lua`，组装成 `godot::Dictionary` 返回给 GDScript
4. **LosLua 注册为 C++ 引擎单例**（`Engine::register_singleton("LosLuaInstance", ...)`），全局一份 lua_State，不随关卡销毁
5. **LosEnemy_1.initConfig(config)** 被动接收配置（依赖注入），health/attack/speed 等被 Lua 覆盖
6. **LosLevel 批量刷怪 + L_enemyArray[] 管理**：_ready 读一次 config，for 循环 addEnemy 复用同一份（已做"读一次缓存复用"优化）
- ✅ **验证通过**：改 enemy_1.lua 的 speed，怪速度真变 → 数据驱动生效；改 lua 文本即可改怪行为，代码不动

### ⚠️⚠️ 本阶段踩过的坑（务必记住，以后必复现）
1. **GDExtension dll 被 Godot 锁定**：改 C++ 后编译，若 Godot 开着，dll 被占用写不进去（会残留 `~libdiana...dll`，或只剩 .lib/.exp 没 .dll）。铁律顺序：**关 Godot → 编译 → 开 Godot**。
2. **SCons 命令别加 compiledb 目标**：`python -m SCons compiledb=yes compiledb` 只生成 compile_commands.json，不编译 dll！要编译 dll 用 `python -m SCons compiledb=yes`（compiledb=yes 是参数，末尾的 compiledb 是目标）。
3. **C/C++ 混编 name mangling（LNK2019 unresolved external）**：C++ 里读 Lua 必须用 `lua.hpp`（内部 extern "C" 包了 lua.h），**绝不直接 include `lua.h`/`lauxlib.h`**，否则符号名被 C++ 修饰，链接找不到 Lua 的 C 符号。
4. **C++ register_singleton 的单例，编辑器自动补全不显示是假象**：补全里看不到 LosLuaInstance 不代表运行时不存在。用 `Engine.has_singleton()` / `Engine.get_singleton("LosLuaInstance")` 运行时验证才是真相。推荐 GDScript 里用 `Engine.get_singleton("LosLuaInstance")` 拿（补全不报红线）。
5. **单例名不要和类名相同**：类型名 LosLua（register_class）和单例名若都叫 "LosLua" 会冲突（GDScript 把它当类型 → "Cannot call non-static function"）。单例注册成不同名字（LosLuaInstance）。
6. **String UTF-8 乱码**：`godot::String(lua_tostring(...))` 按 Latin-1 解析导致中文乱码，必须用 `godot::String::utf8(lua_tostring(...))`（静态方法）。
7. **敌人 visible=false 隐身坑**：日志显示敌人生成成功、位置正确却看不见——检查节点 visible 是否被误设 false。逻辑正常但肉眼不可见时，先查 visible/z_index/位置。

### ⏳ 下一步计划（覆盖下方 §6 旧列表）
1. **台阶3**：加 enemy_2.lua，验证"加怪不改代码"（addEnemy 传不同 id 即可）
2. **台阶4**：关卡也用 Lua（level_1.lua 含 spawns 数组）——需先学 C++ 读 Lua 嵌套表/数组（lua_geti / 遍历），是新知识点
3. 后续：武器/Buff 词条也走 Lua 数据驱动；C++ 优化性能热点

---

## 7. 讲解「函数作用」的规范（作者 2026-07-06 明确要求，务必遵守）

> **背景**：作者在学习 Lua C API（如 `lua_getfield`）时，反复追问「为什么」。
> 作者要求：以后 AI 解释任何一个函数的作用时，**必须足够详细，必须让作者真正明白"为什么这样设计、为什么要这么用"**，不能只给一句"它的功能是 XXX"。

### 7.1 解释函数时必须包含的要素（缺一不可）
1. **一句话本质**：先用最直白的一句话说清它到底"做了什么"（可用作者熟悉的 C++ / Lua 概念类比）。
2. **函数签名**：写出参数列表和返回值，逐个参数说明含义。
3. **等价写法/心智模型**：给出它等价于什么更熟悉的写法（例如 `lua_getfield(L,-1,"health")` 等价于 Lua 的 `t["health"]`）。
4. **为什么这样设计（重点！）**：解释这个函数/机制为什么存在、为什么是这种形式，背后的设计动机（例如 Lua 用栈交换数据、负数索引不依赖栈长度所以方便）。
5. **执行前后的状态变化**：涉及栈/内存/状态的，必须画出「调用前 → 调用后」的变化（尤其 Lua 栈用 ASCII 图示）。
6. **配套动作**：说明它通常要和哪些函数搭配（例如 `lua_getfield` 后要 `lua_tonumber` 读值 + `lua_pop` 清栈）。
7. **坑 / 边界情况**：说明用错会怎样、边界情况如何处理（例如目标不是 table 时会取到 nil 或报错）。
8. **回到本项目**：结合 Diana 项目的真实文件和真实代码行说明该函数在这里怎么用（标注文件绝对路径）。

### 7.2 硬性要求
- **"为什么" 优先于 "是什么"**：作者要的是理解原理，不是背 API。每次解释都要回答"为什么这么设计/为什么要这么写"。
- **多用类比**：优先用作者已掌握的 C++（指针、栈、map、成员函数）和 Lua 概念做类比。
- **多用图示**：涉及栈、指针、数据流的，用 ASCII 图画出状态，不要只用文字描述。
- **循序渐进**：先给最朴素能懂的版本，再给更健壮/进阶的写法，不要一上来堆复杂封装。
- **不跳步**：不要假设作者已经懂中间环节，关键中间步骤要显式写出来。

---

## 8. 已讲解函数速查（学习沉淀，持续补充）

> 记录已经给作者详细讲过的函数，方便后续复习和保持一致口径。

### 8.1 `lua_getfield` —— 从 table 里按字符串 key 取字段

**一句话本质**：在 C++ 里，从 Lua 栈上指定位置的 table 中，取名为 `k` 的字段，并把该字段的**值压到栈顶**。等价于 Lua 的 `t["health"]` 或 `t.health`。

**函数签名**：
```c
void lua_getfield(lua_State *L, int index, const char *k);
```
- `L`：Lua 状态机（本项目里由 `LosLuaState` 持有，见 LosLusState.h 的 `lua_State *L_L`）。
- `index`：去栈的哪个位置取（通常是 table 所在位置，如 `-1` 表示栈顶）。
- `k`：要取的字段名（**只能是字符串 key**）。

**心智模型（等价写法）**：
```cpp
lua_getfield(L, -1, "health");   // 等价于 Lua: enemy_table["health"]
```

**为什么这样设计（重点）**：
- Lua 和 C 之间不能直接互相返回值，**只能通过一个"栈"来交换数据**。所以 `lua_getfield` 不直接把值 `return` 给 C++ 变量，而是把取到的值**压到栈顶**，再由 `lua_tonumber` / `lua_tostring` 从栈顶读走。
- 用 `-1`（栈顶）是因为负数索引"从栈顶往下数"，`-1` 永远指向"最后压进去的那个值"，**不依赖栈里到底有几个元素**，写 C 代码时最方便。

**执行前后的栈变化**（以本项目 enemy_1.lua 为例）：
```
调用前：
-1  [ enemy_table ]          ← doFile 后，Lua return 的 table 在栈顶

执行 lua_getfield(L, -1, "health");

调用后：
-1  [ 30 ]                   ← health 的值被压到新栈顶
-2  [ enemy_table ]          ← 原 table 被挤到第二位（-2）
```

**配套动作（三步节奏，缺一不可）**：
```cpp
lua_getfield(L, -1, "health");        // 1. 取字段，值压栈
double hp = lua_tonumber(L, -1);      // 2. 从栈顶读出值
lua_pop(L, 1);                        // 3. 弹掉该值，让 table 重新回到 -1
```
> 若不 `lua_pop`，下一次 `lua_getfield(L, -1, ...)` 的 `-1` 就不再是 table 而是上一个字段值，会取错。

**坑 / 边界情况**：
- `lua_getfield` **不检查** index 位置是不是 table。如果那里不是 table：
  - Lua 5.4 对普通 number/boolean 取字段会**直接报错**（`attempt to index a number value`）。
  - 就算不报错，也只会压一个 `nil`，`lua_tonumber` 读出来是 `0`，造成"脏数据 bug"。
- 因此取字段前**必须先判断类型**：
```cpp
if (!lua_istable(L, -1)) { lua_pop(L, 1); return result; }
```
- `lua_getfield` 只能取 **string key**。若是数组（number key）要用 `lua_geti(L, index, 1)`；动态 key 用 `lua_gettable`。
- 想避免连续取字段时栈乱，可先 `int idx = lua_absindex(L, -1);` 把 table 位置钉成正数，之后一直用 `idx`。

**回到本项目**：见 <D:\LosAngelous\Los\Diana\Diana\src\Diana\LosLua\LosLua.cpp> 的 `LosLua::loadEnemy`，读取 enemy_1.lua（<D:\LosAngelous\Los\Diana\Diana\game\data\enemies\enemy_1\enemy_1.lua>）的 `health/attack/speed` 等字段，组装成 `godot::Dictionary` 返回给 GDScript。

---

### 8.2 C++ GDExtension autoload 单例（正规做法，本项目选定方案）

**一句话本质**：让一个 C++ GDExtension 类（如 LosLua）在游戏启动时自动创建一个全局唯一实例，并注册进引擎的单例表，之后 GDScript 用全局名 `LosLua.xxx()` 直接访问——全程只有一个实例、一个 `lua_State`。

**为什么不用 .tscn 包一层（临时做法的问题）**：
- .tscn 包一层是"把一个 LosLua 节点塞进场景当 autoload"，属于折中方案；实例是"场景节点"，语义上仍是节点树的一部分。
- 作者选定**在 C++ 层直接声明单例**，语义更清晰（它就是引擎级基础设施，不是某个场景的节点），也不依赖手工维护的 .tscn，符合"正规做法 > 临时凑合"原则。

**核心 API**：
```cpp
#include "godot_cpp/classes/engine.hpp"
godot::Engine::get_singleton()->register_singleton("LosLua", instance);   // 注册
godot::Engine::get_singleton()->unregister_singleton("LosLua");           // 注销
```
- `register_singleton(name, ptr)`：把 `ptr` 指向的对象注册成名为 `name` 的全局单例，GDScript 里即可用 `name.xxx()` 访问。
- 单例实例需**自己 new 出来并持有指针**，在扩展卸载时 `unregister_singleton` + `memdelete` 释放。

**实现步骤（写在入口注册文件）**：
👉 <D:\LosAngelous\Los\Diana\Diana\src\Diana\LosEntrySymbol\LosEntrySymbol.cpp>

```cpp
#include "godot_cpp/classes/engine.hpp"
// ...

static LosDiana::LosLua *g_los_lua_singleton = nullptr;   // 持有单例指针

void LosEntrySymbolInit(godot::ModuleInitializationLevel p_level)
{
	if (p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
		return;

	godot::ClassDB::register_class<LosDiana::LosLua>();    // 1. 先注册类型

	g_los_lua_singleton = memnew(LosDiana::LosLua);        // 2. 创建唯一实例
	godot::Engine::get_singleton()->register_singleton("LosLua", g_los_lua_singleton); // 3. 注册为全局单例
}

void LosEntrySymbolUninit(godot::ModuleInitializationLevel p_level)
{
	if (p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
		return;

	if (g_los_lua_singleton != nullptr)                    // 4. 卸载时注销+释放
	{
		godot::Engine::get_singleton()->unregister_singleton("LosLua");
		memdelete(g_los_lua_singleton);
		g_los_lua_singleton = nullptr;
	}
}
```

**坑 / 注意（务必记住）**：
- **注册时机**：`register_singleton` 必须在类型已 `register_class` 之后，且在 `MODULE_INITIALIZATION_LEVEL_SCENE` 层做（此时引擎 Engine 单例可用）。
- **内存管理**：用 `memnew` / `memdelete`（Godot 内存宏），不要用裸 `new`/`delete`。init 里创建、uninit 里销毁，成对出现，否则内存泄漏或悬空。
- **名字唯一**：注册名 `"LosLua"` 不能和已有 autoload（LosRouter/LosPlayerState）或其他单例重名。
- **连带修改**：
  - Level 场景（LosLevel.tscn）里**删掉** LosLua 子节点（否则场景里又多一个实例，和单例重复）。
  - GDScript 里所有 `$LosLua.xxx` 改成 `LosLua.xxx`（全局名，不带 `$`），与 LosRouter/LosPlayerState 写法一致。
- **生命周期**：单例随扩展加载而生、随扩展卸载而灭，横跨所有场景/关卡，`lua_State` 全程唯一——这正是"Lua 环境不随关卡生生死死"的目标。

**验证**：任意脚本（LosLevel.gd / LosPlayer.gd）里 `LosLua.lLuaLoadEnemy("enemy_1")` 都能调通且共享同一状态机，即单例成功。

**回到本项目**：LosLua 类见 <D:\LosAngelous\Los\Diana\Diana\src\Diana\LosLua\LosLua.h>；注册入口见 <D:\LosAngelous\Los\Diana\Diana\src\Diana\LosEntrySymbol\LosEntrySymbol.cpp>；GDScript 调用点见 <D:\LosAngelous\Los\Diana\Diana\game\levels\LosLevel.gd>。

---

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

## 4. 目录结构

> **⚠️ 项目已迁移！当前根目录 = `D:\PR\Diana\Diana`（project.godot 所在层）。已建 git 仓库。**

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

## 7. 当前 player.gd 目标形态（参考）

```gdscript
extends CharacterBody2D

@export var L_speed: float = 200.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
        "move_down"
	)
	velocity = direction * L_speed
	move_and_slide()
```

---

_最后更新：2026-07-04 —— 阶段：玩家移动（进行中）_

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

> 注意：C++ 目前**暂不动手**。先用纯 GDScript 把游戏原型跑通。

---

## 4. 目录结构

### 4.1 当前实际结构（旧，待重构）
```
D:\LosAngelous\Los\Diana\Diana\
├── AGENTS.md
├── project.godot
├── icon.svg
├── scripts/             ← camera.gd, player.gd
├── scene/               ← level.tscn, player.tscn（注意：单数 scene）
├── src/                 ← C++ 源代码（空，未来 GDExtension）
├── content/             ← Lua 配置（待建）
└── assets/              ← 美术资源（待建）
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
- **明确分工（作者 2026-07-04 定）**：
  - **`.gd` 脚本代码 → 作者本人写**（AI 只讲原理、答疑、review，绝不代写脚本）
  - **`.tscn` 场景 / UI 配置 → AI 改**（节点结构、坐标、颜色、输入映射等配置性工作）
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

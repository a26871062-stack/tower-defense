# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Godot 4 塔防游戏，使用 GDScript 开发。玩家在地图上建造防御塔阻止敌人到达终点。

## 运行游戏

```bash
# 使用 Godot 4 打开项目
# 1. 下载 Godot 4.3+: https://godotengine.org/download/macos/
# 2. 启动 Godot，点击 Import，选择 project.godot
# 3. 按 F5 或点击 Play 运行
```

## ⚠️ tscn 文件编辑注意事项

**write 工具会把 `)` 错写成 `]`**，导致 Godot Parse Error。
写完 tscn 后必须检查：
```bash
grep 'ExtResource.*\]' scenes/main.tscn  # 应无结果
```
如果有，手动修复 `ExtResource("id_xxx")` 的括号。

## 架构概览

### 核心类

| 类 | 文件 | 职责 |
|----|------|------|
| `Game` | `scripts/Game.gd` | 主控制器：管理金币/生命/波次、塔建造、UI 更新 |
| `Tower` | `scripts/Tower.gd` | 塔基类：攻击逻辑、升级系统、范围绘制 |
| `Enemy` | `scripts/Enemy.gd` | 敌人：沿路径移动、受塔攻击、生命值管理、减速效果 |
| `EnemyManager` | `scripts/EnemyManager.gd` | 敌人工厂：根据波次生成不同类型敌人 |
| `LevelManager` | `scripts/LevelManager.gd` | 关卡配置：5 个关卡的路径点和经济参数 |
| `TowerUpgradeUI` | `scripts/TowerUpgradeUI.gd` | 塔升级面板：升级/出售按钮（文字内嵌） |
| `Bullet` | `scripts/Bullet.gd` | 子弹：三种视觉类型、溅射伤害、减速效果 |
| `SoundManager` | `audio/SoundManager.gd` | 音效管理（自动加载单例）：9个SFX |

### 重要信号

**Game.gd:**
- `wave_started(wave)` - 波次开始
- `wave_cleared` - 波次清空
- `level_cleared(level)` - 关卡完成
- `game_over` - 游戏结束

**Tower.gd:**
- `tower_selected(tower)` - 塔被选中
- `tower_deselected` - 塔取消选中
- `target_reached(area)` - 敌人进入攻击范围

**Enemy.gd:**
- `reached_end` - 敌人到达终点
- `died(enemy, reward)` - 敌人死亡

### UI 层级结构

```
UI (CanvasLayer)
├── TopBar (Panel) — 左上状态栏：金币/生命/波次/开始按钮
├── TopBarRight (Panel) — 右上速度控制：◀ 速度 ▶ 暂停
├── BuildPanel — 右侧建造面板
├── TowerUpgradeUI — 中央升级面板
└── MessageLabel — 浮动消息
```

### 子弹视觉差异

| 类型 | 颜色 | 形状 | 特效 |
|------|------|------|------|
| ARROW | 米黄色 | 细长箭头 | 飞行时旋转 |
| MAGIC | 蓝紫色 | 圆形法球 | 命中减速敌人 |
| CANNON | 橙色 | 较大圆形 | 溅射范围伤害+爆炸特效 |

### 塔系统

- 塔通过 Area2D 检测范围内的敌人
- 攻击冷却使用 `fire_rate`（次/秒）
- 升级后伤害 = `base_damage * 1.5^(level-1)`，最高 3 级
- 出售返还投资额的 50%

### 敌人系统

- 敌人沿预定义路径点移动
- 3 种敌人类型：Skeleton(高血量/慢)、Slime(低血量/慢)、Bat(低血量/快)
- 随波次增加，敌人数量和类型组合变化
- 被法师塔命中后变蓝紫色（减速效果）

### UI 交互注意事项

**TowerUpgradeUI** 使用 `accept_event()` 拦截点击事件，防止冒泡到 `Game._input` 导致塔被取消选择。

**修改 main.tscn 节点路径后**，必须同步更新 Game.gd 中对应的 `@onready var` 路径。

## 文件结构

```
tower-defense/
├── scenes/               # Godot 场景文件 (.tscn)
│   ├── main.tscn         # 主场景（UI + 路径）
│   ├── bullet.tscn       # 子弹场景
│   ├── death_effect.tscn # 死亡粒子特效
│   └── explosion.tscn    # 炮塔爆炸特效
├── scripts/              # GDScript 代码 (.gd)
├── audio/                 # 音效资源
│   └── SoundManager.gd   # 自动加载音效单例
├── assets/               # 图片和主题资源
└── project.godot         # Godot 项目配置
```

## 常见任务

### 添加新塔类型
1. 在 `scenes/` 创建新场景，继承 `Tower`
2. 在 `Game._setup_build_panel()` 注册新塔类型
3. 配置 `base_damage`、`attack_range`、`fire_rate`
4. 在 `Tower.gd` 的 `_create_projectile()` 添加子弹类型分支

### 添加新敌人类型
1. 在 `EnemyManager.EnemyType` 添加枚举值
2. 在 `ENEMY_SCENES` 和 `ENEMY_CONFIGS` 添加配置
3. 在 `get_enemy_type_for_wave()` 添加波次逻辑

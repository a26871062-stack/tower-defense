# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Godot 4 塔防游戏，使用 GDScript 开发。玩家在地图上建造防御塔阻止敌人到达终点。

## 运行游戏

```bash
# 使用 Godot 4 打开项目
# 1. 下载 Godot 4.3: https://godotengine.org/download/macos/
# 2. 启动 Godot，点击 Import，选择 project.godot
# 3. 按 F5 或点击 Play 运行
```

## 架构概览

### 核心类

| 类 | 文件 | 职责 |
|----|------|------|
| `Game` | `scripts/Game.gd` | 主控制器：管理金币/生命/波次、塔建造、UI 更新 |
| `Tower` | `scripts/Tower.gd` | 塔基类：攻击逻辑、升级系统、范围绘制 |
| `Enemy` | `scripts/Enemy.gd` | 敌人：沿路径移动、受塔攻击、生命值管理 |
| `EnemyManager` | `scripts/EnemyManager.gd` | 敌人工厂：根据波次生成不同类型敌人 |
| `LevelManager` | `scripts/LevelManager.gd` | 关卡配置：5 个关卡的路径点和经济参数 |
| `TowerUpgradeUI` | `scripts/TowerUpgradeUI.gd` | 塔升级面板：升级/出售按钮 |

### 场景继承关系

```
Tower (基类)
├── TowerArrow (箭塔)
├── TowerMage (法师塔)
└── TowerCannon (炮塔)

Enemy (基类)
├── EnemySkeleton
├── EnemySlime
└── EnemyBat
```

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

### 塔系统

- 塔通过 Area2D 检测范围内的敌人
- 攻击冷却使用 `fire_rate`（次/秒）
- 升级后伤害 = `base_damage * 1.5^(level-1)`，最高 3 级
- 出售返还投资额的 50%

### 敌人系统

- 敌人沿预定义路径点移动
- 3 种敌人类型：Skeleton(高血量/慢)、Slime(低血量/慢)、Bat(低血量/快)
- 随波次增加，敌人数量和类型组合变化

### UI 交互注意事项

**TowerUpgradeUI** 使用 `accept_event()` 拦截点击事件，防止冒泡到 `Game._input` 导致塔被取消选择。

## 文件结构

```
scenes/          # Godot 场景文件 (.tscn)
scripts/         # GDScript 代码 (.gd)
assets/          # 图片和主题资源
project.godot    # Godot 项目配置
```

## 常见任务

### 添加新塔类型
1. 在 `scenes/` 创建新场景，继承 `Tower`
2. 在 `Game._setup_build_panel()` 注册新塔类型
3. 配置 `base_damage`、`attack_range`、`fire_rate`

### 添加新敌人类型
1. 在 `EnemyManager.EnemyType` 添加枚举值
2. 在 `ENEMY_SCENES` 和 `ENEMY_CONFIGS` 添加配置
3. 在 `get_enemy_type_for_wave()` 添加波次逻辑

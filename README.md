# 🗼 Tower Defense - 塔防游戏

经典固定路线塔防游戏，基于 Godot 4 开发。

## 如何运行

### 1. 下载 Godot 4
- 官网: https://godotengine.org/download/macos/
- 下载 `Godot_v4.3+`
- 解压后双击 `Godot.app`（不需要安装）

### 2. 打开项目
1. 启动 Godot 4
2. 点击 "Import"
3. 选择这个文件夹: `~/workspace/tower-defense/project.godot`
4. 点击 "Import & Edit"

### 3. 运行游戏
- 按 `F5` 或点击 ▶️ 运行
- 或者点击 "Play" 按钮

## 游戏操作

| 操作 | 说明 |
|------|------|
| 点击右侧面板塔图标 | 选择要建造的塔 |
| 点击地图 | 放置塔（消耗金币） |
| 右键 / ESC | 取消放置 |
| 点击"开始波次" | 启动下一波敌人 |
| P / 暂停按钮 | 暂停/继续游戏 |
| +/- / ◀▶ 按钮 | 调整游戏速度 0.5x~3.0x |

## 塔的类型

| 塔 | 费用 | 伤害 | 攻击速度 | 范围 | 特效 |
|----|------|------|---------|------|------|
| 箭塔 | 50 | 20 | 1.0/s | 150 | 细长米黄色子弹，飞行时旋转 |
| 法师塔 | 80 | 35 | 0.8/s | 130 | 蓝紫色法球，命中减速敌人 |
| 炮塔 | 120 | 60 | 0.5/s | 120 | 橙色炮弹，溅射范围伤害+爆炸特效 |

## 开发进度

- [x] 项目框架搭建
- [x] 核心游戏循环
- [x] 敌人路径系统（5个关卡）
- [x] 塔建造系统
- [x] 塔攻击系统（三种差异化塔）
- [x] 子弹/特效系统（视觉差异+爆炸特效）
- [x] 塔升级系统（3级升级，UI完善）
- [x] 音效系统（SoundManager + 9个SFX）
- [x] 死亡特效（粒子扩散）
- [x] 暂停/加速功能（P键/+/-键/按钮）
- [x] 法师塔减速视觉反馈
- [ ] 存档系统（计划中）
- [ ] 背景音乐（计划中）
- [ ] iOS/Android 打包（计划中）

## 目录结构

```
tower-defense/
├── project.godot          # Godot 项目配置
├── scenes/               # 场景文件
│   ├── main.tscn         # 主场景（UI + 路径）
│   ├── enemy.tscn        # 敌人
│   ├── tower_*.tscn     # 各类型塔
│   ├── bullet.tscn       # 子弹
│   ├── build_panel.tscn  # 建造面板
│   ├── death_effect.tscn # 死亡特效
│   └── explosion.tscn    # 炮塔爆炸特效
├── scripts/              # GDScript 代码
│   ├── Game.gd           # 游戏主控制器
│   ├── Enemy.gd          # 敌人逻辑
│   ├── Tower.gd          # 塔逻辑（基类）
│   ├── Bullet.gd         # 子弹逻辑
│   ├── TowerUpgradeUI.gd  # 塔升级面板
│   ├── BuildPanel.gd     # 建造面板
│   ├── EnemyManager.gd   # 敌人工厂/波次
│   ├── LevelManager.gd   # 关卡配置（5关）
│   ├── PathVisualizer.gd # 路径可视化
│   ├── SoundManager.gd   # 音效管理（自动加载）
│   ├── TowerConfig.gd    # 塔配置数据
│   └── DeathEffect.gd    # 死亡粒子特效
├── audio/                # 音频资源
│   └── *.wav            # 9个音效文件
└── assets/              # 视觉素材
```

## 素材来源

建议使用以下免费素材：
- https://kenney.nl/assets (CC0 免费)
- https://opengameart.org
- AI 生成 (MiniMax / DALL-E)

## Agent 配合

如需 AI 辅助开发：
1. 把代码文件发给 AI
2. 描述你想要的功能
3. AI 会生成代码片段或修改建议

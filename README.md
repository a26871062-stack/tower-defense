# 🗼 Tower Defense - 塔防游戏

经典固定路线塔防游戏，基于 Godot 4 开发。

## 如何运行

### 1. 下载 Godot 4
- 官网: https://godotengine.org/download/macos/
- 下载 `Godot_v4.3-stable_macos.universal.zip`
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
| 点击 "开始波次" | 启动下一波敌人 |

## 塔的类型

| 塔 | 费用 | 伤害 | 攻击速度 | 范围 |
|----|------|------|---------|------|
| 箭塔 | 50 | 20 | 1.0/s | 150 |
| 法师塔 | 80 | 35 | 0.8/s | 130 |
| 炮塔 | 120 | 60 | 0.5/s | 120 |

## 开发进度

- [x] 项目框架搭建
- [x] 核心游戏循环
- [x] 敌人路径系统
- [x] 塔建造系统
- [x] 塔攻击系统（基础版）
- [ ] 子弹/特效系统
- [ ] 塔升级系统
- [ ] 5个关卡地图
- [ ] 音效和背景音乐
- [ ] UI 美化
- [ ] iOS/Android 打包

## 目录结构

```
tower-defense/
├── project.godot        # Godot 项目配置
├── scenes/               # 场景文件
│   ├── main.tscn         # 主场景
│   ├── enemy.tscn        # 敌人
│   ├── tower*.tscn       # 各类型塔
│   ├── bullet.tscn       # 子弹
│   └── build_panel.tscn  # 建造面板
├── scripts/              # GDScript 代码
│   ├── Game.gd           # 游戏主控制器
│   ├── Enemy.gd          # 敌人逻辑
│   ├── Tower.gd          # 塔逻辑（基类）
│   └── Bullet.gd         # 子弹逻辑
└── assets/               # 素材（需替换占位符）
    └── *.png             # 临时占位图
```

## 素材来源

建议使用以下免费素材：
- https://kenney.nl/assets (CC0 免费)
- https://opengameart.org
- AI 生成 (Midjourney / DALL-E)

## Agent 配合

如需 AI 辅助开发：
1. 把代码文件发给 AI
2. 描述你想要的功能
3. AI 会生成代码片段或修改建议

#!/usr/bin/env python3
"""
纯 Python 音效生成器 - 无需外部依赖
使用 wave 模块生成 WAV，再转 OGG (可选)

运行: python generate_sfx.py
"""

import os
import struct
import math
import wave
import subprocess

OUTPUT_DIR = "audio/sfx"
SAMPLE_RATE = 22050


def write_wav(filename: str, samples: list):
    """写入 WAV 文件"""
    filepath = os.path.join(OUTPUT_DIR, filename)
    with wave.open(filepath, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        for s in samples:
            s = max(-1.0, min(1.0, s))
            w.writeframes(struct.pack('<h', int(s * 32767)))
    return filepath


def sine(freq: float, duration: float, volume: float = 0.5, fade_in: float = 0.01, fade_out: float = 0.05) -> list:
    """生成正弦波"""
    samples = []
    n = int(SAMPLE_RATE * duration)
    for i in range(n):
        t = i / SAMPLE_RATE
        val = math.sin(2 * math.pi * freq * t) * volume
        # Fade in
        if t < fade_in:
            val *= t / fade_in
        # Fade out
        if t > duration - fade_out:
            val *= (duration - t) / fade_out
        samples.append(val)
    return samples


def noise(duration: float, volume: float = 0.3) -> list:
    """生成白噪声"""
    import random
    n = int(SAMPLE_RATE * duration)
    return [random.uniform(-1, 1) * volume for _ in range(n)]


def mix(*audios):
    """混合多个音频"""
    max_len = max(len(a) for a in audios)
    result = []
    for i in range(max_len):
        val = sum(a[i] if i < len(a) else 0 for a in audios)
        result.append(val / len(audios))
    return result


def truncate(a: list, duration: float):
    """截断到指定时长"""
    n = int(SAMPLE_RATE * duration)
    return a[:n]


# ============ 音效生成函数 ============

def gen_arrow_attack():
    """短促嗖声"""
    return sine(880, 0.06, 0.4, 0.005, 0.02)


def gen_mage_attack():
    """魔法嗡鸣 - 低频谐波"""
    h1 = sine(220, 0.12, 0.35, 0.01, 0.05)
    h2 = sine(330, 0.10, 0.25, 0.01, 0.04)
    h3 = sine(440, 0.08, 0.18, 0.01, 0.03)
    return mix(h1, h2, h3)


def gen_cannon_attack():
    """沉闷炮轰"""
    boom = sine(60, 0.15, 0.6, 0.005, 0.1)
    n = noise(0.08, 0.25)
    return mix(boom, n)


def gen_enemy_death():
    """尖叫消失 - 下降频率"""
    s1 = sine(800, 0.15, 0.5, 0.005, 0.1)
    s2 = sine(400, 0.12, 0.4, 0.01, 0.08)
    s3 = sine(200, 0.10, 0.3, 0.01, 0.06)
    return mix(s1, s2, s3)


def gen_coin():
    """金币叮当"""
    c1 = sine(987, 0.08, 0.5, 0.003, 0.05)
    c2 = sine(1319, 0.12, 0.4, 0.002, 0.08)
    return mix(c1, c2)


def gen_upgrade():
    """升级音阶 - G4 B4 D5 G5"""
    notes = [392, 523, 659, 784]
    durations = [0.08, 0.08, 0.08, 0.15]
    result = []
    for freq, dur in zip(notes, durations):
        result.extend(sine(freq, dur, 0.4, 0.005, dur * 0.4))
    return result


def gen_sell():
    """硬币掉落"""
    s1 = sine(1800, 0.03, 0.3, 0.002, 0.025)
    s2 = sine(2400, 0.025, 0.2, 0.002, 0.02)
    s3 = sine(600, 0.08, 0.35, 0.005, 0.03)
    return mix(s1, s2, s3)


def gen_wave_start():
    """号角 - 上升 sweep"""
    h1 = sine(200, 0.35, 0.4, 0.02, 0.05)
    h2 = sine(300, 0.30, 0.35, 0.03, 0.05)
    h3 = sine(400, 0.25, 0.30, 0.04, 0.05)
    return mix(h1, h2, h3)


def gen_game_over():
    """游戏结束 - 下降 doom"""
    s1 = sine(200, 0.50, 0.5, 0.02, 0.2)
    s2 = sine(150, 0.45, 0.4, 0.02, 0.2)
    s3 = sine(80, 0.40, 0.3, 0.02, 0.25)
    return mix(s1, s2, s3)


SFX_FUNCS = {
    "arrow_attack": (gen_arrow_attack, "短促嗖声 - 高频burst"),
    "mage_attack": (gen_mage_attack, "魔法嗡鸣 - 低频谐波"),
    "cannon_attack": (gen_cannon_attack, "沉闷炮轰 - 低频+噪声"),
    "enemy_death": (gen_enemy_death, "尖叫消失 - 下降频率"),
    "coin": (gen_coin, "金币叮当 - 高频清脆"),
    "upgrade": (gen_upgrade, "升级音阶 - 上升arpeggio"),
    "sell": (gen_sell, "硬币掉落 - 金属声"),
    "wave_start": (gen_wave_start, "号角 - 上升sweep"),
    "game_over": (gen_game_over, "游戏结束 - 下降doom"),
}


def convert_to_ogg(wav_path: str) -> bool:
    """尝试转换为 OGG (需要 ffmpeg)"""
    ogg_path = wav_path.replace('.wav', '.ogg')
    try:
        result = subprocess.run(
            ['ffmpeg', '-y', '-i', wav_path, '-acodec', 'libvorbis', '-q:a', '4', ogg_path],
            capture_output=True, timeout=10
        )
        if result.returncode == 0:
            os.remove(wav_path)
            return True
    except:
        pass
    return False


def main():
    print("音效生成器 - Dungeon Crawler 像素风格 (纯 Python)\n")

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    ffmpeg_available = subprocess.run(['which', 'ffmpeg'], capture_output=True).returncode == 0

    for name, (gen_func, desc) in SFX_FUNCS.items():
        print(f"  生成 {name}: {desc}")
        try:
            samples = gen_func()
            wav_path = write_wav(f"{name}.wav", samples)
            size = os.path.getsize(wav_path)
            print(f"    -> {wav_path} ({size} bytes)")

            if ffmpeg_available:
                if convert_to_ogg(wav_path):
                    ogg_path = wav_path.replace('.wav', '.ogg')
                    ogg_size = os.path.getsize(ogg_path)
                    print(f"    -> 转换为 OGG: {ogg_path} ({ogg_size} bytes)")
                else:
                    print(f"    ! OGG 转换失败，保留 WAV")
            else:
                print(f"    ! ffmpeg 未安装，保留 WAV 格式 (Godot 也支持)")

        except Exception as e:
            print(f"    ! 错误: {e}")

    ext = "ogg" if ffmpeg_available else "wav"
    print(f"\n完成! 生成了 {len(SFX_FUNCS)} 个音效文件到 {OUTPUT_DIR}/")

    if not ffmpeg_available:
        print("提示: 安装 ffmpeg 后重新运行可转换为 OGG 格式")
        print("      brew install ffmpeg")


if __name__ == "__main__":
    main()

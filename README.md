# MidoMaul

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-cyan)
![Lua](https://img.shields.io/badge/language-Luau-blue)
![Platform](https://img.shields.io/badge/platform-Roblox-red)
![License](https://img.shields.io/badge/license-MIT-green)

**Futuristic. Fluid. Mobile-First.**
<br/>
A next-generation material control surface for Roblox developers.

</div>

## 🌌 Philosophy
MidoMaul is built on the idea that power should feel effortless. It abandons rigid borders for "glass-morphic" surfaces, magnetic haptics, and intelligent scaling. It is designed to feel less like a GUI and more like a physical interface.

## ✨ Features
- **Mobile-First Architecture:** Auto-detects device type and scales UI (1.1x on mobile) for perfect touch targets.
- **Magnetic Haptics:** Buttons pulse and ripple; sliders glow with intensity.
- **Holo-Glow Depth:** Uses layered transparency and shadow sprites instead of borders.
- **TweenService Integration:** deeply integrated smooth motion for every interaction.
- **Single Module:** No complex loader scripts. One module, zero dependencies.

## 📦 Installation

1. Download `src/MidoMaul.lua`.
2. Drag it into `ReplicatedStorage` (or your preferred storage).
3. Require it in a `LocalScript`.

## 🚀 Usage

```lua
local MidoMaul = require(game.ReplicatedStorage.MidoMaul)

local Window = MidoMaul:Window({
    Title = "Cyber Interface"
})

local Tab = Window:Tab("Main")

Tab:Button("Initiate Protocol", function()
    print("Protocol started")
end)

Tab:Slider("Intensity", 0, 100, 50, function(value)
    print(value)
end)
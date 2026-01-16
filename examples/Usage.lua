local MidoMaul = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaulK/MidoMaul-UI/refs/heads/main/src/MidoMaul.lua)"))()

-- Create the Window
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
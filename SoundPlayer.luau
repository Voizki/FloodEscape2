local SoundTable = {}
task.spawn(function()
    while true do
        local NewTable = {}
        for i,v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Sound") then
                table.insert(NewTable,v)
            end
        end
        SoundTable = NewTable
        task.wait(1)
    end
end)
while true do
    for i=1,#SoundTable do
        SoundTable[i]:Play()
    end
    task.wait(0.05*#SoundTable/100)
end

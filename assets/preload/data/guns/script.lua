function onCreatePost()

    --name, modifier class, type (defaults to all), playfield number (-1 = all)
                            --other types:
                            -- player
                            -- opponent
                            -- lane  (needs to have its target lane set)
    startMod('drunkPF0', 'DrunkXModifier', '', 0) --playfield 0 = default playfield
    addPlayfield(0,0,0)
    startMod('zPF1', 'ZModifier', '', 1)
    startMod('tipsyPF1', 'TipsyYModifier', '', 1)

    for i = 0,3 do 
        local beat = i*8

        --start time, ease time, ease, modifier data (value, name)
        ease(beat, 1, 'expoOut', [[
            1.5, drunkPF0,
            4, drunkPF0:speed
        ]])

        --one section after
        ease((beat)+4, 1, 'expoOut', [[
            -1.5, drunkPF0
        ]])
    end


    startMod('drunkPF0', 'DrunkXModifier', '', 0) --playfield 0 = default playfield

    startMod('zPF1', 'ZModifier', '', 1)
    startMod('tipsyPF1', 'TipsyYModifier', '', 1)

    ease(32, 4, 'cubeInOut', [[
        -300, zPF1,
        1, tipsyPF1,
        2, tipsyPF1:speed
    ]]) --puting ":" makes it ease a submod, in this case its changing the speed


    for i = 4,7 do 
        local beat = i*8

        --start time, ease time, ease, modifier data (value, name)
        ease(beat, 1, 'expoOut', [[
            1.5, drunkPF0,
            4, drunkPF0:speed
        ]])

        --one section after
        ease((beat)+4, 1, 'expoOut', [[
            -1.5, drunkPF0
        ]])
    end


    startMod('customModTest', 'Modifier', '', -1)

    --you might get an error if you have luaDebugMode enabled, just ignore them lol it should still work
    runHaxeCode([[

        //move notes and strums back a little
        game.playfieldRenderer.modifiers.get("customModTest").noteMath = function(noteData, lane, curPos, pf)
        {
            noteData.z += game.playfieldRenderer.modifiers.get("customModTest").currentValue * -500;
        }
        game.playfieldRenderer.modifiers.get("customModTest").strumMath = function(noteData, lane, pf)
        {
            noteData.z += game.playfieldRenderer.modifiers.get("customModTest").currentValue * -500;
        }

        //do crazy incoming angles
        game.playfieldRenderer.modifiers.get("customModTest").incomingAngleMath = function(lane, curPos, pf)
        {
            var xAngle = 45*lane + curPos/30;
            var yAngle = 90*lane + curPos/7;
            var value = game.playfieldRenderer.modifiers.get("customModTest").currentValue;
            return [xAngle*value, yAngle*value];
        }
    ]])

    ease(64, 1, 'cubeInOut', [[
        0, zPF1,
        0, tipsyPF1,
        0, drunkPF0,
        1, customModTest
    ]])
end

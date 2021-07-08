function love.conf(t)
    t.identity = 'qfx_vm'                    -- The name of the save directory (string)
    t.version = "11.3"                  -- The LÖVE version this game was made for (string)

    t.window.title = "Qfx's fantastic fantasy VM"         -- The window title (string)

    t.modules.audio = false              -- Enable the audio module (boolean)
    t.modules.joystick = false           -- Enable the joystick module (boolean)
    t.modules.physics = false            -- Enable the physics module (boolean)
    t.modules.sound = false              -- Enable the sound module (boolean)
    t.modules.thread = false             -- Enable the thread module (boolean)
    t.modules.touch = false              -- Enable the touch module (boolean)
    t.modules.video = false              -- Enable the video module (boolean)
end
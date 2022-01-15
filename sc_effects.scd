/*
 * Delay
 */
(
SynthDef(\PPDelay,
    {
        arg
        out = 0,
        fx_bus = -1,
        feedback,
        dtime;

        var
        input = In.ar(fx_bus);

        // Out.ar(out, input ! 2);
        b = Buffer.alloc(s, 44100 , 2);
        Out.ar
        (
            out,
            PingPong.ar
            (
                b.bufnum,
                input ! 2,
                dtime,
                feedback,
                1
            )
        )
    }
).add();
)

/*
 * Reverb
 */
(
SynthDef(\Reverb,
    {
        arg
        out    = 0,
        fx_bus = -1,
        mix    = 0.33,
        room   = 0.5,
        damp   = 0.5;

        var
        input = In.ar(fx_bus);

        Out.ar
        (
            out,
            FreeVerb.ar
            (
                input ! 2,
                mix,
                room,
                damp
            )
        )
    }
).add();
)
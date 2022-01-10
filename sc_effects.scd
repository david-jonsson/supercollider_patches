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
/*
 *  Pad
 */
(
SynthDef(\Paddd,
    {
        arg
        out = 0,
        fx_bus = -1,
        midinote,
        reltime = 2,
        filter_cutoff = 3000,
        filter_slope = -30;

        var
        amp_env,
        filter_env,
        signal;

        amp_env = EnvGen.kr
        (
            Env
            (
                [1 / 3, 0],
                [reltime],
                \lin
            ),
            doneAction: Done.freeSelf
        );

        signal = SawDPW.ar
        (
            freq: midinote.midicps,
            mul: amp_env
        ) + SawDPW.ar
        (
            freq: (midinote + 3).midicps,
            mul: amp_env
        ) + SawDPW.ar
        (
            freq: (midinote - 5).midicps,
            mul: amp_env
        );

        /*
         * Filter
         */
        filter_env = EnvGen.kr
        (
            Env
            (
                [filter_cutoff, 0],
                [reltime],
                filter_slope
            ),
            doneAction: Done.freeSelf
        );
        signal = BLowPass.ar
        (
            in: signal,
            freq: filter_env
        );
        Out.ar(fx_bus, signal);
        Out.ar(out, signal ! 2);
    }
).add().play;
)



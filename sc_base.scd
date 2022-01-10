/*
 *  Basey thingie
 */
(
SynthDef(\Base,
    {
        arg
        out = 0,
        midinote = 30,
        amp = 1,
        att_time = 0.01,
        rel_time = 0.200,
        amp_slope = 1,
        harm_amps = #[1, 1, 1, 1, 1],
        filter_pitch_start = 50,
        filter_pitch_end = 20,
        filter_pitch_slope = \linear,
        filter_moddepth = 1,
        filter_rq = 1,
        snap = 0.5;


        var
        amp_env,
        filter_env,
        oscillators = Array.newClear(indexedSize: 5),
        signal = 0,
        noise;


        /*
         * Additive part
         */
        amp_env = EnvGen.kr
        (
            Env
            (
                [0, 1, 0],
                [att_time, rel_time],
                amp_slope
            ),
            doneAction: Done.freeSelf
        );
        5.do
        ({
            arg i;
            oscillators[i] = SinOsc.ar
            (
                freq: (midinote.midicps) * ((i + 1) * 1.0),
                // phase: 0,
                mul: amp_env * harm_amps[i]
            );
            signal = signal + oscillators[i];
        });
        signal = signal / 5;

        /*
         * Filter
         */
        filter_env = EnvGen.kr
        (
            Env
            (
                [filter_pitch_start, filter_pitch_end],
                [rel_time + att_time],
                filter_pitch_slope
            ),
            doneAction: Done.freeSelf
        );
/*        signal = BLowPass.ar
        (
            in: signal,
            freq: filter_env * filter_moddepth,
            rq: filter_rq
        );*/
        signal = signal * amp;
        Out.ar(out, signal ! 2);
    }
).add();
)
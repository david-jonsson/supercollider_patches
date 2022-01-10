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
        triangle_amp_slope = 1,
        triangles_pitch_offsets = #[0, 3, 7, 10, 12],
        noise_amp_slope = 1,
        filter_pitch_start = 50,
        filter_pitch_end = 20,
        filter_pitch_slope = \linear,
        filter_moddepth = 1,
        filter_rq = 1,
        snap = 0.5;


        var
        noise_amp_env,
        triangle_amp_env,
        filter_env,
        triangles = Array.newClear(indexedSize: 5),
        signal,
        triangle = 0,
        noise;

        /*
         * Noise
         */
        noise_amp_env   = EnvGen.kr
        (
            Env
            (
                [1, 0],
                [rel_time],
                noise_amp_slope
            ),
            doneAction: Done.freeSelf
        );

        noise = BrownNoise.ar() * noise_amp_env;


        /*
         * Triangle
         */
        triangle_amp_env = EnvGen.kr
        (
            Env
            (
                [1, 0],
                [rel_time],
                triangle_amp_slope
            ),
            doneAction: Done.freeSelf
        );
        5.do
        ({
            arg i;
            triangles[i] = LFTri.ar
            (
                freq: (midinote + triangles_pitch_offsets[i]).midicps,
                iphase: 0,
                mul: triangle_amp_env * 1/5
            );
            triangle = triangle + triangles[i];

        });
        signal = triangle + (noise * snap);

        /*
         * Filter
         */
        filter_env = EnvGen.kr
        (
            Env
            (
                [filter_pitch_start, filter_pitch_end],
                [rel_time],
                filter_pitch_slope
            ),
            doneAction: Done.freeSelf
        );
        signal = BLowPass.ar
        (
            in: signal,
            freq: filter_env * filter_moddepth,
            rq: filter_rq
        );
        signal = signal * amp;
        Out.ar(out, signal ! 2);
    }
).add();
)
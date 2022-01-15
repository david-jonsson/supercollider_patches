
/*
 *  Kick
 */
(
SynthDef(\Kick,
    {
        arg
        out = 0,
        amp = 1,
        att_time = 0.01,
        rel_time = 0.200,
        pitch_start = 200,
        pitch_end = 100,
        pitch_slope = -4,
        filter_moddepth = 1,
        filter_rq = 1;

        var
        amp_env,
        pitch_env,
        signal;

        amp_env = EnvGen.kr(Env.perc(att_time, rel_time));
        pitch_env = EnvGen.kr
        (
            Env([pitch_start, pitch_end], [rel_time], pitch_slope),
            doneAction: Done.freeSelf
        );

        signal = SinOsc.ar
        (
            freq: pitch_env,
            iphase: 0,
            mul: amp_env * 0.5
        );

        signal = signal + LFTri.ar
        (
            freq: pitch_env,
            iphase: 0,
            mul: amp_env  * 0.5
        );
        signal = BLowPass.ar
        (
            in: signal,
            freq: pitch_env * filter_moddepth,
            rq: filter_rq
        );
        signal = signal * amp;
        Out.ar(out, signal ! 2);
    }
).add();


/*
 *  Snare
 */
SynthDef(\Snare,
    {
        arg
        out = 0,
        amp = 1,
        att_time = 0.01,
        rel_time = 0.200,
        triangle_pitch_start = 300,
        triangle_pitch_end = 160,
        triangle_pitch_slope = \linear,
        filter_pitch_start = 300,
        filter_pitch_end = 160,
        filter_pitch_slope = \linear,
        filter_moddepth = 1,
        filter_rq = 1,
        noise_pitch_start = 300,
        noise_pitch_end = 160,
        noise_pitch_slope = -6,
        snap = 0.5;

        var
        filter_pitch_env,
        triangle_amp_env,
        triangle_pitch_env,
        noise_amp_env,
        noise_pitch_env,
        signal,
        noise,
        triangle;

        /*
         * Noise
         */
        noise_amp_env   = EnvGen.kr(Env
            (
                [1, 0, 0.5, 0],
                [0.01, 0.05, 0.15],
                [\lin, -3, \lin],
            )
        );
        noise = BrownNoise.ar() * noise_amp_env * snap;


        /*
         * Triangle
         */
        triangle_amp_env   = EnvGen.kr(Env.perc(att_time, rel_time));
        triangle_pitch_env = EnvGen.kr
        (
            Env
            (
                [triangle_pitch_start, triangle_pitch_end,triangle_pitch_end],
                [rel_time / 2 , rel_time],
                triangle_pitch_slope
            ),
            doneAction: Done.freeSelf
        );
        triangle = LFTri.ar
        (
            freq: triangle_pitch_env,
            iphase: 0,
            mul: triangle_amp_env * 1
        );
        signal = triangle + noise;

        /*
         * Filter
         */
        filter_pitch_env = EnvGen.kr
        (
            Env
            (
                [filter_pitch_start, filter_pitch_end, filter_pitch_end],
                [rel_time / 2 , rel_time],
                filter_pitch_slope
            ),
            doneAction: Done.freeSelf
        );
        signal = BLowPass.ar
        (
            in: signal,
            freq: filter_pitch_env * filter_moddepth,
            rq: filter_rq
        );
        signal = signal * amp;
        Out.ar(out, signal ! 2);
    }
).add();


/*
 *  FMToms
 */
SynthDef(\TomsFM,
    {
        arg
        out = 0,
        amp = 1,
        midinote,
        att_times =    #[0.01, 0.01, 0.01, 0.01, 0.01],
        rel_times =    #[0.20, 0.20, 0.20, 0.20, 0.20],
        amp_slopes =   #[\lin, \lin, \lin, \lin],
        pitch_starts = #[100, 100, 100, 100, 100],
        pitch_ends =   #[100, 100, 100, 100, 100],
        pitch_slopes = #[\lin, \lin, \lin, \lin, \lin],
        fm_moddepths = #[200, 100],
        filter_moddepth = 1,
        filter_rq = 1,
        snap = 0.5;

        var
        amp_envs = Array.newClear(indexedSize: 5),
        pitch_envs = Array.newClear(indexedSize: 5),
        signal,
        noise,
        carrier,
        mod1,
        mod2;

        /*
         *  d
         *  c
         * ab <- carriers
         *
         *  a : noisemaxSize
         *  b : sawtooth -3db
         *  c : sawtooth -6db
         *  d : sawtooth  8db
         */
        /*
         * Noise
         */
        amp_envs[0] = EnvGen.kr(Env.perc(att_times[0], rel_times[0]));
        noise = WhiteNoise.ar() * amp_envs[0] * snap;


        /*
         * Mod 2
         */
        amp_envs[3] = EnvGen.kr(Env.perc(att_times[3], rel_times[3]));
        pitch_envs[3] = EnvGen.kr
        (
            Env
            (
                [pitch_starts[3], pitch_ends[3]],
                [rel_times[3]],
                pitch_slopes[3]
            ),
            doneAction: Done.freeSelf
        );
        mod2 = SawDPW.ar
        (
            freq: pitch_envs[3],
            mul: amp_envs[3] * fm_moddepths[1]
        );

        /*
         * Mod 1
         */
        amp_envs[2] = EnvGen.kr(Env.perc(att_times[2], rel_times[2]));
        pitch_envs[2] = EnvGen.kr
        (
            Env
            (
                [pitch_starts[2], pitch_ends[2]],
                [rel_times[2]],
                pitch_slopes[2]
            ),
            doneAction: Done.freeSelf
        );
        mod1 = SawDPW.ar
        (
            freq: pitch_envs[2] + (mod2 * fm_moddepths[1]),
            mul: amp_envs[2] * fm_moddepths[0]
        );

        /*
         * Carrier
         */
        amp_envs[1] = EnvGen.kr(Env.perc(att_times[1], rel_times[1]));
        pitch_envs[1] = EnvGen.kr
        (
            Env
            (
                [pitch_starts[1], pitch_ends[1]],
                [rel_times[1]],
                pitch_slopes[1]
            ),
            doneAction: Done.freeSelf
        );
        carrier = SawDPW.ar
        (
            freq: pitch_envs[1] + mod1 - 50 + (10 * midinote),
            mul: amp_envs[1]
        );
        signal = carrier + noise;

        pitch_envs[4] = EnvGen.kr
        (
            Env
            (
                [pitch_starts[4], pitch_ends[4]],
                [rel_times[4]],
                pitch_slopes[4]
            ),
            doneAction: Done.freeSelf
        );
        signal = BLowPass.ar
        (
            in: signal,
            freq: pitch_envs[4] * filter_moddepth,
            rq: filter_rq
        );
        signal = signal * amp;
        Out.ar(out, signal ! 2);
    }
).add();


/*
 *  Toms
 */
SynthDef(\Toms909,
    {
        arg
        out = 0,
        amp = 1,
        midinote,
        amps         = #[0.5, 0,5],
        att_times =    #[0.01, 0.01, 0.01, 0.01, 0.01],
        rel_times =    #[0.20, 0.20, 0.20, 0.20, 0.20],
        pitch_starts = #[200, 300, 100, 100, 100],
        pitch_ends =   #[100, 100, 100, 100, 100],
        pitch_slopes = #[\lin, \lin, \lin, \lin, \lin],
        filter_moddepth = 1,
        filter_rq = 1,
        snap = 0.5,
        release;

        var
        sine_amp_envs = Array.newClear(indexedSize: 3),
        pulse_amp_envs = Array.newClear(indexedSize: 3),
        noise_amp_env,
        signal_amp_env,
        morph_env,
        signal = 0,
        noise = 0,
        pitch_envs = Array.newClear(indexedSize: 5),
        oscillators = Array.newClear(indexedSize: 5);


        /*
         * Noise
         */
        noise_amp_env = EnvGen.kr(Env.perc(0, rel_times[2]));
        morph_env = EnvGen.kr(Env.linen(releaseTime: release, curve: \lin));
        signal_amp_env = EnvGen.kr(Env.perc(0, release));
        noise = WhiteNoise.ar() * noise_amp_env * snap;


        /*perc
         * Oscilators
         */
        2.do
        ({
            arg i;
            pulse_amp_envs[i] = EnvGen.kr
            (
                Env
                (
                    [1, 0, 0],
                    [rel_times[i], release],
                    \lin
                ),
                doneAction: Done.freeSelf
            );
            sine_amp_envs[i] = EnvGen.kr
            (
                Env
                (
                    [1, 0, 0],
                    [rel_times[i], release],
                    \lin
                ),
                doneAction: Done.freeSelf
            );
            pitch_envs[i] = EnvGen.kr
            (
                Env
                (
                    [
                        (pitch_starts[i] + midinote).midicps,
                        (pitch_ends[i] + midinote).midicps
                    ],
                    [rel_times[i]],
                    pitch_slopes[i]
                ),
                doneAction: Done.freeSelf
            );
            oscillators[i] = SinOsc.ar
            (
                freq: pitch_envs[i],
                mul: sine_amp_envs[i] * amps[i]  * 0.7
            );

            oscillators[i] = oscillators[i] + LFPulse.ar
            (
                freq: pitch_envs[i],
                mul: pulse_amp_envs[i] * amps[i] * morph_env * 0.3
            );

            signal = signal + oscillators[i];
        });
        signal = signal + noise;


        /*
         * Filter
         */
        pitch_envs[4] = EnvGen.kr
        (
            Env
            (
                [
                    (pitch_starts[4] + midinote).midicps,
                    (pitch_ends[4] + midinote).midicps
                ],
                [rel_times[4]],
                pitch_slopes[4]
            ),
            doneAction: Done.freeSelf
        );
        signal = BLowPass.ar
        (
            in: signal,
            freq: pitch_envs[4] * filter_moddepth,
            rq: filter_rq
        );
        signal = signal * signal_amp_env;
        Out.ar(out, signal ! 2);
    }
).add();
)

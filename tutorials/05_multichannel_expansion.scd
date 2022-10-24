// https://www.youtube.com/watch?v=fAXETAyrv8s
s.boot;

// See Multichannel Expansion in the SuperCollider Guides

// We can visualize output with `meter`:
s.meter;


// --- Expansion ---

// The following will output on the first channel:
x = {SinOsc.ar}.play;
x.free;

// If we want two-channel output, we can do:
x = {[SinOsc.ar(300), SinOsc.ar(500)]}.play;
x.free;

// You can re-write it like this, and SC will expand for you:
x = {SinOsc.ar([300, 500])}.play;
x.free;


// If we perform mathematical operations on two-multichannel UGens,
// then the arguments for one UGen will correspond to the arguments
// for the other UGen.
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7, 1]).range(0, 1);
	// The 300 Hz cycle will change in amplitude at a faster
	// rate than the 500 Hz one
	sig = SinOsc.ar([300, 500]);
	sig = sig * amp;
}.play;
)

x.free;

// If we perform mathematical operations on two multichannel signals
// that don't have the same number of channels, then the result will
// have the same number of channels as the maximal number of channels.
(
x = {
	var sig, amp;
	amp = SinOsc.kr(7).range(0, 1);
	// There will still be two channels, both multiplied by the
	// amplitude 7 control signal
	sig = SinOsc.ar([300, 500]);
	sig = sig * amp;
}.play;
)

x.free;


// --- Mixing and Duplicating ---

// There's a Mix UGen that can help us mix multichannel audio so
// we can output it into a smaller number of channels.
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0, 1);
	// There will still be two channels, both multiplied by the
	// amplitude 7 control signal
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;

	// Scale this down to avoid clipping and output
	// to two channels
	[Mix.new(sig), Mix.new(sig) ] * 0.25;

	// You could also write the above like:
	// Mix.new(sig).dup(2) * 0.25;
	// Mix.new(sig)!2 * 0.25;
}.play;
)

x.free;

60.dup(4);
"hello".dup(4);
3!4;

// There's also Splay which mixes down to stereo
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0, 1);
	// There will still be two channels, both multiplied by the
	// amplitude 7 control signal
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;

	Splay.ar(sig) * 0.5;
}.play;
)

x.free;


// Pitfall 1: Duplicating functions or arguments?

// In this example, we create two copies of the same noise source:
x = {PinkNoise.ar(0.5)!2}.play;
x.free;

// If you duplicate the argument, however, SuperCollider will
// create two instances for you
x = {PinkNoise.ar(0.5!2)}.play;
x.free;


// Pitfall 2: In a SynthDef with an Out, what do we specify
// for the bus argument?
(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0, 1);
	// There will still be two channels, both multiplied by the
	// amplitude 7 control signal
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;

	Splay.ar(sig) * 0.5;
	Out.ar(0, sig);  // <== SC will spread across two channels
}).add;
)

x = Synth.new(\multi);
x.free;


// But if we change the output to [0, 1], there will be
// outputs at [0, 1] and [1, 2] giving signal overlap on
// channel 1.
(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0, 1);
	// There will still be two channels, both multiplied by the
	// amplitude 7 control signal
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;

	Splay.ar(sig) * 0.5;
	Out.ar([0, 1], sig);  // <== don't do this, and just
	                      // specify the lowest output channel
}).add;
)

x = Synth.new(\multi);
x.free;


// --- Expansion for Arrays ---
rrand(50, 1200)!4;  // We always get four copies of the same value
{rrand(50, 1200)}!4;  // We get four different values

// Using this in context:
(
SynthDef.new(\multi, {
	var sig, amp;

	// expand outside of the {}
	amp = SinOsc.kr({exprand(0.2, 12)}!8).range(0, 1);
	sig = SinOsc.ar({exprand(50, 1200)}!8);

	// Note, though that this still isn't the best option:
	// these `exprand`s are expanded when the SynthDef is
	// compiled, not when the synth is created. This means
	// every synth made from the SynthDef will have the same
	// random values, which you probably don't mean.
	//
	// Instead, see the next example...

	sig = sig * amp;
	Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);  // Each execution will sound the same
x.free;


(
SynthDef.new(\multi, {
	var sig, amp;

	// This will pick different random values for
	// each instance of a synth.
	amp = SinOsc.kr({ExpRand(0.2, 12)}!8).range(0, 1);
	sig = SinOsc.ar({ExpRand(50, 1200)}!8);

	sig = sig * amp;
	Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);  // Each time you execute this,
                        // it should sound different now
x.free;


// Let's add an envelope:
(
SynthDef.new(\multi, {
	var sig, amp, env;
	env = EnvGen.kr(
		Env.new([0, 1, 0], [10, 10], [1, -1]),
		doneAction:2
	);
	amp = SinOsc.kr({ExpRand(0.2, 12)}!8).range(0, 1);
	sig = SinOsc.ar({ExpRand(50, 1200)}!8);
	sig = sig * amp * env;
	Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)
x = Synth.new(\multi);

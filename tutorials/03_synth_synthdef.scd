// https://www.youtube.com/watch?v=LKGGWsXyiyo

s.boot;

// Before, we were creating functions that contained UGens which
// would execute the `play` method. This creates a Synth which
// represents a single sound on the audio server.

// The more flexible method is to create a SynthDef and then
// execute the SynthDef by calling a Synth explicitly.

// Open the `Core > Kernel > Function` help documentation and
// find Function.play
//
// > Function.play is often more convenient than SynthDef.play,
// > particularly for short examples and quick testing. The latter
// > does have some additional options, such as lagtimes for
// > controls, etc. Where reuse and maximum flexibility are of greater
// > importance, SynthDef and its various methods are usually the
// > better choice.
//
// Open `Server > Abstractions > SynthDef` in the help browser
//
// > Methods such as Function-play, etc. are simply conveniences
// > which automatically create such a def.

// Let's convert our previous function into a SynthDef!
(
z = {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	amp = LFNoise1.kr(12).exprange(0.02, 1);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

// `new` takes six arguments, but generally you'll only specify the
// first two (name, ugenGraphFunc).
// The ugenGraphFunc is basically the same as what we had before, but
// this time, we need to specify an output UGen.
(
SynthDef.new(\sineTest, {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	amp = LFNoise1.kr(12).exprange(0.02, 1);
	sig = SinOsc.ar(freq) * amp;

	// Out takes the output bus index and the signal to write to that
	// bus. We'll look more output busses it in later tutorials.
	Out.ar(0, sig);

	// To add the SynthDef to the audio server, we use the `add` message.
	// Others exist (e.g. load), but `add` is probably the most common.
}).add;
)

// To execute the SynthDef, we create a new Synth and provide it with
// a name.
x = Synth.new(\sineTest);
// We can free as usual.
x.free;

// We can also create the Synth with arguments and manipulate arguments.
x = Synth.new(\sineTest, [\noiseHz, 32]);
x.set(\noiseHz, 12);
x.free;

// Synth.new can also take `target` and `addAction` arguments which we'll
// look at later.


// Let's make a new SynthDef to practice!
(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPartial=4, width=0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;

	// The duty-cycle of these pulses will be pretty short.
	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.75;  // Let's make them out of phase

	// These random noise generators are independent of each other.
	// `round` will give us the closest whole number and means the following
	// will produce random overtones that are multiples of the fundamental
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);

	// We can add octave jumps. The LFPulse will range from 1..2 when we add 1.
	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);

	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);

	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);

	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

x = Synth.new(\pulseTest);

x.set(\width, 0.25);
x.set(\fund, 50);
x.set(\maxPartial, 8);
x.set(\ampHz, 2);

x.free;

// Remember we can initialize the Synth with arguments
x = Synth.new(\pulseTest, [\ampHz, 3.3, \fund, 48, \maxPartial, 4, \width, 0.15]);
x.free;
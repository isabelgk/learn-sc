// https://www.youtube.com/watch?v=-wDAPo9hpCg

s.boot;


// --- Envelopes and `doneAction`

// Browse > UGens > Envelopes > Line (Class Methods)
//
// Notice there's an argument called `doneAction`?
// There are different things SuperCollider can do
// when an envelope finishes.
//
// UGens > Synth control > Done (Actions)
// The most common ones are:
// - `none`     (0): do nothing when the UGen is finished
// - `freeSelf` (2): free the enclosing synth

// It's easiest to see what we're going to explore via
// the node tree
s.plotTree;


// Let's create a synth which uses a (0) doneAction for Line
// Watch the node tree and the server status bar on the bottom
// right for the synth count (the value before "s").
(
x = {
	var sig, env;
	env = Line.kr(1, 0, 1);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

// If you execute the above synth multiple times, the synth
// count will keep rising, and you won't be able to free anything
// but the most recent synth. You'll have to use
s.freeAll;


// If you use the (2) doneAction, the server will free the synth
// once the envelope finishes. We won't need a name for the
// automatically-freed synth anymore, either!
(
{
	var sig, env;
	env = Line.kr(1, 0, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)


// There's an exponential version of Line which works
// well for amplitude and frequency.
(
{
	var sig, env;
	// We need to constrain the range to the positive or
	// negative domain for XLine
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

// Decibels would work better with Line, and there's a
// message just for that case.
(
{
	var sig, env;
	env = Line.kr(0, -40, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env.dbamp;
}.play;
)

// You can convert in the other direction with `ampdb`

// Let's experiment with modulating frequency.
(
{
	var sig, freq, env;
	// It doesn't matter which one has doneAction:2 since
	// both have the same duration. If the durations
	// were different, you'd have to be more careful
	// to not free too soon.
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play;
)

// Let's look at a more complex envelope -- EnvGen
// EnvGen uses a class of objects called `Env`.

// We can look at an Env with `plot`.
Env.new.plot;

// Take a look at the documentation for EnvGen.new first. Let's
// see it in action
(
{
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

// Here's how we change the envelope breakpoints:
Env.new([0, 1, 0.2, 0], [0.5, 1, 2]).plot;
// We can make it exponential via the curve arg like this:
Env.new([0, 1, 0.2, 0.01], [0.5, 1, 2], \exp).plot;
// ... or by specifying curvature values in an array:
Env.new([0, 1, 0.2, 0.01], [0.5, 1, 2], [3, -3, 0]).plot;
// We can use symbols for curvature, too!
Env.new([0, 1, 0.2, 0.01], [0.5, 1, 2], [\sin, 12, -0.5]).plot;

// Let's try listening:
(
{
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -3, 0]
	), doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)


// You can trigger the envelope via the gate argument to EnvGen
(
x = {
	arg gate=0;
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -3, 0]
	), gate);
	sig = Pulse.ar(LFPulse.kr(8).range(600, 900)) * env;
}.play;
)

x.set(\gate, 1);  // evaluating this a second time won't do anything
                  // because the trigger only happens when the
                  // gate goes from 0 -> 1
x.free;


// Instead of manually dealing with resetting the gate, you
// can make a trigger argument by naming arguments with a prefix `t_`
(
x = {
	arg t_gate=0;   // <==
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -3, 0]
	), t_gate);     // <==
	sig = Pulse.ar(LFPulse.kr(8).range(600, 900)) * env;
}.play;
)

x.set(\t_gate, 1);
x.free;

// It's important to use the right doneAction for something that
// can be retriggered. If we use doneAction:2, then we can only
// retrigger if the envelope hasn't finished yet.
//
// Rule of thumb: Use doneAction:0 if you want a retriggerable
//                envelope. If you want a one-shot, use 2.


(
x = {
	arg gate=0;
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate);
	sig = VarSaw.ar(SinOsc.kr(16).range(500, 1000)) * env;
}.play;
)

// If you used a trigger gate, then there would never be a sustain
x.set(\gate, 1);  // Start and sustain
x.set(\gate, 0);  // Release
x.free;


// Example of using an envelope to modulate frequency:
(
x = {
	arg gate=0;
	var sig, env, freq;
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = VarSaw.ar(SinOsc.kr(freq).range(500, 1000)) * env;
}.play;
)
x.set(\gate, 1);
x.set(\gate, 0);


// If you look at the Env help file, there are a lot of messages
// available besides new and adsr -- sinusoids, triangles, dadsr,
// asr, and more.
// https://www.youtube.com/watch?v=oTBcGPXH6K0

// Start the SC server
Server.local.boot;

// Quit the server
Server.local.quit;

// The global variable `s` is short for `Server.local`
s.boot;
s.quit;

// You can also start via the Server menu or a keyboard shortcut


// --- Functions ---

// Functions are an easy way to create sound and are written
// with curly braces
{SinOsc.ar}.play;  // We create a function containing a unit generator

// You can stop the sound with Ctrl+.

// Notice that the post window shows something like
// `Synth('temp__1' : 1000)`

// Synths exist on the audio server and can be destroyed with the
// message `free` (instead of killing all sound with Ctrl+.)

x = {SinOsc.ar}.play;  // Store in a global variable
x.free;                // and now free it


// The following isn't going to work the way you think:
x = {SinOsc.ar};   // Store a function in `x`
x.play;            // Create a Synth from the function `x`
x.free;            // Oh no -- you can't free a function

y = x.play;        // Better!
y.free;



// --- Unit Generators ---

// Unit Generators (UGens) are basic building blocks of synth
// definitions on the server. They're used to generate/process
// audio/control signals. (See more in the documentation.)

// They accept messages:
//  - ar(arg1, arg2, ...)  for audio
//  - kr(arg1, arg2, ...)  for control rate
//  - ir(arg1, arg2, ...)  for calculation at initialization

// See Documentation:
// - UGen
// - UGens
// - Unit Generators and Synths
// - Tour of UGens

// Try looking at the SinOsc documentation with Ctrl+D
x = {SinOsc.ar};

// Class methods include:
//     ar (freq: 440, phase: 0, mul: 1, add: 0)
// `mul` and `add` are very common arguments


// --- Arguments ---

// If we don't specify an argument, the default is used
// We can specify values like you'd expect
x = {SinOsc.ar(700, 0, 0.125, 0)}.play;
x.free;

// If we only specify some, the rest use defaults
x = {SinOsc.ar(400)}.play;
x.free;

// We can also skip arguments using `arg:val`
x = {SinOsc.ar(330, mul:0.5)}.play;
x.free;

// We can also add args to our own functions so that
// we can modify them as they're playing
(
z = {
	// Arguments must be declared before variables
	// and must begin with a lowercase letter
	arg freq=440, amp=1;
	// Variables come before the rest of the code
	var sig;
	sig = SinOsc.ar(freq) * amp;
}.play;
)

// To change the argument's value, use `set`
z.set(\freq, 330);
z.set(\freq, 550);
z.set(\amp, 0.5);
z.set(\freq, 660, \amp, 1);
z.set(\amp, 0.5, \freq, 440);
z.free;


// --- Control-rate modulation ---
(
z = {
	var freq, sig;
	// The default output of LFNoise0 is -1..1, but we can
	// scale from 200 to 1000 by multiplying by 400 and
	// adding 600.
	freq = LFNoise0.kr(8, 400, 600);
	sig = SinOsc.ar(freq);
}.play;
)

z.free;

// A more intuitive way to scale is with `range`
(
z = {
	var freq, sig;
	// Don't use range and mul/add at the same time
	// because they'll conflict
	freq = LFNoise0.kr(8).range(200, 1000);
	sig = SinOsc.ar(freq);
}.play;
)

z.free;


// See the UGen documentation for other methods
// that come in handy -- e.g. exprange, curverange,
// unipolar, clip...


// Let's try a more complicated example using what
// we've learned so far!
(
z = {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	amp = LFNoise1.kr(12).exprange(0.02, 1);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.set(\noiseHz, 16);
z.set(\noiseHz, 32);
z.set(\noiseHz, 4);

// We can also have SuperCollider generate a new
// random value everytime the following is executed
z.set(\noiseHz, exprand(4, 64));

z.free;


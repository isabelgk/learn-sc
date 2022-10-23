/// https://www.youtube.com/watch?v=ntL8QDOhhL8

/// Supercollider uses a "receiver" "message"/"method" paradigm
// receiver.message


/// Evaluate a line with Ctrl/Cmd + Enter
3.cubed

/// Clear the post window with Ctrl + P


/// Variables
/// Lowercase a-z are reserved for use as global variables
x = 3.cubed
x
x + 10

/// You can also declare global variables with `~`
~gl = 1 + 3;

/// You need to declare local variables, unlike global variables
// ERROR: Variable 'number' not defined.
// number = 3.cubed

/// Local variables are declared with `var`
/// Evaluate multiple lines of code by highlighting them and running
/// or by enclosing them in `(` `)`
var foo;
foo = 4.sqrt;

(
var number;
number = 3.cubed;
)


/// You can update variables like you'd expect
(
var thing;
thing = 3;
thing = thing.cubed;  // 27
thing = thing + 100;  // 127
thing = thing / 2;    // 63.5
thing;
)


/// There is *no order of operations* in SC
3.cubed + 100 / 2;  // Not (27) + (50) = 77, like you'd expect


/// To lookup documentation, hover over something and use Ctrl+D
/// You can also search with Shift+Ctrl+D
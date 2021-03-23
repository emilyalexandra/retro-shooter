module util.math;

import std.algorithm;
import std.format;
import std.math;
import std.traits;

alias Vec2 = Vector!(double, 2);
alias Vec3 = Vector!(double, 3);
alias Vec4 = Vector!(double, 4);

alias Vec2i = Vector!(int, 2);
alias Vec3i = Vector!(int, 3);
alias Vec4i = Vector!(int, 4);

struct Vector(T, uint SIZE) {
	static assert(SIZE > 0, "Can't have a vector with no axis");
	static assert(SIZE <= AXIS_NAMES.length, "Can't have a vector with more than %s axes".format(AXIS_NAMES.length));

	// This could be expanded, but I don't think I'll be using anything bigger than 4, and don't know what to call them past this
	private enum string[] AXIS_NAMES = ["x", "y", "z", "w"];

	static foreach (uint i; 0..SIZE) {
		mixin(q{
			T %s;
		}.format(AXIS_NAMES[i]));
	}

	this(A...)(A args) {
		static assert (args.length == SIZE, "Vector argument length mismatch, expected %s, got %s".format(SIZE, args.length));
		static foreach (uint i; 0..SIZE) {
			mixin(q{
				%s = args[i];
			}.format(AXIS_NAMES[i]));
		}
	}

	@property T magnitude() {
		T ret = 0;
		static foreach (uint i; 0..SIZE) {
			mixin(q{
				ret += pow(%s, 2);
			}.format(AXIS_NAMES[i]));
		}
		static if (isFloatingPoint!T) {
			return sqrt(ret);
		} else {
			return cast(T) sqrt(cast(float) ret);
		}
	}

	Vector!(T, SIZE) normalize() {
		Vector!(T, SIZE) ret = this;
		static foreach (uint i; 0..SIZE) {
			mixin(q{
				ret.%s /= magnitude();
			}.format(AXIS_NAMES[i]));
		}
		return ret;
	}

	T dot(Vector!(T, SIZE) b) {
		T ret = 0;
		static foreach (uint i; 0..SIZE) {
			mixin(q{
				ret += %s * b.%s;
			}.format(AXIS_NAMES[i], AXIS_NAMES[i]));
		}
		return ret;
	}

	Vector!(T, SIZE) opBinary(string OP)(Vector!(T, SIZE) b) {
		static foreach (uint i; 0..SIZE) {
			mixin(q{
				b.%s = %s %s b.%s;
			}.format(AXIS_NAMES[i], AXIS_NAMES[i], OP, AXIS_NAMES[i]));
		}
		return b;
	}

	auto opDispatch(string S)() {
		static assert(S.length > 1);
		Vector!(T, S.length) ret;

		static foreach (uint i; 0..S.length) {
			mixin(q{
				ret.%s = %s;
			}.format(AXIS_NAMES[i], S[i]));
		}

		return ret;
	}
}

unittest {
	Vec3i a = Vec3i(10, 1, 2);
	Vec3i b = Vec3i(2, 2, 2);

	assert(a + b == Vec3i(12, 3, 4));
	assert(a - b == Vec3i(8, -1, 0));
	assert(a * b == Vec3i(20, 2, 4));
	assert(a / b == Vec3i(5, 0, 1));

	assert(a.xz == Vec2i(10, 2));
	assert(a.xxx == Vec3i(10, 10, 10));
	assert(a.zyxz == Vec4i(2, 1, 10, 2));

	assert(b.magnitude == 3); // Rounding :)
	assert(a.dot(b) == 26);

	assert(Vec3(10, 3, 11).normalize().magnitude == 1);
}
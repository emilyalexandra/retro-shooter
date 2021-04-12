module network.packet;

import std.traits;

import vibe.data.json;

import util.math;

Json serializePacket(T)(T packet) {
	Json json = serializeType(packet);
	
	return json;
}

Json serializeType(T)(T type) {

}

Packet parsePacket(Json json) {
	if (json["id"].type != Json.Type.String) {
		return null;
	}
	if (json["id"].get!string == "position") {

	}

	/*
	static foreach(member; __traits(allMembers, network.packet)) {
		static if (isType!(__traits(getMember, network.packet, member)) && hasUDA!(__traits(getMember, network.packet, member), Id)) {
			mixin(q{
				if (json["id"].get!string == %s) {
					return new 
				}
			});
		}
	}*/
	return null;
}

private struct Id {
	string id;
}

abstract class Packet {
	uint clientId;

	abstract string getId();
}

@Id("position")
class PositionPacket: Packet {
	override string getId() = () => "position";
	Vec3 position;
	
}
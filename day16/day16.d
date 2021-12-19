import std;

void main() {
    Bitstream stream = Bitstream(readText("day16/input.txt").strip.byCodeUnit.map!parseHex.array);

    Packet[] root_packets;
    while (stream.num_bits - stream.pos > 6) {
        root_packets ~= parsePacketRecursive(stream);
    }

    int version_sum = 0;
    foreach (Packet packet; root_packets) {
        addVersionRecursive(packet, version_sum);
    }

    writefln("The sum of all version numbers is %s", version_sum);

    assert(root_packets.length == 1);
    ulong result = evaluateRecursive(root_packets[0]);

    writefln("The result of the expression is %s", result);
}

struct Packet {
    int type_id;
    int packet_version;
    ulong number;

    Packet[] sub_packets;
}

void addVersionRecursive(Packet packet, ref int version_sum) {
    version_sum += packet.packet_version;

    foreach (Packet sub_packet; packet.sub_packets) {
        addVersionRecursive(sub_packet, version_sum);
    }
}

ulong evaluateRecursive(Packet packet) {
    final switch (packet.type_id) {
        case 0: {
            ulong result = 0;
            foreach (Packet sub_packet; packet.sub_packets) {
                result += evaluateRecursive(sub_packet);
            }
            return result;
        }

        case 1: {
            ulong result = 1;
            foreach (Packet sub_packet; packet.sub_packets) {
                result *= evaluateRecursive(sub_packet);
            }
            return result;
        }

        case 2: {
            ulong result = ulong.max;
            foreach (Packet sub_packet; packet.sub_packets) {
                result = min(result, evaluateRecursive(sub_packet));
            }
            return result;
        }

        case 3: {
            ulong result = 0;
            foreach (Packet sub_packet; packet.sub_packets) {
                result = max(result, evaluateRecursive(sub_packet));
            }
            return result;
        }

        case 4: {
            return packet.number;
        }

        case 5: {
            assert(packet.sub_packets.length == 2);
            return evaluateRecursive(packet.sub_packets[0]) > evaluateRecursive(packet.sub_packets[1]);
        }

        case 6: {
            assert(packet.sub_packets.length == 2);
            return evaluateRecursive(packet.sub_packets[0]) < evaluateRecursive(packet.sub_packets[1]);
        }

        case 7: {
            assert(packet.sub_packets.length == 2);
            return evaluateRecursive(packet.sub_packets[0]) == evaluateRecursive(packet.sub_packets[1]);
        }
    }
}

Packet parsePacketRecursive(ref Bitstream stream) {
    Packet result;
    result.packet_version = stream.readBits(3);
    result.type_id = stream.readBits(3);

    if (result.type_id == 4) {
        ulong number = 0;
        int part;
        do {
            part = stream.readBits(5);
            number <<= 4;
            number |= (part & 15);
        }
        while (part >> 4 == 1);
        result.number = number;
    } else {
        int type = stream.readBits(1);
        if (type == 0) {
            int sub_packet_size = stream.readBits(15);
            size_t end_pos = stream.pos + sub_packet_size;
            while (stream.pos != end_pos) {
                result.sub_packets ~= parsePacketRecursive(stream);
            }
        } else {
            int sub_packet_count = stream.readBits(11);
            foreach (i; 0 .. sub_packet_count) {
                result.sub_packets ~= parsePacketRecursive(stream);
            }
        }
    }

    return result;
}

int parseHex(char c) {
    if (c >= 'A') {
        return c - 'A' + 10;
    } else {
        return c - '0';
    }
}

struct Bitstream {
    uint[] buffer;
    size_t num_bits;
    size_t pos;

    this(int[] hex_bits) {
        buffer = new uint[](hex_bits.length + 7 / 8 + 1);
        buffer[] = 0;
        foreach (i, bits; hex_bits) {
            size_t index = i >> 3;
            size_t offset = (7 - (i & 7)) * 4;
            buffer[index] |= bits << offset;
        }

        num_bits = hex_bits.length * 4;
        pos = 0;
    }

    uint readBits(size_t to_read) in {
        assert(to_read <= 32);
        assert(pos + to_read <= num_bits);
    } do {
        uint result = 0;

        size_t first_read_size = min(to_read, 32 - (pos & 31));
        size_t second_read_size = to_read - first_read_size;
        result |= ((buffer[pos >> 5] >> (32 - (pos & 31) - first_read_size)) & ((1u << first_read_size) - 1)) << second_read_size;
        result |= (buffer[(pos >> 5) + 1] >> (32 - second_read_size)) & ((1u << second_read_size) - 1);

        pos += to_read;

        return result;
    }
}
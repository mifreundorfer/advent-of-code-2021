import std;

void main() {
    int[][] map;

    foreach (line; readText("day9/input.txt").splitLines()) {
        map ~= line.map!(x => cast(int)(x - '0')).array;
    }

    int size_x = cast(int)map[0].length;
    int size_y = cast(int)map.length;

    int risk_level_sum = 0;
    foreach (y; 0 .. size_y) {
        foreach (x; 0 .. size_x) {
            int height = map[y][x];

            bool is_lower = true;
            if (x > 0 && map[y][x - 1] <= height) {
                is_lower = false;
            }

            if (x < size_x - 1 && map[y][x + 1] <= height) {
                is_lower = false;
            }

            if (y > 0 && map[y - 1][x] <= height) {
                is_lower = false;
            }

            if (y < size_y - 1 && map[y + 1][x] <= height) {
                is_lower = false;
            }

            if (is_lower) {
                int risk_level = height + 1;
                risk_level_sum += risk_level;
            }
        }
    }

    writefln("Sum of risk level for all low points is %s", risk_level_sum);

    int[][] basin_indices = new int[][size_y];
    foreach (i; 0 .. size_y) {
        basin_indices[i] = new int[size_x];
        basin_indices[i][] = 0;
    }

    int[] basin_sizes = [];

    struct Coord {
        int x;
        int y;
    }

    Coord[] todo = [];

    foreach (y; 0 .. size_y) {
        foreach (x; 0 .. size_x) {
            if (map[y][x] == 9 || basin_indices[y][x] != 0) {
                continue;
            }

            int basin_index = cast(int)basin_sizes.length;
            assert(todo.length == 0);
            basin_indices[y][x] = basin_index;
            int basin_size = 1;
            todo ~= Coord(x, y);

            while (todo.length != 0) {
                Coord coord = todo[$-1];
                todo.length -= 1;

                if (coord.x > 0 && map[coord.y][coord.x - 1] != 9) {
                    int* index = &basin_indices[coord.y][coord.x - 1];
                    if (*index != basin_index) {
                        assert(*index == 0);
                        *index = basin_index;
                        basin_size += 1;
                        todo ~= Coord(coord.x - 1, coord.y);
                    }
                }

                if (coord.x < size_x - 1 && map[coord.y][coord.x + 1] != 9) {
                    int* index = &basin_indices[coord.y][coord.x + 1];
                    if (*index != basin_index) {
                        assert(*index == 0);
                        *index = basin_index;
                        basin_size += 1;
                        todo ~= Coord(coord.x + 1, coord.y);
                    }
                }

                if (coord.y > 0 && map[coord.y - 1][coord.x] != 9) {
                    int* index = &basin_indices[coord.y - 1][coord.x];
                    if (*index != basin_index) {
                        assert(*index == 0);
                        *index = basin_index;
                        basin_size += 1;
                        todo ~= Coord(coord.x, coord.y - 1);
                    }
                }

                if (coord.y < size_y - 1 && map[coord.y + 1][coord.x] != 9) {
                    int* index = &basin_indices[coord.y + 1][coord.x];
                    if (*index != basin_index) {
                        assert(*index == 0);
                        *index = basin_index;
                        basin_size += 1;
                        todo ~= Coord(coord.x, coord.y + 1);
                    }
                }
            }

            basin_sizes ~= basin_size;
        }
    }

    int result = basin_sizes.topN!("a > b")(3).array.fold!("a * b")(1);
    writefln("The multiplied size of the three largest basins is %s", result);
}
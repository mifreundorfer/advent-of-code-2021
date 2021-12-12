import std;

void main() {
    Cell[] cells = readText("day11/input.txt").splitLines.join.map!(x => Cell(x - '0')).array;
    Grid grid = Grid(cells.dup, 10, 10);

    int total_flashes = 0;
    foreach (int step; 0 .. 100) {
        foreach (ref cell; grid.cells) {
            cell.level += 1;
        }

        while (true) {
            bool has_flashed = false;
            foreach (ref cell; grid.cells) {
                if (cell.level > 9) {
                    // Cells that have flashed marked with level -1
                    cell.level = -1;
                    total_flashes += 1;
                    has_flashed = true;

                    foreach (ref Cell surrounding_cell; grid.surroundingCellsIter(cell)) {
                        // If a cell has flashed don't increase its energy level, it may flash at most once during a cycle
                        if (surrounding_cell.level > 0) {
                            surrounding_cell.level += 1;
                        }
                    }
                }

            }

            if (!has_flashed) {
                break;
            }
        }

        // Set all flashed cells back to energy level 0
        foreach (ref cell; grid.cells) {
            if (cell.level == -1) {
                cell.level = 0;
            }
        }
    }

    writefln("The first time all octopussed 100 steps there have been a total of %s flashes", total_flashes);

    grid = Grid(cells.dup, 10, 10);
    int step = 0;
    while (true) {
        step += 1;
        foreach (ref cell; grid.cells) {
            cell.level += 1;
        }

        while (true) {
            bool has_flashed = false;
            foreach (ref cell; grid.cells) {
                if (cell.level > 9) {
                    // Cells that have flashed marked with level -1
                    cell.level = -1;
                    total_flashes += 1;
                    has_flashed = true;

                    foreach (ref Cell surrounding_cell; grid.surroundingCellsIter(cell)) {
                        // If a cell has flashed don't increase its energy level, it may flash at most once during a cycle
                        if (surrounding_cell.level > 0) {
                            surrounding_cell.level += 1;
                        }
                    }
                }

            }

            if (!has_flashed) {
                break;
            }
        }

        // Set all flashed cells back to energy level 0
        int num_flashed = 0;
        foreach (ref cell; grid.cells) {
            if (cell.level == -1) {
                num_flashed += 1;
                cell.level = 0;
            }
        }

        if (num_flashed == grid.width * grid.height) {
            break;
        }
    }

    writefln("The first time a synchronized flash occurs is after %s steps", step);
}

struct Grid {
    Cell[] cells;
    int width;
    int height;

    this(Cell[] cells, int width, int height) in {
        assert(width > 0);
        assert(height > 0);
        assert(cells.length == width * height);
    } do {
        this.cells = cells;
        this.width = width;
        this.height = height;

        foreach (int y; 0 .. height) {
            foreach (int x; 0 .. width) {
                cells[x + y * width].index = Index(x, y);
            }
        }
    }

    ref Cell opIndex(Index index) in {
        assert(index.x >= 0 && index.x < width);
        assert(index.y >= 0 && index.y < height);
    } do {
        return cells[index.x + index.y * width];
    }

    SurroundingCellsIter surroundingCellsIter(Cell cell) {
        auto iter = SurroundingCellsIter(&this, cell, -1, -1);
        while (!iter.empty && !iter.indexIsInGrid) {
            iter.moveToNextCell();
        }
        return iter;
    }

    struct SurroundingCellsIter {
        Grid* grid;
        Cell cell;
        int x;
        int y;

        @property bool empty() {
            return y > 1;
        }

        @property ref Cell front() {
            return (*grid)[Index(cell.index.x + x, cell.index.y + y)];
        }

        void popFront() {
            moveToNextCell();
            while (!empty && !indexIsInGrid) {
                moveToNextCell();
            }
        }

        @property bool indexIsInGrid() {
            return cell.index.x + x >= 0
                && cell.index.x + x < grid.width
                && cell.index.y + y >= 0
                && cell.index.y + y < grid.height;
        }

        void moveToNextCell() {
            x += 1;
            if (x > 1) {
                x = -1;
                y += 1;
            }

            if (x == 0 && y == 0) {
                x += 1;
            }
        }
    }
}

struct Cell {
    int level;
    Index index;
}

struct Index {
    int x;
    int y;
}

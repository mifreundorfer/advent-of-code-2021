import std;

void main()
{
    int[] input = split(readText("day6/input.txt").strip, ',').map!(to!int).array;

    int[] fish = input.dup;
    foreach (i; 0..80) {
        foreach (j; 0 .. fish.length) {
            if (fish[j] == 0) {
                fish[j] = 6;
                fish ~= 8;
            } else {
                fish[j] -= 1;
            }
        }
    }

    writefln("After 80 days there are %s fish", fish.length);

    long[] numBreeders = new long[9];
    numBreeders[] = 0;

    foreach (timer; input) {
        numBreeders[timer] += 1;
    }

    int numDays = 256;
    foreach (i; 0 .. numDays) {
        long todayBreeders = numBreeders[0];
        foreach (j; 0 .. 8) {
            numBreeders[j] = numBreeders[j+1];
        }
        numBreeders[8] = todayBreeders;
        numBreeders[6] += todayBreeders;
    }

    writefln("After %s days there are %s fish", numDays, sum(numBreeders));
}

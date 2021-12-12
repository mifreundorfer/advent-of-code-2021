module day7.day7;

import std;

void main()
{
    int[] input = split(readText("day7/input.txt").strip, ',').map!(to!int).array;

    int maxPos = input.maxElement();

    int minCost = int.max;
    int idealPos = -1;
    foreach (targetPos; 0 .. maxPos) {
        int totalCost = 0;
        foreach (pos; input) {
            int cost = abs(pos - targetPos);
            totalCost += cost;
        }

        if (totalCost < minCost) {
            idealPos = targetPos;
            minCost = totalCost;
        }
    }

    writefln("Ideal position is at %s, costing %s fuel", idealPos, minCost);

    minCost = int.max;
    idealPos = -1;
    foreach (targetPos; 0 .. maxPos)
    {
        int totalCost = 0;
        foreach (pos; input)
        {
            int distance = abs(pos - targetPos);
            // The series of 1 + 2 + 3 + ... + n is the same as (n^2 + n)/2
            int cost = (distance * distance + distance) / 2;
            totalCost += cost;
        }

        if (totalCost < minCost)
        {
            idealPos = targetPos;
            minCost = totalCost;
        }
    }

    writefln("Adjusted ideal position is at %s, costing %s fuel", idealPos, minCost);
}
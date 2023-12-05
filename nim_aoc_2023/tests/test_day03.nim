import unittest
import nim_aoc_2023/day03 

const data1: string = "..33.\n1@...\n.1.4\n...%\n"

let schm = initSchematic(data1)
echo "schm.w: ", schm.w
echo "schm.h: ", schm.h
echo "schm.data: ", schm.data
echo "schm.nums: ", schm.nums

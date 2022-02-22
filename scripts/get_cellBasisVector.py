"""This script gives you the coordinates to set for the periodic boundary conditions when used Truncated Octahedron
reference from https://ambermd.org/namd/namd_amber.html """
import math

d = 84.1184799 #73.2952106
cell10 = d
cell11 = 0.0
cell12 = 0.0

cell20 = (-1/3)*d
cell21 = (2/3)*math.sqrt(2)*d
cell22 = 0.0

cell30 = (-1/3)*d
cell31 = (-1/3)*math.sqrt(2)*d
cell32 = (-1/3)*math.sqrt(6)*d

print(cell10, '\t', cell11, '\t', cell12 )
print(cell20, '\t', cell21, '\t', cell22 )
print(cell30, '\t', cell31, '\t', cell32 )


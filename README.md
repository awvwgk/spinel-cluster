# Set up for a spinel lattice

The program is invoked with ruby

    ruby spinel.rb lattice_constant atom_type_A atom_type_B atom_type_X cut_off_radius x_pos y_pos z_pos

The script places a hardcoded primitiv cell of a normal type spinel (AB2X4) with the specified lattice constant. You can choose a cut off radius to determinate the size of the cluster from a given position _within_ the primitive cell. 
In case the position is outside the primitive cell I will translate the coordinate system.

Enjoy!

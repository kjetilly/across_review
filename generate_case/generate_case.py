import os
import argparse


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description="""
Generate a modified SPE1 case with the given resolution.
                                     
The default resolution is 10 x 10 x 3. This will generate a
a new case with resolution nx * 10 x ny * 10 x nz * 3
        """)

    parser.add_argument('-x', '--nx', type=int, default=10,
                        help='Number of times to increase x.')

    parser.add_argument('-y', '--ny', type=int, default=10,
                        help='Number of times to increase y.')

    parser.add_argument('-z', '--nz', type=int, default=50,
                        help='Number of times to increase z.')

    parser.add_argument('-o', '--output-dir', type=str, default='generated_highres_spe1',
                        help='Outputdir to place the new ensemble.')

    args = parser.parse_args()

    directory_of_script = os.path.dirname(os.path.realpath(__file__))
    template_dir = os.path.join(directory_of_script, 'template_ert')

    xbase = 10
    ybase = 10
    zbase = 3
    replacements = {
        'ACROSS_NUM_X': args.nx * xbase,
        'ACROSS_NUM_Y': args.ny * ybase,
        'ACROSS_NUM_Z': args.nz * zbase,
        'ACROSS_CELLS_X_DIRECTION': args.nz * zbase * args.ny * ybase,
        'ACROSS_CELLS_Y_DIRECTION': args.nz * zbase * args.nx * xbase,
        'ACROSS_CELLS_Z_DIRECTION': args.ny * ybase * args.nx * xbase,
        'ACROSS_NUM_GRID_CELLS': args.nz * zbase * args.ny * ybase * args.nx * xbase,
        'ACROSS_LAYER_SIZE': (args.nz * zbase * args.ny * ybase * args.nx * xbase)//3,
    }
    for path, dirs, files in os.walk(template_dir):
        targetdir = path.replace(template_dir, args.output_dir)
        os.makedirs(targetdir, exist_ok=True)
        for fname in files:
            targetfile = os.path.join(targetdir, fname)
            with open(os.path.join(path, fname), 'r') as source:
                with open(targetfile, 'w') as target:
                    for l in source:
                        for k, v in replacements.items():
                            l = l.replace(k, str(v))
                        target.write(f'{l}')

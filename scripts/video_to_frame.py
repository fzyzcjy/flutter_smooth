import os
from argparse import ArgumentParser
from pathlib import Path


def _run_command(command):
    print(f'>>> {command}')
    os.system(command)


parser = ArgumentParser()
parser.add_argument('input')
parser.add_argument('--output', default='~/temp/video_frames')
args = parser.parse_args()

path_input = Path(args.input)
dir_output = Path(args.output)

assert path_input.exists()

_run_command(f'mkdir -p {dir_output}')
_run_command(f'rm {dir_output}/*.jpg')
_run_command(
    f"ffmpeg -i {path_input} -vsync 0 -frame_pts true "
    # add text about time information at left-top
    "-vf drawtext=fontfile=/usr/share/fonts/truetype/freefont/FreeMonoBold.ttf:fontsize=80:text='%{pts}':fontcolor=white@0.8:x=7:y=7 "
    f"{dir_output}/output_%04d.jpg"
)

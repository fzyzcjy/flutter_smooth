import os
from pathlib import Path

repo_base_dir = Path(__file__).parents[1]


def run_command(command):
    print(f'>>> {command}')
    os.system(command)

from argparse import ArgumentParser

from generation import fetch_github_pr, generate_pr_status, readme
from .comments.gather import __main__ as gather_main
from .comments.transform import __main__ as transform_main


def main(ci: bool):
    print(f'main start (ci={ci})')

    readme.main()
    fetch_github_pr.main()
    generate_pr_status.main()
    if not ci:
        gather_main.main()
    transform_main.main()


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--ci', action='store_true')
    args = parser.parse_args()

    main(ci=args.ci)

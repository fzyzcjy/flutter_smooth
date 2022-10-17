from generation import fetch_github_pr
from .comments.gather import __main__ as gather_main
from .comments.transform import __main__ as transform_main


def main():
    fetch_github_pr.main()
    gather_main.main()
    transform_main.main()


if __name__ == '__main__':
    main()

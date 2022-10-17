from generation import fetch_github_pr, generate_pr_status
from .comments.gather import __main__ as gather_main
from .comments.transform import __main__ as transform_main


def main():
    fetch_github_pr.main()
    generate_pr_status.main()
    gather_main.main()
    transform_main.main()


if __name__ == '__main__':
    main()

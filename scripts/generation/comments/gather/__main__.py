from . import github, discord, google_doc_comments


def main(ci: bool = False):
    github.main()
    if not ci:
        discord.main()
        google_doc_comments.main()


if __name__ == '__main__':
    main()

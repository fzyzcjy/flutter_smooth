from . import github, discord, google_doc_comments


def main():
    github.main()
    discord.main()
    google_doc_comments.main()


if __name__ == '__main__':
    main()

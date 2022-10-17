def gather_range(start_url: str, end_url_inclusive: str):
    TODO


def gather_all_in_channel(url: str):
    TODO


def main():
    # hackers-framework
    gather_range(
        start_url='https://discord.com/channels/608014603317936148/608021234516754444/1021783497112821861',
        end_url_inclusive='https://discord.com/channels/608014603317936148/608021234516754444/1021807402510716970',
    )
    gather_range(
        start_url='https://discord.com/channels/608014603317936148/608021234516754444/1021917668288245772',
        end_url_inclusive='https://discord.com/channels/608014603317936148/608021234516754444/1024852804029927537',
    )
    gather_range(
        start_url='https://discord.com/channels/608014603317936148/608021234516754444/1029371064066785340',
        end_url_inclusive='https://discord.com/channels/608014603317936148/608021234516754444/1029757386598121502',
    )

    # the discord "thread"
    gather_all_in_channel(
        url='https://discord.com/channels/608014603317936148/1021987751710699632',
    )


if __name__ == '__main__':
    main()

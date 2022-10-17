import os
import re
from pathlib import Path

from utils import run_command

_dir_out = Path('/tmp/out')


def _discord_token():
    return os.environ['DISCORD_TOKEN']


def _run_discord_chat_exporter(command, *args):
    run_command(
        f'docker run -it -v {_dir_out}:/out '
        f'tyrrrz/discordchatexporter:stable '
        f'{command} '
        f'--token {_discord_token()} '
        f'{" ".join(args)}'
    )


def _run_export_command(channel: str, *args):
    _run_discord_chat_exporter(
        'export',
        '--format', 'Json',
        '--channel', channel,
        *args,
    )


def gather_range(start_url: str, end_url_inclusive: str):
    matcher_start = re.match(r'https://discord.com/channels/(\d+)/(\d+)/(\d+)', start_url)
    matcher_end = re.match(r'https://discord.com/channels/(\d+)/(\d+)/(\d+)', end_url_inclusive)

    channel_id = matcher_start.group(1)
    assert channel_id == matcher_end.group(1)

    after = matcher_start.group(3)
    before = matcher_end.group(3)

    _run_export_command(channel_id, f'--after {after} --before {before}')


def gather_all_in_channel(url: str):
    channel_id = re.match(r'https://discord.com/channels/(\d+)/(\d+)', url).group(1)
    _run_export_command(channel_id)


def main():
    # hackers-framework
    if 0:
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
    if 0:
        gather_all_in_channel(
            url='https://discord.com/channels/608014603317936148/1021987751710699632',
        )


if __name__ == '__main__':
    main()

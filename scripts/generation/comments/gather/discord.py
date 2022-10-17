import json
import os
import re
import shutil
from pathlib import Path

from generation.comments.common import save_raw
from utils import run_command

_dir_out = Path('/tmp/out')


def _discord_token():
    return os.environ['DISCORD_TOKEN']


def _run_discord_chat_exporter(command, *args):
    run_command(
        f'docker run -it -v {_dir_out}:/out '
        f'-e HTTP_PROXY={os.environ["HTTP_PROXY"]} '
        f'-e HTTPS_PROXY={os.environ["HTTPS_PROXY"]} '
        f'tyrrrz/discordchatexporter:stable '
        f'{command} '
        f'--output /out '
        f'--token {_discord_token()} '
        f'{" ".join(args)}'
    )


def _run_export_command(channel_id: str, after, before):
    shutil.rmtree(str(_dir_out))

    _run_discord_chat_exporter(
        'export',
        '--format', 'Json',
        '--channel', channel_id,
        *(['--after', after] if after is not None else []),
        *(['--before', before] if before is not None else []),
    )

    json_paths = list(_dir_out.glob('*.json'))
    assert len(json_paths) == 1

    content = json_paths[0].read_text()

    save_raw(
        stem=f'discord_{channel_id}_{after or "all"}',
        source='discord',
        metadata=dict(
            channel_id=channel_id,
            after=after,
            before=before,
        ),
        content=json.loads(content),
    )


def gather_range(start_url_exclusive: str, end_url_exclusive: str):
    matcher_start = re.match(r'https://discord.com/channels/(\d+)/(\d+)/(\d+)', start_url_exclusive)
    matcher_end = re.match(r'https://discord.com/channels/(\d+)/(\d+)/(\d+)', end_url_exclusive)

    channel_id = matcher_start.group(2)
    assert channel_id == matcher_end.group(2)

    after = matcher_start.group(3)
    before = matcher_end.group(3)

    _run_export_command(channel_id, after=after, before=before)


def gather_all_in_channel(url: str):
    channel_id = re.match(r'https://discord.com/channels/(\d+)/(\d+)', url).group(2)
    _run_export_command(channel_id, after=None, before=None)


def main():
    # hackers-framework
    gather_range(
        start_url_exclusive='https://discord.com/channels/608014603317936148/608021234516754444/1019348859601825852',
        end_url_exclusive='https://discord.com/channels/608014603317936148/608021234516754444/1021814222688104548',
    )
    gather_range(
        start_url_exclusive='https://discord.com/channels/608014603317936148/608021234516754444/1021884336158548078',
        end_url_exclusive='https://discord.com/channels/608014603317936148/608021234516754444/1025657091169468436',
    )
    gather_range(
        start_url_exclusive='https://discord.com/channels/608014603317936148/608021234516754444/1029190035431506020',
        end_url_exclusive='https://discord.com/channels/608014603317936148/608021234516754444/1030376055774650439',
    )

    # the discord "thread"
    gather_all_in_channel(
        url='https://discord.com/channels/608014603317936148/1021987751710699632',
    )


if __name__ == '__main__':
    main()

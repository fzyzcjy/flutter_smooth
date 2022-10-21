import json
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Any

repo_base_dir = Path(__file__).parents[3]
dir_data_comments = repo_base_dir / 'blob/data/comments'
dir_data_comments_raw = dir_data_comments / 'raw'


def save_raw(stem: str, source: str, metadata: Dict, content: Any):
    (dir_data_comments_raw / f'{stem}.json').write_text(json.dumps(dict(
        source=source,
        metadata={
            # remove retrieve time, otherwise data is not reproducible
            # 'retrieve_time': datetime.now().isoformat(),
            **metadata,
        },
        content=content,
    )))


def read_raw_all():
    for p in dir_data_comments_raw.glob('*.json'):
        yield json.loads(p.read_text())


@dataclass
class TransformedComment:
    body: str
    author: str
    link: str
    source: str
    create_time: str
    # retrieve_time: str

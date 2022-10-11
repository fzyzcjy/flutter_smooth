import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any

dir_data_comments = Path(__file__).parents[2] / 'website/data/comments'
dir_data_comments_raw = dir_data_comments / 'raw'


def save_raw(stem: str, source: str, metadata: Dict, content: Any):
    (dir_data_comments_raw / f'{stem}.json').write_text(json.dumps(dict(
        source=source,
        metadata={
            'retrieve_time': datetime.now().isoformat(),
            **metadata,
        },
        content=content,
    )))


def read_raw_all():
    for p in dir_data_comments_raw.glob('*.json'):
        yield json.loads(p.read_text())

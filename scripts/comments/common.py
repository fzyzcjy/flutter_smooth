import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any

_dir_data_comments = Path(__file__).parents[2] / 'website/data/comments'


def save_raw(stem: str, source: str, metadata: Dict, content: Any):
    (_dir_data_comments / 'raw' / f'{stem}.json').write_text(json.dumps(dict(
        source=source,
        metadata={
            'retrieve_time': datetime.now().isoformat(),
            **metadata,
        },
        content=content,
    )))

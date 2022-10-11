import json

from comments.common import dir_data_comments_raw, dir_data_comments
from comments.transform import github

_transformers = {
    'github': github.transform,
}

if __name__ == '__main__':
    data_transformed = []

    for p_raw in dir_data_comments_raw.glob('*.json'):
        data_raw = json.loads(p_raw.read_text())
        data_transformed += _transformers[data_raw['source']](data_raw)

    (dir_data_comments / 'transformed.json').write_text(json.dumps(data_transformed))

    print('transform done')

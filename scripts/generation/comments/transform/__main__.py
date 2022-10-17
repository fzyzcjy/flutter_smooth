import json

from generation.comments.common import dir_data_comments_raw, TransformedComment, repo_base_dir
from generation.comments.transform import github, google_doc_comments, discord

_transformers = {
    github.SOURCE: github.transform,
    google_doc_comments.SOURCE: google_doc_comments.transform,
    discord.SOURCE: discord.transform,
}

_author_mappers = {
    'Ch Tom': 'fzyzcjy',
    'Ian Hickson': 'Hixie',
    'Dan Field': 'dnfield',
    'Jonah Williams': 'jonahwilliams',
    'Aaron Clarke': 'gaaclarke',
    'Nayuta': 'Nayuta403',
    'Jsouliang': 'JsouLiang',
    'XanaHopper': 'xanahopper',
}


def _visualize(data_transformed):
    yield '''<!-- THIS IS AUTO GENERATED, DO NOT MODIFY BY HAND -->

import DiscussionComment from '@site/src/components/DiscussionComment';'''

    for item in data_transformed:
        assert isinstance(item, TransformedComment)
        yield f'''
<DiscussionComment author="{item.author}" link="{item.link}" source="{item.source}" createTime="{item.create_time}" retrieveTime="{item.retrieve_time}">

{item.body}

</DiscussionComment>'''


def _analyze_data(data):
    try:
        import pandas as pd

        df = pd.DataFrame([item.__dict__ for item in data])
        print(f'authors:\n{df.author.value_counts()}')
    except:
        print('_analyze_data failed, skip it')  # e.g. in CI, pandas is not installed


def main():
    data_transformed = []

    for p_raw in dir_data_comments_raw.glob('*.json'):
        data_raw = json.loads(p_raw.read_text())
        data_transformed += _transformers[data_raw['source']](data_raw)

    data_transformed.sort(key=lambda item: item.create_time)

    for item in data_transformed:
        item.author = _author_mappers.get(item.author, item.author)
        item.body = item.body.replace('<reasons>', 'reasons')  # well, very hacky escape...

    _analyze_data(data_transformed)

    data_visualized = '\n'.join(_visualize(data_transformed))

    p = repo_base_dir / 'website/docs/insight/_conversation_generated.mdx'
    p.write_text(data_visualized)


if __name__ == '__main__':
    main()

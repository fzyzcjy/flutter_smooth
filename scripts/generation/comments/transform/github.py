from generation.comments.common import TransformedComment

SOURCE = 'github'


def _transform_comment(comment_raw, link):
    if comment_raw.get('isMinimized', False):
        return None

    body = comment_raw['body']

    title = comment_raw.get('title')
    if title is not None:
        body = f'### {title}\n\n{body}'

    return TransformedComment(
        author=comment_raw['author']['login'],
        body=body,
        link=link,  # do not have per-comment link yet
        create_time=comment_raw['createdAt'],
        # retrieve_time=retrieve_time,
        source=SOURCE,
    )


def transform(data_raw):
    metadata = data_raw['metadata']
    # retrieve_time = metadata['retrieve_time']
    link = f'https://github.com/{metadata["org"]}/{metadata["repo"]}/issues/{metadata["issue"]}'

    yield _transform_comment(data_raw['content'], link)

    for comment_raw in data_raw['content']['comments']:
        transformed_comment = _transform_comment(comment_raw, link)
        if transformed_comment is not None:
            yield transformed_comment

def _transform_comment(comment_raw, retrieve_time, link):
    if comment_raw['isMinimized']:
        return None

    return dict(
        author=comment_raw['author']['login'],
        body=comment_raw['body'],
        link=link,  # do not have per-comment link yet
        create_time=comment_raw['createdAt'],
        retrieve_time=retrieve_time,
    )


def transform(data_raw):
    metadata = data_raw['metadata']
    retrieve_time = metadata['retrieve_time']
    link = f'https://github.com/{metadata["org"]}/{metadata["repo"]}/issues/{metadata["issue"]}'

    for comment_raw in data_raw['content']['comments']:
        transformed_comment = _transform_comment(comment_raw, retrieve_time, link)
        if transformed_comment is not None:
            yield transformed_comment

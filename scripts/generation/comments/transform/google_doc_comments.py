from generation.comments.common import TransformedComment

SOURCE = 'google_doc_comments'

doc_id = '1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko'


def _parse_item(item, retrieve_time):
    comment_or_reply_id = item.get('commentId', item.get('replyId'))

    return TransformedComment(
        author=item['author']['displayName'],
        body=item['content'],
        link=f'https://docs.google.com/document/d/{doc_id}/edit?disco={comment_or_reply_id}',
        create_time=item['createdDate'],
        retrieve_time=retrieve_time,
        source=SOURCE,
    )


def transform(data_raw):
    retrieve_time = data_raw['metadata']['retrieve_time']

    for item in data_raw['content']['items']:
        yield _parse_item(item, retrieve_time)
        for reply in item['replies']:
            yield _parse_item(reply, retrieve_time)

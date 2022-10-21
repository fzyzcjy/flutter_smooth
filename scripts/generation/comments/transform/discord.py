from generation.comments.common import TransformedComment

SOURCE = 'discord'

server_id = 608014603317936148


def transform(data_raw):
    # retrieve_time = data_raw['metadata']['retrieve_time']
    channel_id = data_raw['metadata']['channel_id']

    for message in data_raw['content']['messages']:
        body = message['content']

        for attachment in message['attachments']:
            url = attachment['url']
            if url.endswith('png') or url.endswith('jpg') or url.endswith('jpeg'):
                body += f'\n![image]({url})'

        yield TransformedComment(
            author=message['author']['name'],
            body=body,
            link=f'https://discord.com/channels/{server_id}/{channel_id}/{message["id"]}',
            create_time=message['timestamp'],
            # retrieve_time=retrieve_time,
            source=SOURCE,
        )

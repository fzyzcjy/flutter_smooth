import json

from utils import repo_base_dir


def _generate_one(item):
    return f'* [{item["org"]}/{item["repo"]}#{item["number"]}](https://github.com/{item["org"]}/{item["repo"]}/pull/{item["number"]}): ' \
           f'![badge](https://img.shields.io/github/pulls/detail/state/{item["org"]}/{item["repo"]}/{item["number"]}) ' \
           f'({item["title"]} @ {item["createdAt"]})'


def main():
    items = json.loads((repo_base_dir / 'blob/data/github_pr.json').read_text())
    print(f'items={items}')

    items = sorted(items, key=lambda item: item['createdAt'], reverse=True)

    text = '\n'.join(
        _generate_one(item) for item in items
    )

    (repo_base_dir / 'website/docs/insight/_status_generated.mdx').write_text(text)


if __name__ == '__main__':
    main()

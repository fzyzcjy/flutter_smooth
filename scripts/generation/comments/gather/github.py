import json
import subprocess

from generation.comments.common import save_raw, repo_base_dir


def _strip_fields(raw):
    if isinstance(raw, list):
        for item in raw:
            _strip_fields(item)

    if isinstance(raw, dict):
        # https://github.com/fzyzcjy/flutter_smooth/issues/153#issuecomment-1288451480
        if 'viewerDidAuthor' in raw:
            del raw['viewerDidAuthor']

        for k, v in raw.items():
            _strip_fields(v)


def gather(org: str, repo: str, issue: int):
    print('step: run gh to get data')
    result = subprocess.run(f'gh issue view {issue} --repo {org}/{repo} --json author,body,createdAt,title,comments',
                            shell=True, stdout=subprocess.PIPE)
    assert result.returncode == 0
    data = result.stdout

    content = json.loads(data)
    _strip_fields(content)

    print('step: save data')
    save_raw(
        stem=f'github_{org}_{repo}_{issue}',
        source='github',
        metadata=dict(
            org=org,
            repo=repo,
            issue=issue,
        ),
        content=content,
    )


def main():
    gather(org='flutter', repo='flutter', issue=101227)

    for item in json.loads((repo_base_dir / 'blob/data/github_pr.json').read_text()):
        gather(org=item['org'], repo=item['repo'], issue=item['number'])


if __name__ == '__main__':
    main()

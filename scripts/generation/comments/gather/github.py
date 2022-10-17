import json
import subprocess

from generation.comments.common import save_raw


def gather(org: str, repo: str, issue: int):
    print('step: run gh to get data')
    result = subprocess.run(f'gh issue view {issue} --repo {org}/{repo} --json author,body,createdAt,title,comments',
                            shell=True, stdout=subprocess.PIPE)
    assert result.returncode == 0
    data = result.stdout

    print('step: save data')
    save_raw(
        stem=f'github_{org}_{repo}_{issue}',
        source='github',
        metadata=dict(
            org=org,
            repo=repo,
            issue=issue,
        ),
        content=json.loads(data),
    )


def main():
    gather(org='flutter', repo='flutter', issue=101227)


if __name__ == '__main__':
    main()

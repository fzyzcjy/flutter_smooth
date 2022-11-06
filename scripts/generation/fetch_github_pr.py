import json
import subprocess

from utils import repo_base_dir


def fetch_repo(org: str, repo: str):
    limit = 100

    result = subprocess.run(
        f"gh pr list "
        f"--repo {org}/{repo} "
        f"--limit {limit} "
        f"--state all "
        f"--author fzyzcjy "
        f"--json number,title,createdAt",
        shell=True, stdout=subprocess.PIPE)
    assert result.returncode == 0
    raw_data = json.loads(result.stdout)
    print(f'fetch_repo {org}/{repo} count={len(raw_data)} data={raw_data}')
    
    assert len(raw_data) < limit, 'looks like there is next page'

    return [
        {**item, 'org': org, 'repo': repo}
        for item in raw_data
    ]


def main():
    items = []
    items += fetch_repo('flutter', 'flutter')
    items += fetch_repo('flutter', 'engine')
    (repo_base_dir / 'blob/data/github_pr.json').write_text(json.dumps(items))


if __name__ == '__main__':
    main()

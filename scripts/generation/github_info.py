from dataclasses import dataclass


@dataclass
class GitHubEntry:
    org: str
    repo: str
    number: int


PR_INFO = [
    GitHubEntry('flutter', 'flutter', 101227),
    # TODO
]

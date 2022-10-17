from utils import repo_base_dir


def main():
    content_source = (repo_base_dir / 'README.md').read_text()

    content_website = TODO
    content_package_readme = TODO

    (repo_base_dir / 'website/docs/index.md').write_text(content_website)
    for package in ['smooth', 'smooth_dev']:
        (repo_base_dir / f'packages/{package}/README.md').write_text(content_package_readme)


if __name__ == '__main__':
    main()

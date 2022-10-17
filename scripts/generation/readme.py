from utils import repo_base_dir


def _replace_part(raw, part_name, part_replacer):
    lines = raw.split('\n')
    i_start = next(i for i, line in enumerate(lines) if f'start: {part_name}' in line)
    i_end = next(i for i, line in enumerate(lines) if f'end: {part_name}' in line)
    return '\n'.join([
        *lines[:i_start],
        part_replacer,
        *lines[i_end + 1:],
    ])


def _generate_content_website(c):
    c = _replace_part(c, 'title', '''---
title: Flutter Smooth
hide_title: true
---

import ReactPlayer from 'react-player'
    ''')

    c = _replace_part(c, 'video', '''
<div className="flex flex-row">
    <div className="flex-1"></div>
    <div className="flex" style={{flexDirection: 'column', alignItems: 'center'}}>
        <ReactPlayer 
            controls
            className="flex"
            width="480px"
            height="320px"
            url='https://github.com/fzyzcjy/flutter_smooth_blob/blob/master/video/output.mp4?raw=true'
        />
        <small>(left = without smooth, right = smooth; captured by external camera to maximally demonstrate end-user perception)</small>
    </div>
    <div className="flex-1"></div>
</div>
    ''')

    return c


def _generate_content_package_readme(content_source):
    return content_source


def main():
    content_source = (repo_base_dir / 'README.md').read_text()

    content_website = _generate_content_website(content_source)
    content_package_readme = _generate_content_package_readme(content_source)

    (repo_base_dir / 'website/docs/index.md').write_text(content_website)
    for package in ['smooth', 'smooth_dev']:
        (repo_base_dir / f'packages/{package}/README.md').write_text(content_package_readme)


if __name__ == '__main__':
    main()

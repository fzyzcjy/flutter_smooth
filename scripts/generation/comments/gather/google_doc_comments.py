import json

from generation.comments.common import save_raw, repo_base_dir


def main():
    """
    Run the following code in GoogleAppsScript, then manually download that json
    (https://script.google.com/home/projects/1VG0rPtARJhbypubpxLUO-QSjkhl2YpZUEL0-iQZ6eI4F3rQ0E9A2DYmL/edit)
    
    ```
    function myFunction() {
      // https://stackoverflow.com/questions/66103464/export-google-docs-comments-into-google-sheets-along-with-highlighted-text
      var docId = '1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko';
      var comments = Drive.Comments.list(docId);
      var content = JSON.stringify(comments)
      // https://stackoverflow.com/questions/36756045/export-google-spreadsheet-to-text-file-using-script
      DriveApp.createFile('my_export.json', content);
    }
    ```
    """

    save_raw(
        stem=f'google_doc_main',
        source='google_doc',
        metadata=dict(),
        content=json.loads((repo_base_dir / 'blob/data/google_doc_main_manual_download.json').read_text()),
    )


if __name__ == '__main__':
    main()

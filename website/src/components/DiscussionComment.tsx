import React from 'react';

const sourceTitleMap = {
    'github': 'GitHub',
}

// noinspection JSUnusedGlobalSymbols
export default function DiscussionComment({children, author, link, createTime, source, retrieveTime}) {
    const sourceTitle = sourceTitleMap[source]
    return <div className="discussion-comment border rounded mb-8 px-4 py-4">
        <div className="flex flex-row mb-4">
            <span className="font-semibold">{author}</span>
            &emsp;
            <span>{createTime}</span>
            <span className="flex-1"/>
            <a href={link}>{sourceTitle}</a>
        </div>
        {children}
    </div>
}

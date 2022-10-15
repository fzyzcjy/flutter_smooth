import React from 'react';

// noinspection JSUnusedGlobalSymbols
export default function DiscussionComment({children, author, link, createTime, retrieveTime}) {
    return <div className="discussion-comment border rounded mb-8 px-4 py-4">
        <div className="flex flex-row mb-4">
            <span className="font-semibold">{author}</span>
            &emsp;
            <span>{createTime}</span>
            <span className="flex-1"/>
            <a href={link}>Original link</a>
        </div>
        {children}
    </div>
}

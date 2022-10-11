import React from 'react';

// noinspection JSUnusedGlobalSymbols
export default function DiscussionComment({children, author, link, createTime, retrieveTime}) {
    // TODO
    return <div>
        <span>author={author}</span>
        <span>link={link}</span>
        <span>createTime={createTime}</span>
        <span>retrieveTime={retrieveTime}</span>
        {children}
    </div>
}

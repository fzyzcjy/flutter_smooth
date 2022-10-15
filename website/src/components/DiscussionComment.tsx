import React from 'react';
import {FaGithub} from 'react-icons/fa';

const sourceTitleMap = {
    'github': 'GitHub',
}
const sourceIconMap = {
    // TODO
    'github': <FaGithub className="inline-block pb-1"/>,
}

// noinspection JSUnusedGlobalSymbols
export default function DiscussionComment({children, author, link, createTime, source, retrieveTime}) {
    return <div className="discussion-comment border rounded mb-8 px-4 py-4">
        <div className="flex flex-row mb-4">
            <span className="font-semibold">{author}</span>
            &emsp;
            <span>{createTime}</span>
            <span className="flex-1"/>
            <a href={link}>
                {sourceIconMap[source]}
                &nbsp;
                {sourceTitleMap[source]}
            </a>
        </div>
        {children}
    </div>
}

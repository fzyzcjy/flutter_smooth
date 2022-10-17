import React from 'react';
import {FaDiscord, FaGithub, FaGoogle} from 'react-icons/fa';

const sourceTitleMap = {
    'github': 'GitHub',
    'discord': 'Discord',
    'google_doc_comments': 'Google Doc',
}
const sourceIconMap = {
    'github': <FaGithub className="inline-block pt-1"/>,
    'discord': <FaDiscord className="inline-block pt-1"/>,
    'google_doc_comments': <FaGoogle className="inline-block pt-1"/>,
}

// noinspection JSUnusedGlobalSymbols
export default function DiscussionComment({children, author, link, createTime, source, retrieveTime}) {
    return <div className="discussion-comment border border-solid border-slate-200 rounded mb-8 px-4 py-4">
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

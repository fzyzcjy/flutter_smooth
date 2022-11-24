"use strict";(self.webpackChunksmooth=self.webpackChunksmooth||[]).push([[9203],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>f});var r=n(7294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function s(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function o(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},i=Object.keys(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var c=r.createContext({}),l=function(e){var t=r.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):s(s({},t),e)),n},p=function(e){var t=l(e.components);return r.createElement(c.Provider,{value:t},e.children)},m={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},u=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,i=e.originalType,c=e.parentName,p=o(e,["components","mdxType","originalType","parentName"]),u=l(n),f=a,d=u["".concat(c,".").concat(f)]||u[f]||m[f]||i;return n?r.createElement(d,s(s({ref:t},p),{},{components:n})):r.createElement(d,s({ref:t},p))}));function f(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var i=n.length,s=new Array(i);s[0]=u;var o={};for(var c in t)hasOwnProperty.call(t,c)&&(o[c]=t[c]);o.originalType=e,o.mdxType="string"==typeof e?e:a,s[1]=o;for(var l=2;l<i;l++)s[l]=n[l];return r.createElement.apply(null,s)}return r.createElement.apply(null,n)}u.displayName="MDXCreateElement"},4752:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>c,contentTitle:()=>s,default:()=>m,frontMatter:()=>i,metadata:()=>o,toc:()=>l});var r=n(7462),a=(n(7294),n(3905));const i={},s="Fix jank by await vsync",o={unversionedId:"design/infra/misc/await-vsync",id:"design/infra/misc/await-vsync",title:"Fix jank by await vsync",description:"Title: Fix janks caused by await vsync in classical Flutter",source:"@site/docs/design/infra/misc/await-vsync.md",sourceDirName:"design/infra/misc",slug:"/design/infra/misc/await-vsync",permalink:"/flutter_smooth/design/infra/misc/await-vsync",draft:!1,editUrl:"https://github.com/fzyzcjy/flutter_smooth/tree/master/website/docs/design/infra/misc/await-vsync.md",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"Report timing slowness",permalink:"/flutter_smooth/design/infra/misc/report-timing"},next:{title:"Drop-in layer",permalink:"/flutter_smooth/design/drop-in/"}},c={},l=[],p={toc:l};function m(e){let{components:t,...n}=e;return(0,a.kt)("wrapper",(0,r.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"fix-jank-by-await-vsync"},"Fix jank by await vsync"),(0,a.kt)("admonition",{type:"info"},(0,a.kt)("p",{parentName:"admonition"},(0,a.kt)("strong",{parentName:"p"},"Title"),": Fix janks caused by await vsync in classical Flutter"),(0,a.kt)("p",{parentName:"admonition"},(0,a.kt)("strong",{parentName:"p"},"Link"),": ",(0,a.kt)("a",{parentName:"p",href:"https://github.com/flutter/engine/pull/36911"},"https://github.com/flutter/engine/pull/36911"))),(0,a.kt)("p",null,"This fixes the jank happened in ",(0,a.kt)("strong",{parentName:"p"},"classical")," Flutter, even without the existence of flutter_smooth"),(0,a.kt)("p",null,"During experiments, I observe a phenomenon: Even when the UI thread finishes everything ",(0,a.kt)("em",{parentName:"p"},"before")," the deadline (vsync) a few milliseconds, the next frame is scheduled ",(0,a.kt)("em",{parentName:"p"},"one")," vsync later, causing one jank. For example, UI thread may run from 0-15ms, but the next frame starts from 33.33ms instead of the correct 16.67ms."),(0,a.kt)("p",null,"An example screenshot can be seen at the end of this proposal. I added a timeline event, ",(0,a.kt)("inlineCode",{parentName:"p"},"Animator::AwaitVSync"),", so we can clearly see when vsync await is called. (This screenshot has roughly 3ms space; but more frequently, I see this bug when there is about 0.5-2ms space.)"),(0,a.kt)("p",null,"Therefore, this PR tries to fix this problem. The main idea is that, when detecting we are very near the next vsync, we do not wait at all, but instead directly start the next frame."),(0,a.kt)("p",null,(0,a.kt)("img",{parentName:"p",src:"https://user-images.githubusercontent.com/5236035/197105732-7c0bfbad-8816-46c0-85b1-5007d0f82d5d.png",alt:"image"})),(0,a.kt)("p",null,"zoom in:"),(0,a.kt)("p",null,(0,a.kt)("img",{parentName:"p",src:"https://user-images.githubusercontent.com/5236035/197105742-c511137c-3089-4ff9-b102-52bdfcfc72f9.png",alt:"image"})),(0,a.kt)("p",null,"further zoom in:"),(0,a.kt)("p",null,(0,a.kt)("img",{parentName:"p",src:"https://user-images.githubusercontent.com/5236035/197105754-fd471b8f-1ae7-45cb-b4d8-3163beb0d87a.png",alt:"image"})))}m.isMDXComponent=!0}}]);